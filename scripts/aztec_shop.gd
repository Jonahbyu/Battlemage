class_name AztecShop
extends Control

signal upgrade_bought(key: String)
signal closed()

var _data: AztecShopData = null
var _gold: int = 0
var _player_tier: int = 1
var _player_hp: int = 100
var _tribute_used: bool = false
var _sacrifice_used: bool = false

var _gold_label: Label = null
var _info_vbox: VBoxContainer = null
var _upgrades_vbox: VBoxContainer = null


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	z_index = 80
	visible = false
	_build_ui()


func open(data: AztecShopData, gold: int, tier: int, hp: int, tribute_used: bool, sacrifice_used: bool) -> void:
	_data = data
	_gold = gold
	_player_tier = tier
	_player_hp = hp
	_tribute_used = tribute_used
	_sacrifice_used = sacrifice_used
	_refresh()
	visible = true


func close() -> void:
	visible = false
	closed.emit()


func refresh_gold(gold: int, hp: int, tribute_used: bool, sacrifice_used: bool) -> void:
	_gold = gold
	_player_hp = hp
	_tribute_used = tribute_used
	_sacrifice_used = sacrifice_used
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
	ps.bg_color = Color(0.14, 0.09, 0.02, 0.98)
	ps.set_corner_radius_all(10)
	ps.set_border_width_all(2)
	ps.border_color = Color(0.85, 0.65, 0.10, 1.0)
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
	title.text = "The Temple"
	title.add_theme_font_size_override("font_size", 22)
	title.add_theme_color_override("font_color", Color(1.0, 0.80, 0.15))
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
	left.custom_minimum_size = Vector2(280, 0)
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

	var scroll := ScrollContainer.new()
	scroll.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	rm.add_child(scroll)

	_upgrades_vbox = VBoxContainer.new()
	_upgrades_vbox.add_theme_constant_override("separation", 8)
	_upgrades_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(_upgrades_vbox)


func _make_inner_panel() -> Panel:
	var p := Panel.new()
	var s := StyleBoxFlat.new()
	s.bg_color = Color(0.10, 0.06, 0.01, 1.0)
	s.set_corner_radius_all(6)
	s.set_border_width_all(1)
	s.border_color = Color(0.65, 0.48, 0.08, 0.7)
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

	_info_vbox.add_child(_make_section_label("Golden Blessing", Color(1.0, 0.80, 0.15)))
	_info_vbox.add_child(HSeparator.new())
	_info_vbox.add_child(_make_stat_row("Blessing Rate", "+%d/+%d per gold" % [_data.blessing_rate, _data.blessing_rate]))
	var buff := _data.blessing_rate * _gold
	_info_vbox.add_child(_make_stat_row("Current Buff", "+%d/+%d per Aztec unit" % [buff, buff]))
	_info_vbox.add_child(HSeparator.new())

	_info_vbox.add_child(_make_section_label("Rituals (once per round)", Color(0.90, 0.55, 0.10)))
	_info_vbox.add_child(HSeparator.new())

	var tribute_gold_amt := _data.tribute_gold(_player_tier)
	var tribute_status := "Used this round" if _tribute_used else "Available  (5 HP → %dg)" % tribute_gold_amt
	var tribute_color := Color(0.5, 0.5, 0.5) if _tribute_used else Color(0.80, 0.65, 0.20)
	_info_vbox.add_child(_make_stat_row("Blood Tribute", tribute_status, tribute_color))

	var sac_status := "Used this round" if _sacrifice_used else "Available  (%dg per unit tier)" % _data.sacrifice_rate
	var sac_color := Color(0.5, 0.5, 0.5) if _sacrifice_used else Color(0.80, 0.65, 0.20)
	_info_vbox.add_child(_make_stat_row("Sacrifice", sac_status, sac_color))

	_info_vbox.add_child(HSeparator.new())
	var desc := Label.new()
	desc.text = "All Aztec units gain ATK/HP equal to your blessing rate × your saved gold at combat start. High Priest doubles the blessing rate. Temple Warden gives all Aztecs a flat +2/+2 on top. Sun Jaguar gains an extra +1 ATK per 5 gold held, beyond the blessing."
	desc.autowrap_mode = TextServer.AUTOWRAP_WORD
	desc.add_theme_font_size_override("font_size", 11)
	desc.add_theme_color_override("font_color", Color(0.70, 0.58, 0.30))
	_info_vbox.add_child(desc)


