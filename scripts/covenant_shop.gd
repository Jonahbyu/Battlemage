class_name CovenantShop
extends Control

signal upgrade_bought(key: String)
signal divested()
signal closed()

var _data: CovenantShopData = null
var _gold: int = 0
var _gold_label: Label = null
var _info_vbox: VBoxContainer = null
var _upgrades_vbox: VBoxContainer = null


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	z_index = 80
	visible = false
	_build_ui()


func open(data: CovenantShopData, gold: int) -> void:
	_data = data
	_gold = gold
	_refresh()
	visible = true


func close() -> void:
	visible = false
	closed.emit()


func refresh_gold(gold: int) -> void:
	_gold = gold
	if visible:
		_refresh()


# ── UI construction ───────────────────────────────────────────────────────────

func _build_ui() -> void:
	var dim := ColorRect.new()
	dim.color = Color(0, 0, 0, 0.65)
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	dim.mouse_filter = Control.MOUSE_FILTER_PASS
	add_child(dim)

	var panel := Panel.new()
	var ps := StyleBoxFlat.new()
	ps.bg_color = Color(0.12, 0.03, 0.04, 0.98)
	ps.set_corner_radius_all(10)
	ps.set_border_width_all(2)
	ps.border_color = Color(0.75, 0.18, 0.18, 1.0)
	panel.add_theme_stylebox_override("panel", ps)
	panel.set_anchors_preset(Control.PRESET_FULL_RECT)
	panel.offset_left = 40
	panel.offset_top = 30
	panel.offset_right = -40
	panel.offset_bottom = -30
	add_child(panel)

	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	for side in ["margin_left", "margin_right", "margin_top", "margin_bottom"]:
		margin.add_theme_constant_override(side, 20)
	panel.add_child(margin)

	var outer := VBoxContainer.new()
	outer.add_theme_constant_override("separation", 14)
	margin.add_child(outer)

	var header := HBoxContainer.new()
	header.add_theme_constant_override("separation", 12)
	outer.add_child(header)

	var title := Label.new()
	title.text = "Covenant Blood Pact"
	title.add_theme_font_size_override("font_size", 22)
	title.add_theme_color_override("font_color", Color(1.0, 0.40, 0.40))
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(title)

	_gold_label = Label.new()
	_gold_label.add_theme_font_size_override("font_size", 15)
	_gold_label.add_theme_color_override("font_color", Color(1.0, 0.85, 0.20))
	header.add_child(_gold_label)

	var close_btn := Button.new()
	close_btn.text = "Close"
	close_btn.custom_minimum_size = Vector2(70, 30)
	close_btn.pressed.connect(close)
	header.add_child(close_btn)

	outer.add_child(HSeparator.new())

	var body := HBoxContainer.new()
	body.add_theme_constant_override("separation", 20)
	body.size_flags_vertical = Control.SIZE_EXPAND_FILL
	outer.add_child(body)

	var left := _make_inner_panel()
	left.custom_minimum_size = Vector2(260, 0)
	left.size_flags_vertical = Control.SIZE_EXPAND_FILL
	body.add_child(left)

	var lm := MarginContainer.new()
	lm.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	for side in ["margin_left", "margin_right", "margin_top", "margin_bottom"]:
		lm.add_theme_constant_override(side, 14)
	left.add_child(lm)

	_info_vbox = VBoxContainer.new()
	_info_vbox.add_theme_constant_override("separation", 8)
	lm.add_child(_info_vbox)

	var right := _make_inner_panel()
	right.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	right.size_flags_vertical = Control.SIZE_EXPAND_FILL
	body.add_child(right)

	var rm := MarginContainer.new()
	rm.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	for side in ["margin_left", "margin_right", "margin_top", "margin_bottom"]:
		rm.add_theme_constant_override(side, 14)
	right.add_child(rm)

	_upgrades_vbox = VBoxContainer.new()
	_upgrades_vbox.add_theme_constant_override("separation", 8)
	_upgrades_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	rm.add_child(_upgrades_vbox)


func _make_inner_panel() -> Panel:
	var p := Panel.new()
	var s := StyleBoxFlat.new()
	s.bg_color = Color(0.09, 0.02, 0.03, 1.0)
	s.set_corner_radius_all(6)
	s.set_border_width_all(1)
	s.border_color = Color(0.55, 0.14, 0.14, 0.7)
	p.add_theme_stylebox_override("panel", s)
	return p


# ── Refresh ───────────────────────────────────────────────────────────────────

func _refresh() -> void:
	if _data == null:
		return
	if _gold_label != null:
		_gold_label.text = "Gold: %d" % _gold
	_refresh_info()
	_refresh_upgrades()


