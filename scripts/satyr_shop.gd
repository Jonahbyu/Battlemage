class_name SatyrShop
extends Control

signal upgrade_bought(key: String)
signal closed()

var _data: SatyrShopData = null
var _gold: int = 0

var _gold_label: Label = null
var _info_vbox: VBoxContainer = null
var _upgrades_vbox: VBoxContainer = null

const CRIMSON_COLOR := Color(0.95, 0.28, 0.28)
const GOLD_COLOR    := Color(1.00, 0.85, 0.20)
const SILVER_COLOR  := Color(0.80, 0.88, 1.00)
const GREEN_COLOR   := Color(0.32, 0.88, 0.45)
const BLACK_COLOR   := Color(0.72, 0.48, 0.95)
const PRISMATIC_COLOR := Color(1.00, 1.00, 0.65)
const ACCENT_COLOR  := Color(1.00, 0.78, 0.32)


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	z_index = 80
	visible = false
	_build_ui()


func open(data: SatyrShopData, gold: int) -> void:
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


# ── UI construction ────────────────────────────────────────────────────────────

func _build_ui() -> void:
	var dim := ColorRect.new()
	dim.color = Color(0, 0, 0, 0.65)
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	dim.mouse_filter = Control.MOUSE_FILTER_PASS
	add_child(dim)

	var panel := Panel.new()
	var ps := StyleBoxFlat.new()
	ps.bg_color = Color(0.10, 0.08, 0.06, 0.98)
	ps.set_corner_radius_all(10)
	ps.set_border_width_all(2)
	ps.border_color = Color(0.85, 0.62, 0.22, 1.0)
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
	title.text = "The Sacred Grove  (Satyrs)"
	title.add_theme_font_size_override("font_size", 22)
	title.add_theme_color_override("font_color", ACCENT_COLOR)
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
	left.custom_minimum_size = Vector2(310, 0)
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
	s.bg_color = Color(0.07, 0.06, 0.04, 1.0)
	s.set_corner_radius_all(6)
	s.set_border_width_all(1)
	s.border_color = Color(0.52, 0.40, 0.18, 0.7)
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

	_info_vbox.add_child(_make_section_label("Satyr Colors", ACCENT_COLOR))
	_info_vbox.add_child(HSeparator.new())

	_info_vbox.add_child(_make_stat_row(
		"Crimson  (Sacrifice)",
		"On death: %d dmg to random enemy" % _data.crimson_damage,
		CRIMSON_COLOR))
	_info_vbox.add_child(_make_stat_row(
		"Gold  (Glory)",
		"+%d ATK to all allies while alive" % _data.gold_atk_bonus,
		GOLD_COLOR))
	_info_vbox.add_child(_make_stat_row(
		"Silver  (The Hunt)",
		"+%d bonus dmg vs highest-HP target" % _data.silver_bonus_damage,
		SILVER_COLOR))
	_info_vbox.add_child(_make_stat_row(
		"Green  (The Grove)",
		"Deathknell: +%d/+%d passed to next unit, chains" % [_data.green_stat_bonus, _data.green_stat_bonus],
		GREEN_COLOR))
	_info_vbox.add_child(_make_stat_row(
		"Black  (Forbidden Rites)",
		"On hit: -%d%% ATK to random enemy" % _data.black_debuff_percent,
		BLACK_COLOR))

	_info_vbox.add_child(HSeparator.new())
	_info_vbox.add_child(_make_section_label("Prismatic", ACCENT_COLOR))
	_info_vbox.add_child(HSeparator.new())

	_info_vbox.add_child(_make_stat_row(
		"Bonus per Color Alive",
		"+%d%% board stats" % _data.prismatic_percent,
		PRISMATIC_COLOR))

	var desc := Label.new()
	desc.text = "Prismatic scales live as Satyrs die. Mono-color bonus: if only one color remains, that color's effect is doubled."
	desc.autowrap_mode = TextServer.AUTOWRAP_WORD
	desc.add_theme_font_size_override("font_size", 11)
	desc.add_theme_color_override("font_color", Color(0.55, 0.50, 0.40))
	_info_vbox.add_child(desc)


