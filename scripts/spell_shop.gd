class_name SpellShop
extends Control

signal spell_bought(spell_data: SpellData)
signal refresh_requested()
signal closed()

const INSTANT_SPELLS: Array = [
	preload("res://resources/spells/bolster.tres"),
	preload("res://resources/spells/fortify.tres"),
	preload("res://resources/spells/embolden.tres"),
	preload("res://resources/spells/wild_call.tres"),
	preload("res://resources/spells/arcane_infusion.tres"),
	preload("res://resources/spells/war_surge.tres"),
	preload("res://resources/spells/kindred_search.tres"),
]

var _offerings: Array = []
var _player_tier: int = 1
var _spells_container: VBoxContainer
var _refresh_btn: Button


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	z_index = 60
	mouse_filter = Control.MOUSE_FILTER_STOP
	_build_ui()
	visible = false


func _build_ui() -> void:
	var backdrop := ColorRect.new()
	backdrop.color = Color(0.0, 0.0, 0.0, 0.65)
	backdrop.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	backdrop.mouse_filter = Control.MOUSE_FILTER_PASS
	add_child(backdrop)

	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	center.mouse_filter = Control.MOUSE_FILTER_PASS
	add_child(center)

	var panel := PanelContainer.new()
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.10, 0.12, 0.18, 1.0)
	style.set_corner_radius_all(8)
	style.set_border_width_all(2)
	style.border_color = Color(0.45, 0.50, 0.80, 1.0)
	panel.add_theme_stylebox_override("panel", style)
	panel.custom_minimum_size = Vector2(560, 0)
	center.add_child(panel)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 16)
	margin.add_theme_constant_override("margin_right", 16)
	margin.add_theme_constant_override("margin_top", 14)
	margin.add_theme_constant_override("margin_bottom", 14)
	panel.add_child(margin)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 10)
	margin.add_child(vbox)

	var header := HBoxContainer.new()
	vbox.add_child(header)

	var title := Label.new()
	title.text = "Spell Shop"
	title.add_theme_font_size_override("font_size", 16)
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(title)

	_refresh_btn = Button.new()
	_refresh_btn.text = "Refresh (1g)"
	_refresh_btn.pressed.connect(_on_refresh_pressed)
	header.add_child(_refresh_btn)

	var close_btn := Button.new()
	close_btn.text = "Close"
	close_btn.pressed.connect(_on_close_pressed)
	header.add_child(close_btn)

	vbox.add_child(HSeparator.new())

	_spells_container = VBoxContainer.new()
	_spells_container.add_theme_constant_override("separation", 8)
	vbox.add_child(_spells_container)


func open(gold: int, tier: int) -> void:
	_player_tier = tier
	if _offerings.is_empty():
		_generate_offerings()
	_refresh_rows(gold)
	visible = true


func refresh_gold(gold: int) -> void:
	if visible:
		_refresh_rows(gold)


func new_round() -> void:
	_offerings.clear()


func do_refresh(gold: int) -> void:
	_offerings.clear()
	_generate_offerings()
	_refresh_rows(gold)


func remove_offering(spell: SpellData) -> void:
	var idx := _offerings.find(spell)
	if idx != -1:
		_offerings.remove_at(idx)


func _generate_offerings() -> void:
	var pool: Array = INSTANT_SPELLS.filter(func(s): return s.tier <= _player_tier)
	if pool.is_empty():
		_offerings = []
		return
	var count := _spells_for_tier(_player_tier)
	_offerings = []
	for _i in range(count):
		_offerings.append(pool[randi() % pool.size()])


func _spells_for_tier(tier: int) -> int:
	match tier:
		1: return 3
		2: return 4
		3: return 5
		_: return 6


func _refresh_rows(gold: int) -> void:
	for child in _spells_container.get_children():
		child.queue_free()

	_refresh_btn.disabled = gold < 1

	if _offerings.is_empty():
		var lbl := Label.new()
		lbl.text = "No spells available."
		lbl.add_theme_color_override("font_color", Color(0.6, 0.6, 0.6))
		_spells_container.add_child(lbl)
		return

	for spell: SpellData in _offerings:
		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 10)

		var name_lbl := Label.new()
		name_lbl.text = spell.display_name
		name_lbl.custom_minimum_size.x = 140
		name_lbl.add_theme_font_size_override("font_size", 12)

		var tier_lbl := Label.new()
		tier_lbl.text = "T%d" % spell.tier
		tier_lbl.custom_minimum_size.x = 26
		tier_lbl.add_theme_font_size_override("font_size", 11)
		tier_lbl.add_theme_color_override("font_color", Color(0.65, 0.65, 0.65))

		var desc_lbl := Label.new()
		desc_lbl.text = spell.description
		desc_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		desc_lbl.add_theme_font_size_override("font_size", 10)
		desc_lbl.add_theme_color_override("font_color", Color(0.75, 0.75, 0.85))
		desc_lbl.autowrap_mode = TextServer.AUTOWRAP_OFF
		desc_lbl.clip_text = true

		var cost_lbl := Label.new()
		cost_lbl.text = "%dg" % spell.buy_price
		cost_lbl.custom_minimum_size.x = 34
		cost_lbl.add_theme_font_size_override("font_size", 12)
		cost_lbl.add_theme_color_override("font_color", Color(1.0, 0.85, 0.2))

		var buy_btn := Button.new()
		buy_btn.text = "Buy"
		buy_btn.disabled = gold < spell.buy_price
		buy_btn.pressed.connect(_on_buy_pressed.bind(spell))

		row.add_child(name_lbl)
		row.add_child(tier_lbl)
		row.add_child(desc_lbl)
		row.add_child(cost_lbl)
		row.add_child(buy_btn)
		_spells_container.add_child(row)


func _on_buy_pressed(spell: SpellData) -> void:
	spell_bought.emit(spell)


func _on_refresh_pressed() -> void:
	refresh_requested.emit()


func _on_close_pressed() -> void:
	visible = false
	closed.emit()