func _refresh_upgrades() -> void:
	for c in _upgrades_vbox.get_children():
		c.queue_free()

	_upgrades_vbox.add_child(_make_section_label("Upgrades", Color(1.0, 0.80, 0.15)))
	_upgrades_vbox.add_child(HSeparator.new())

	_upgrades_vbox.add_child(_make_upgrade_row(
		"Blessing Rate +1",
		"Each Aztec unit currently gains +%d/+%d per gold at combat start." % [_data.blessing_rate, _data.blessing_rate],
		_data.blessing_cost(),
		"blessing"
	))
	_upgrades_vbox.add_child(HSeparator.new())

	_upgrades_vbox.add_child(_make_upgrade_row(
		"Blood Tribute Rate +1",
		"Blood Tribute currently yields %d × tier = %dg for 5 HP." % [_data.tribute_rate, _data.tribute_gold(_player_tier)],
		_data.tribute_cost(),
		"tribute_rate"
	))
	_upgrades_vbox.add_child(HSeparator.new())

	_upgrades_vbox.add_child(_make_upgrade_row(
		"Sacrifice Rate +1",
		"Sacrificed units currently yield %dg × unit tier." % _data.sacrifice_rate,
		_data.sacrifice_cost(),
		"sacrifice_rate"
	))
	_upgrades_vbox.add_child(HSeparator.new())

	_upgrades_vbox.add_child(_make_section_label("Rituals", Color(0.90, 0.55, 0.10)))
	_upgrades_vbox.add_child(HSeparator.new())

	var tribute_gold_amt := _data.tribute_gold(_player_tier)
	_upgrades_vbox.add_child(_make_action_row(
		"Blood Tribute",
		"Sacrifice 5 HP to gain %dg (Tier %d × %d)." % [tribute_gold_amt, _player_tier, _data.tribute_rate],
		"tribute",
		_tribute_used or _player_hp <= 5
	))
	_upgrades_vbox.add_child(HSeparator.new())

	_upgrades_vbox.add_child(_make_action_row(
		"Sacrifice Unit",
		"Sacrifice one unit for gold equal to its tier × %d. Click, then pick a unit." % _data.sacrifice_rate,
		"sacrifice",
		_sacrifice_used
	))
	_upgrades_vbox.add_child(HSeparator.new())


# ── Helpers ───────────────────────────────────────────────────────────────────

func _make_upgrade_row(label_text: String, desc_text: String, cost: int, key: String) -> HBoxContainer:
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
	desc_lbl.add_theme_color_override("font_color", Color(0.65, 0.52, 0.25))
	desc_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD
	info.add_child(desc_lbl)

	var btn := Button.new()
	btn.text = "Buy\n%dg" % cost
	btn.custom_minimum_size = Vector2(72, 52)
	btn.disabled = _gold < cost
	btn.pressed.connect(func(): upgrade_bought.emit(key))
	row.add_child(btn)

	return row


func _make_action_row(label_text: String, desc_text: String, key: String, force_disabled: bool) -> HBoxContainer:
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
	desc_lbl.add_theme_color_override("font_color", Color(0.65, 0.52, 0.25))
	desc_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD
	info.add_child(desc_lbl)

	var btn := Button.new()
	btn.text = "Use"
	btn.custom_minimum_size = Vector2(72, 52)
	btn.disabled = force_disabled
	btn.pressed.connect(func(): upgrade_bought.emit(key))
	row.add_child(btn)

	return row


func _make_section_label(text: String, color: Color) -> Label:
	var lbl := Label.new()
	lbl.text = text
	lbl.add_theme_font_size_override("font_size", 15)
	lbl.add_theme_color_override("font_color", color)
	return lbl


func _make_stat_row(left_text: String, right_text: String, right_color: Color = Color(0.90, 0.75, 0.30)) -> HBoxContainer:
	var row := HBoxContainer.new()
	var lbl := Label.new()
	lbl.text = left_text
	lbl.add_theme_font_size_override("font_size", 12)
	lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(lbl)
	var val := Label.new()
	val.text = right_text
	val.add_theme_font_size_override("font_size", 12)
	val.add_theme_color_override("font_color", right_color)
	val.custom_minimum_size = Vector2(120, 0)
	val.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	row.add_child(val)
	return row