func _refresh_upgrades() -> void:
	for c in _upgrades_vbox.get_children():
		c.queue_free()

	_upgrades_vbox.add_child(_make_section_label("Color Upgrades", ACCENT_COLOR))
	_upgrades_vbox.add_child(HSeparator.new())

	_upgrades_vbox.add_child(_make_upgrade_row(
		"Crimson Fury",
		"Death burst deals %d dmg (currently %d)." % [_data.crimson_damage + 5, _data.crimson_damage],
		_data.crimson_cost(), "crimson", CRIMSON_COLOR))
	_upgrades_vbox.add_child(HSeparator.new())

	_upgrades_vbox.add_child(_make_upgrade_row(
		"Golden Aura",
		"Gold Satyr grants +%d ATK to all allies while alive (currently +%d)." % [_data.gold_atk_bonus + 1, _data.gold_atk_bonus],
		_data.gold_cost(), "gold", GOLD_COLOR))
	_upgrades_vbox.add_child(HSeparator.new())

	_upgrades_vbox.add_child(_make_upgrade_row(
		"Hunter's Mark",
		"Silver deals +%d bonus dmg vs highest-HP target (currently +%d)." % [_data.silver_bonus_damage + 5, _data.silver_bonus_damage],
		_data.silver_cost(), "silver", SILVER_COLOR))
	_upgrades_vbox.add_child(HSeparator.new())

	_upgrades_vbox.add_child(_make_upgrade_row(
		"Grove's Gift",
		"Deathknell passes +%d/+%d (currently +%d/+%d)." % [_data.green_stat_bonus + 1, _data.green_stat_bonus + 1, _data.green_stat_bonus, _data.green_stat_bonus],
		_data.green_cost(), "green", GREEN_COLOR))
	_upgrades_vbox.add_child(HSeparator.new())

	_upgrades_vbox.add_child(_make_upgrade_row(
		"Plague Curse",
		"Black debuffs enemy ATK by -%d%% on hit (currently -%d%%)." % [_data.black_debuff_percent + 10, _data.black_debuff_percent],
		_data.black_cost(), "black", BLACK_COLOR))
	_upgrades_vbox.add_child(HSeparator.new())

	_upgrades_vbox.add_child(_make_section_label("Prismatic Upgrade", ACCENT_COLOR))
	_upgrades_vbox.add_child(HSeparator.new())

	_upgrades_vbox.add_child(_make_upgrade_row(
		"Prismatic Revelation",
		"Board stats +%d%% per color alive (currently +%d%%)." % [_data.prismatic_percent + 5, _data.prismatic_percent],
		_data.prismatic_cost(), "prismatic", PRISMATIC_COLOR))
	_upgrades_vbox.add_child(HSeparator.new())


# ── Helpers ───────────────────────────────────────────────────────────────────

func _make_upgrade_row(label_text: String, desc_text: String, cost: int, key: String, accent: Color) -> HBoxContainer:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 12)

	var info := VBoxContainer.new()
	info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(info)

	var name_lbl := Label.new()
	name_lbl.text = label_text
	name_lbl.add_theme_font_size_override("font_size", 14)
	name_lbl.add_theme_color_override("font_color", accent)
	info.add_child(name_lbl)

	var desc_lbl := Label.new()
	desc_lbl.text = desc_text
	desc_lbl.add_theme_font_size_override("font_size", 11)
	desc_lbl.add_theme_color_override("font_color", Color(0.52, 0.47, 0.38))
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


func _make_stat_row(left_text: String, right_text: String, right_color: Color) -> HBoxContainer:
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
	val.custom_minimum_size = Vector2(185, 0)
	val.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	val.autowrap_mode = TextServer.AUTOWRAP_WORD
	row.add_child(val)
	return row