func _refresh_info() -> void:
	for c in _info_vbox.get_children():
		c.queue_free()

	_info_vbox.add_child(_make_section_label("Blood Bond", Color(1.0, 0.40, 0.40)))
	_info_vbox.add_child(HSeparator.new())
	_info_vbox.add_child(_make_stat_row("Bond Share", "%d%%" % _data.bond_share_percent))
	var berserk_str := "%d%%" % _data.berserk_multiplier_percent if _data.berserk_multiplier_percent > 0 else "None"
	_info_vbox.add_child(_make_stat_row("Berserk Multiplier", berserk_str))
	_info_vbox.add_child(HSeparator.new())

	var desc := Label.new()
	desc.text = "Bonded units share stats when a bond forms. When a bonded partner dies, ALL bonded units go Berserk: immediately attack the killer, then gain bonus stats (scaled by Berserk Multiplier). Units can berserk multiple times."
	desc.autowrap_mode = TextServer.AUTOWRAP_WORD
	desc.add_theme_font_size_override("font_size", 11)
	desc.add_theme_color_override("font_color", Color(0.75, 0.50, 0.50))
	_info_vbox.add_child(desc)


func _refresh_upgrades() -> void:
	for c in _upgrades_vbox.get_children():
		c.queue_free()

	_upgrades_vbox.add_child(_make_section_label("Upgrades", Color(1.0, 0.40, 0.40)))
	_upgrades_vbox.add_child(HSeparator.new())

	var share_cost := _data.bond_share_cost()
	_upgrades_vbox.add_child(_make_upgrade_row(
		"Bond Share +10%",
		"Bonded units currently share %d%% of each other's stats." % _data.bond_share_percent,
		share_cost,
		"bond_share"
	))
	_upgrades_vbox.add_child(HSeparator.new())

	var berserk_cost := _data.berserk_cost()
	var berserk_desc: String
	if _data.berserk_multiplier_percent == 0:
		berserk_desc = "Berserk currently grants no bonus stats (attack only)."
	else:
		berserk_desc = "Berserk currently grants +%d%% bonus stats." % _data.berserk_multiplier_percent
	_upgrades_vbox.add_child(_make_upgrade_row(
		"Berserk Multiplier +10%",
		berserk_desc,
		berserk_cost,
		"berserk"
	))
	_upgrades_vbox.add_child(HSeparator.new())

	_upgrades_vbox.add_child(_make_divest_row())


# ── Helpers ───────────────────────────────────────────────────────────────────

func _make_divest_row() -> HBoxContainer:
	var refund := floori(_data.gold_invested * 0.75)
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 12)

	var name_lbl := Label.new()
	name_lbl.text = "Divest Shop"
	name_lbl.add_theme_font_size_override("font_size", 14)
	name_lbl.add_theme_color_override("font_color", Color(1.0, 0.45, 0.25))
	name_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(name_lbl)

	var btn := Button.new()
	btn.text = "Divest\n+%dg" % refund
	btn.custom_minimum_size = Vector2(72, 52)
	btn.disabled = _data.gold_invested == 0
	btn.tooltip_text = "Invested: %dg  →  Refund: %dg (75%%)\nResets all upgrades to default." % [_data.gold_invested, refund]
	btn.pressed.connect(func(): divested.emit())
	row.add_child(btn)
	return row


func _make_upgrade_row(label_text: String, desc_text: String, cost: int, key: String, force_disabled: bool = false) -> HBoxContainer:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 12)

	var info := VBoxContainer.new()
	info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(info)

	var name_lbl := Label.new()
	name_lbl.text = label_text
	name_lbl.add_theme_font_size_override("font_size", 14)
	info.add_child(name_lbl)

	var desc_lbl := Label.new()
	desc_lbl.text = desc_text
	desc_lbl.add_theme_font_size_override("font_size", 11)
	desc_lbl.add_theme_color_override("font_color", Color(0.70, 0.40, 0.40))
	desc_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD
	info.add_child(desc_lbl)

	var btn := Button.new()
	btn.text = "Buy\n%dg" % cost
	btn.custom_minimum_size = Vector2(72, 52)
	btn.disabled = force_disabled or _gold < cost
	btn.pressed.connect(func(): upgrade_bought.emit(key))
	row.add_child(btn)

	return row


func _make_section_label(text: String, color: Color) -> Label:
	var lbl := Label.new()
	lbl.text = text
	lbl.add_theme_font_size_override("font_size", 15)
	lbl.add_theme_color_override("font_color", color)
	return lbl


func _make_stat_row(left_text: String, right_text: String) -> HBoxContainer:
	var row := HBoxContainer.new()
	var lbl := Label.new()
	lbl.text = left_text
	lbl.add_theme_font_size_override("font_size", 12)
	lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(lbl)
	var val := Label.new()
	val.text = right_text
	val.add_theme_font_size_override("font_size", 12)
	val.add_theme_color_override("font_color", Color(1.0, 0.60, 0.60))
	val.custom_minimum_size = Vector2(80, 0)
	val.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	row.add_child(val)
	return row
