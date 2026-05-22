class_name GoblinShop
extends Control

signal upgrade_bought(key: String)
signal closed()

const UPGRADES: Array = [
	{"key": "budget",        "label": "Stat Budget",    "desc": "Peons get +1 total stat",                    "cost": 4},
	{"key": "reborn",        "label": "Reborn",         "desc": "+10% chance each Peon spawns with Reborn",   "cost": 5},
	{"key": "divine_shield", "label": "Divine Shield",  "desc": "+10% chance each Peon has Divine Shield",    "cost": 6},
	{"key": "poisonous",     "label": "Poisonous",      "desc": "+10% chance each Peon is Poisonous",         "cost": 7},
	{"key": "taunt",         "label": "Taunt",          "desc": "+10% chance each Peon has Taunt",            "cost": 4},
]

const UPGRADE_COSTS: Dictionary = {
	"budget": 4, "reborn": 5, "divine_shield": 6,
	"poisonous": 7, "taunt": 4,
}

var _data: GoblinShopData = null
var _gold: int = 0
var _gold_label: Label = null
var _preview_vbox: VBoxContainer = null
var _upgrades_vbox: VBoxContainer = null


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	z_index = 80
	visible = false
	_build_ui()


func open(data: GoblinShopData, gold: int) -> void:
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
	ps.bg_color = Color(0.08, 0.12, 0.05, 0.98)
	ps.set_corner_radius_all(10)
	ps.set_border_width_all(2)
	ps.border_color = Color(0.45, 0.70, 0.18, 1.0)
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

	# Header
	var header := HBoxContainer.new()
	header.add_theme_constant_override("separation", 12)
	outer.add_child(header)

	var title := Label.new()
	title.text = "Goblin Workshop"
	title.add_theme_font_size_override("font_size", 22)
	title.add_theme_color_override("font_color", Color(0.65, 1.0, 0.25))
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

	# Two-column body
	var body := HBoxContainer.new()
	body.add_theme_constant_override("separation", 20)
	body.size_flags_vertical = Control.SIZE_EXPAND_FILL
	outer.add_child(body)

	# Left: peon preview
	var left := _make_inner_panel()
	left.custom_minimum_size = Vector2(280, 0)
	left.size_flags_vertical = Control.SIZE_EXPAND_FILL
	body.add_child(left)

	var lm := MarginContainer.new()
	lm.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	for side in ["margin_left", "margin_right", "margin_top", "margin_bottom"]:
		lm.add_theme_constant_override(side, 14)
	left.add_child(lm)

	_preview_vbox = VBoxContainer.new()
	_preview_vbox.add_theme_constant_override("separation", 7)
	lm.add_child(_preview_vbox)

	# Right: upgrades
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
	s.bg_color = Color(0.06, 0.09, 0.03, 1.0)
	s.set_corner_radius_all(6)
	s.set_border_width_all(1)
	s.border_color = Color(0.35, 0.52, 0.14, 0.7)
	p.add_theme_stylebox_override("panel", s)
	return p


# ── Refresh ───────────────────────────────────────────────────────────────────

func _refresh() -> void:
	if _data == null:
		return
	if _gold_label != null:
		_gold_label.text = "Gold: %d" % _gold
	_refresh_preview()
	_refresh_upgrades()


func _refresh_preview() -> void:
	for c in _preview_vbox.get_children():
		c.queue_free()

	_preview_vbox.add_child(_make_section_label("Goblin Peon", Color(0.60, 1.0, 0.25)))
	_preview_vbox.add_child(HSeparator.new())

	_preview_vbox.add_child(_make_stat_row("Stat Budget", str(_data.stat_budget)))
	_preview_vbox.add_child(HSeparator.new())

	_preview_vbox.add_child(_make_stat_row("Reborn",        "%d%%" % _data.reborn_chance))
	_preview_vbox.add_child(_make_stat_row("Divine Shield", "%d%%" % _data.divine_shield_chance))
	_preview_vbox.add_child(_make_stat_row("Poisonous",     "%d%%" % _data.poisonous_chance))
	_preview_vbox.add_child(_make_stat_row("Taunt",         "%d%%" % _data.taunt_chance))

	_preview_vbox.add_child(HSeparator.new())

	_preview_vbox.add_child(_make_section_label("Example Spawns", Color(0.6, 0.6, 0.6)))
	for _i in range(4):
		var roll := _data.roll_peon()
		var kw_parts: Array[String] = []
		if roll["keywords"] & KeywordFlags.Keyword.TAUNT:         kw_parts.append("Taunt")
		if roll["keywords"] & KeywordFlags.Keyword.DIVINE_SHIELD: kw_parts.append("DS")
		if roll["keywords"] & KeywordFlags.Keyword.REBORN:        kw_parts.append("Reborn")
		if roll["keywords"] & KeywordFlags.Keyword.POISONOUS:     kw_parts.append("Poison")
		var kw_str := "  " + "  ".join(kw_parts) if not kw_parts.is_empty() else ""
		var row := _make_stat_row("  %d / %d" % [roll["atk"], roll["hp"]], kw_str)
		_preview_vbox.add_child(row)


func _refresh_upgrades() -> void:
	for c in _upgrades_vbox.get_children():
		c.queue_free()

	_upgrades_vbox.add_child(_make_section_label("Upgrades", Color(0.60, 1.0, 0.25)))
	_upgrades_vbox.add_child(HSeparator.new())

	for upg in UPGRADES:
		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 12)

		var info := VBoxContainer.new()
		info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row.add_child(info)

		var name_lbl := Label.new()
		name_lbl.text = upg["label"]
		name_lbl.add_theme_font_size_override("font_size", 14)
		info.add_child(name_lbl)

		var current_val := _get_current_value(upg["key"])
		var desc_lbl := Label.new()
		desc_lbl.text = "Now: %s  •  %s" % [current_val, upg["desc"]]
		desc_lbl.add_theme_font_size_override("font_size", 11)
		desc_lbl.add_theme_color_override("font_color", Color(0.55, 0.70, 0.40))
		desc_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD
		info.add_child(desc_lbl)

		var btn := Button.new()
		btn.text = "Buy\n%dg" % upg["cost"]
		btn.custom_minimum_size = Vector2(72, 52)
		btn.disabled = _gold < upg["cost"]
		var key: String = upg["key"]
		btn.pressed.connect(func(): upgrade_bought.emit(key))
		row.add_child(btn)

		_upgrades_vbox.add_child(row)
		_upgrades_vbox.add_child(HSeparator.new())


# ── Helpers ───────────────────────────────────────────────────────────────────

func _get_current_value(key: String) -> String:
	match key:
		"budget":        return str(_data.stat_budget)
		"reborn":        return "%d%%" % _data.reborn_chance
		"divine_shield": return "%d%%" % _data.divine_shield_chance
		"poisonous":     return "%d%%" % _data.poisonous_chance
		"taunt":         return "%d%%" % _data.taunt_chance
	return "?"


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
	val.add_theme_color_override("font_color", Color(0.75, 1.0, 0.40))
	val.custom_minimum_size = Vector2(60, 0)
	val.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	row.add_child(val)
	return row
