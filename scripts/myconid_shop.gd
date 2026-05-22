class_name MyconidShop
extends Control

signal upgrade_bought(key: String)
signal spore_distributed(card: UnitCard)
signal closed()

var _data: MyconidShopData = null
var _gold: int = 0
var _units: Array = []  # Myconid UnitCards available for pool distribution

var _gold_label: Label = null
var _info_vbox: VBoxContainer = null
var _upgrades_vbox: VBoxContainer = null


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	z_index = 80
	visible = false
	_build_ui()


func open(data: MyconidShopData, gold: int, units: Array) -> void:
	_data = data
	_gold = gold
	_units = units
	_refresh()
	visible = true


func close() -> void:
	visible = false
	closed.emit()


func refresh_gold(gold: int, units: Array) -> void:
	_gold = gold
	_units = units
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
	ps.bg_color = Color(0.05, 0.12, 0.06, 0.98)
	ps.set_corner_radius_all(10)
	ps.set_border_width_all(2)
	ps.border_color = Color(0.25, 0.70, 0.35, 1.0)
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
	title.text = "The Grove"
	title.add_theme_font_size_override("font_size", 22)
	title.add_theme_color_override("font_color", Color(0.50, 0.95, 0.55))
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
	s.bg_color = Color(0.04, 0.09, 0.04, 1.0)
	s.set_corner_radius_all(6)
	s.set_border_width_all(1)
	s.border_color = Color(0.20, 0.50, 0.25, 0.7)
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

	_info_vbox.add_child(_make_section_label("Spore System", Color(0.50, 0.95, 0.55)))
	_info_vbox.add_child(HSeparator.new())
	_info_vbox.add_child(_make_stat_row("Sporulation", "+%d spores/round/Myconid" % _data.sporulation_rate))
	_info_vbox.add_child(_make_stat_row("Spore Buff", "+%d/+%d per spore" % [_data.spore_buff_level, _data.spore_buff_level]))
	_info_vbox.add_child(_make_stat_row("Spore Pool", "%d spores" % _data.spore_pool))
	_info_vbox.add_child(HSeparator.new())

	var desc := Label.new()
	desc.text = "Myconids generate Spores each round. Each spore gives +%d/+%d in combat. Every 10 spores spawns a Parasite on death — half the spores go to the Parasite(s), half to an adjacent Myconid. Surviving Parasites add their spores to the pool after combat. Last unit keeps 75%% of spores." % [_data.spore_buff_level, _data.spore_buff_level]
	desc.autowrap_mode = TextServer.AUTOWRAP_WORD
	desc.add_theme_font_size_override("font_size", 11)
	desc.add_theme_color_override("font_color", Color(0.38, 0.58, 0.40))
	_info_vbox.add_child(desc)


func _refresh_upgrades() -> void:
	for c in _upgrades_vbox.get_children():
		c.queue_free()

	# ── Spore Pool distribution ───────────────────────────────────────────────
	_upgrades_vbox.add_child(_make_section_label("Spore Pool  (%d available)" % _data.spore_pool, Color(0.50, 0.95, 0.55)))
	_upgrades_vbox.add_child(HSeparator.new())

	if _units.is_empty():
		var no_units := Label.new()
		no_units.text = "No Myconids on board or bench."
		no_units.add_theme_font_size_override("font_size", 11)
		no_units.add_theme_color_override("font_color", Color(0.38, 0.58, 0.40))
		_upgrades_vbox.add_child(no_units)
	else:
		for card: UnitCard in _units:
			if not is_instance_valid(card):
				continue
			_upgrades_vbox.add_child(_make_distribute_row(card))
	_upgrades_vbox.add_child(HSeparator.new())

	# ── Upgrades ──────────────────────────────────────────────────────────────
	_upgrades_vbox.add_child(_make_section_label("Upgrades", Color(0.50, 0.95, 0.55)))
	_upgrades_vbox.add_child(HSeparator.new())

	_upgrades_vbox.add_child(_make_upgrade_row(
		"Sporulation +1",
		"Each starting Myconid currently generates %d spore(s) per round." % _data.sporulation_rate,
		_data.sporulation_cost(),
		"sporulation"
	))
	_upgrades_vbox.add_child(HSeparator.new())

	_upgrades_vbox.add_child(_make_upgrade_row(
		"Spore Buff +1/+1",
		"Each spore currently gives +%d/+%d in combat." % [_data.spore_buff_level, _data.spore_buff_level],
		_data.spore_buff_cost(),
		"spore_buff"
	))
	_upgrades_vbox.add_child(HSeparator.new())

	_upgrades_vbox.add_child(_make_section_label("Actions", Color(0.35, 0.80, 0.45)))
	_upgrades_vbox.add_child(HSeparator.new())

	_upgrades_vbox.add_child(_make_buy_spores_row())
	_upgrades_vbox.add_child(HSeparator.new())


# ── Helpers ───────────────────────────────────────────────────────────────────

func _make_distribute_row(card: UnitCard) -> HBoxContainer:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 12)

	var info := VBoxContainer.new()
	info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(info)

	var name_lbl := Label.new()
	name_lbl.text = card.data.display_name
	name_lbl.add_theme_font_size_override("font_size", 13)
	info.add_child(name_lbl)

	var spore_lbl := Label.new()
	spore_lbl.text = "%d spores" % card.myconid_spores
	spore_lbl.add_theme_font_size_override("font_size", 11)
	spore_lbl.add_theme_color_override("font_color", Color(0.45, 0.80, 0.50))
	info.add_child(spore_lbl)

	var btn := Button.new()
	btn.text = "Give 1"
	btn.custom_minimum_size = Vector2(72, 44)
	btn.disabled = _data.spore_pool <= 0
	btn.pressed.connect(func(): spore_distributed.emit(card))
	row.add_child(btn)

	return row


func _make_buy_spores_row() -> HBoxContainer:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 12)

	var info := VBoxContainer.new()
	info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(info)

	var name_lbl := Label.new()
	name_lbl.text = "Buy Spores"
	name_lbl.add_theme_font_size_override("font_size", 14)
	info.add_child(name_lbl)

	var desc_lbl := Label.new()
	desc_lbl.text = "Give +1 Spore to every Myconid on your board. (3g)"
	desc_lbl.add_theme_font_size_override("font_size", 11)
	desc_lbl.add_theme_color_override("font_color", Color(0.32, 0.50, 0.35))
	desc_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD
	info.add_child(desc_lbl)

	var btn := Button.new()
	btn.text = "Buy\n3g"
	btn.custom_minimum_size = Vector2(72, 52)
	btn.disabled = _gold < 3
	btn.pressed.connect(func(): upgrade_bought.emit("buy_spores"))
	row.add_child(btn)

	return row


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
	desc_lbl.add_theme_color_override("font_color", Color(0.32, 0.50, 0.35))
	desc_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD
	info.add_child(desc_lbl)

	var btn := Button.new()
	btn.text = "Buy\n%dg" % cost
	btn.custom_minimum_size = Vector2(72, 52)
	btn.disabled = _gold < cost
	btn.pressed.connect(func(): upgrade_bought.emit(key))
	row.add_child(btn)

	return row


func _make_section_label(text: String, color: Color) -> Label:
	var lbl := Label.new()
	lbl.text = text
	lbl.add_theme_font_size_override("font_size", 15)
	lbl.add_theme_color_override("font_color", color)
	return lbl


func _make_stat_row(left_text: String, right_text: String, right_color: Color = Color(0.45, 0.80, 0.50)) -> HBoxContainer:
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
	val.custom_minimum_size = Vector2(160, 0)
	val.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	row.add_child(val)
	return row
