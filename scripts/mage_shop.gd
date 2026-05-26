class_name MageShop
extends Control

signal trigger_bought(trigger: int)
signal mage_effect_upgraded()
signal triggers_divested()
signal mage_effect_divested()
signal closed()

const TRIGGER_ORDER: Array = [
	SpellTrigger.Trigger.ON_ATTACK,
	SpellTrigger.Trigger.WHEN_ATTACKED,
	SpellTrigger.Trigger.DEATH_KNELL,
	SpellTrigger.Trigger.START_OF_COMBAT,
]

var _cards: Array = []
var _target_card: UnitCard = null
var _gold: int = 0
var _gold_label: Label = null
var _unit_list_vbox: VBoxContainer = null
var _triggers_vbox: VBoxContainer = null


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	z_index = 80
	visible = false
	_build_ui()


func open(cards: Array, initial_card: UnitCard, gold: int) -> void:
	_cards = cards
	_target_card = initial_card
	_gold = gold
	_refresh()
	visible = true


func refresh(gold: int) -> void:
	if visible:
		_gold = gold
		_refresh()


func get_target_card() -> UnitCard:
	return _target_card


func close() -> void:
	visible = false
	closed.emit()


# ── UI construction ───────────────────────────────────────────────────────────

func _build_ui() -> void:
	var dim := ColorRect.new()
	dim.color = Color(0, 0, 0, 0.65)
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	dim.mouse_filter = Control.MOUSE_FILTER_PASS
	add_child(dim)

	var panel := Panel.new()
	var ps := StyleBoxFlat.new()
	ps.bg_color = Color(0.10, 0.08, 0.18, 0.98)
	ps.set_corner_radius_all(10)
	ps.set_border_width_all(2)
	ps.border_color = Color(0.55, 0.40, 0.80, 1.0)
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
	title.text = "Mage Shop"
	title.add_theme_font_size_override("font_size", 22)
	title.add_theme_color_override("font_color", Color(0.75, 0.60, 1.0))
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

	# Left: unit list
	var left := _make_inner_panel()
	left.custom_minimum_size = Vector2(240, 0)
	left.size_flags_vertical = Control.SIZE_EXPAND_FILL
	body.add_child(left)

	var lm := MarginContainer.new()
	lm.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	for side in ["margin_left", "margin_right", "margin_top", "margin_bottom"]:
		lm.add_theme_constant_override(side, 14)
	left.add_child(lm)

	var scroll_left := ScrollContainer.new()
	scroll_left.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll_left.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	lm.add_child(scroll_left)

	_unit_list_vbox = VBoxContainer.new()
	_unit_list_vbox.add_theme_constant_override("separation", 6)
	_unit_list_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll_left.add_child(_unit_list_vbox)

	# Right: triggers
	var right := _make_inner_panel()
	right.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	right.size_flags_vertical = Control.SIZE_EXPAND_FILL
	body.add_child(right)

	var rm := MarginContainer.new()
	rm.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	for side in ["margin_left", "margin_right", "margin_top", "margin_bottom"]:
		rm.add_theme_constant_override(side, 14)
	right.add_child(rm)

	var scroll_right := ScrollContainer.new()
	scroll_right.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll_right.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	rm.add_child(scroll_right)

	_triggers_vbox = VBoxContainer.new()
	_triggers_vbox.add_theme_constant_override("separation", 8)
	_triggers_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll_right.add_child(_triggers_vbox)


func _make_inner_panel() -> Panel:
	var p := Panel.new()
	var s := StyleBoxFlat.new()
	s.bg_color = Color(0.08, 0.06, 0.14, 1.0)
	s.set_corner_radius_all(6)
	s.set_border_width_all(1)
	s.border_color = Color(0.45, 0.32, 0.65, 0.7)
	p.add_theme_stylebox_override("panel", s)
	return p


# ── Refresh ───────────────────────────────────────────────────────────────────

func _refresh() -> void:
	if _gold_label != null:
		_gold_label.text = "Gold: %d" % _gold
	_refresh_unit_list()
	_refresh_triggers()


func _refresh_unit_list() -> void:
	for c in _unit_list_vbox.get_children():
		c.queue_free()

	var section_lbl := Label.new()
	section_lbl.text = "Mages"
	section_lbl.add_theme_font_size_override("font_size", 15)
	section_lbl.add_theme_color_override("font_color", Color(0.75, 0.60, 1.0))
	_unit_list_vbox.add_child(section_lbl)
	_unit_list_vbox.add_child(HSeparator.new())

	if _cards.is_empty():
		var empty_lbl := Label.new()
		empty_lbl.text = "No mages on board"
		empty_lbl.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5))
		_unit_list_vbox.add_child(empty_lbl)
		return

	for card: UnitCard in _cards:
		if not is_instance_valid(card):
			continue
		var btn := Button.new()
		btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		btn.alignment = HORIZONTAL_ALIGNMENT_LEFT

		var inst: SpellInstance = card.equipped_spell
		var spell_name: String
		if inst != null:
			spell_name = inst.spell_data.display_name
		elif card.data.mage_effect == MageEffect.Effect.DEATH_KNELL_GOLD:
			spell_name = "Gold Lv.%d" % card.mage_effect_level
		else:
			spell_name = "No spell"
		btn.text = "%s\n%s" % [card.data.display_name, spell_name]

		if card == _target_card:
			var sel := StyleBoxFlat.new()
			sel.bg_color = Color(0.25, 0.18, 0.40, 1.0)
			sel.set_corner_radius_all(4)
			btn.add_theme_stylebox_override("normal", sel)

		var target := card
		btn.pressed.connect(func():
			_target_card = target
			_refresh())
		_unit_list_vbox.add_child(btn)


func _refresh_triggers() -> void:
	for c in _triggers_vbox.get_children():
		c.queue_free()

	if _target_card == null or not is_instance_valid(_target_card):
		return

	var unit_lbl := Label.new()
	unit_lbl.text = _target_card.data.display_name
	unit_lbl.add_theme_font_size_override("font_size", 15)
	unit_lbl.add_theme_color_override("font_color", Color(0.85, 0.75, 1.0))
	_triggers_vbox.add_child(unit_lbl)

	var inst: SpellInstance = _target_card.equipped_spell
	if inst == null:
		if _target_card.data.mage_effect == MageEffect.Effect.DEATH_KNELL_GOLD:
			_build_coin_sage_invest_row()
		else:
			var no_lbl := Label.new()
			no_lbl.text = "No spell equipped"
			no_lbl.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5))
			_triggers_vbox.add_child(no_lbl)
		return

	var spell_lbl := Label.new()
	spell_lbl.text = inst.spell_data.display_name
	spell_lbl.add_theme_font_size_override("font_size", 13)
	spell_lbl.add_theme_color_override("font_color", Color(0.65, 0.55, 0.90))
	_triggers_vbox.add_child(spell_lbl)

	_triggers_vbox.add_child(HSeparator.new())

	var trigger_hdr := Label.new()
	trigger_hdr.text = "Add / Upgrade Triggers"
	trigger_hdr.add_theme_font_size_override("font_size", 14)
	trigger_hdr.add_theme_color_override("font_color", Color(0.75, 0.60, 1.0))
	_triggers_vbox.add_child(trigger_hdr)
	_triggers_vbox.add_child(HSeparator.new())

	for t: int in TRIGGER_ORDER:
		var lvl: int = inst.get_fire_count(t)
		var cost: int = inst.get_upgrade_cost(t)

		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 12)
		_triggers_vbox.add_child(row)

		var info := VBoxContainer.new()
		info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		info.add_theme_constant_override("separation", 2)
		row.add_child(info)

		var name_lbl := Label.new()
		name_lbl.text = SpellTrigger.display_name(t)
		name_lbl.add_theme_font_size_override("font_size", 14)
		info.add_child(name_lbl)

		var desc_lbl := Label.new()
		if lvl == 0:
			desc_lbl.text = "Not purchased"
		else:
			desc_lbl.text = "Lv.%d  —  fires %d× per trigger" % [lvl, lvl]
		desc_lbl.add_theme_font_size_override("font_size", 11)
		desc_lbl.add_theme_color_override("font_color", Color(0.55, 0.45, 0.75))
		info.add_child(desc_lbl)

		var btn := Button.new()
		btn.text = "Buy\n%dg" % cost
		btn.custom_minimum_size = Vector2(72, 52)
		btn.disabled = _gold < cost
		btn.pressed.connect(_on_trigger_buy.bind(t))
		row.add_child(btn)

		_triggers_vbox.add_child(HSeparator.new())

	_triggers_vbox.add_child(_make_trigger_divest_row(inst))


func _on_trigger_buy(trigger: int) -> void:
	trigger_bought.emit(trigger)


func _build_coin_sage_invest_row() -> void:
	var lvl: int = _target_card.mage_effect_level
	var cost: int = 4 + lvl  # death knell base (4) + current level

	var hdr := Label.new()
	hdr.text = "Invest Gold"
	hdr.add_theme_font_size_override("font_size", 14)
	hdr.add_theme_color_override("font_color", Color(0.75, 0.60, 1.0))
	_triggers_vbox.add_child(hdr)
	_triggers_vbox.add_child(HSeparator.new())

	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 12)
	_triggers_vbox.add_child(row)

	var info := VBoxContainer.new()
	info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	info.add_theme_constant_override("separation", 2)
	row.add_child(info)

	var name_lbl := Label.new()
	name_lbl.text = "Death Knell Gold"
	name_lbl.add_theme_font_size_override("font_size", 14)
	info.add_child(name_lbl)

	var desc_lbl := Label.new()
	desc_lbl.text = "Lv.%d  —  yields %d gold on death" % [lvl, lvl]
	desc_lbl.add_theme_font_size_override("font_size", 11)
	desc_lbl.add_theme_color_override("font_color", Color(0.55, 0.45, 0.75))
	info.add_child(desc_lbl)

	var btn := Button.new()
	btn.text = "Invest\n%dg" % cost
	btn.custom_minimum_size = Vector2(72, 52)
	btn.disabled = _gold < cost
	btn.pressed.connect(_on_mage_effect_buy)
	row.add_child(btn)

	_triggers_vbox.add_child(HSeparator.new())
	_triggers_vbox.add_child(_make_effect_divest_row())


func _on_mage_effect_buy() -> void:
	mage_effect_upgraded.emit()


func _make_trigger_divest_row(inst: SpellInstance) -> HBoxContainer:
	var refund := floori(inst.gold_invested * 0.75)
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 12)

	var name_lbl := Label.new()
	name_lbl.text = "Divest Triggers"
	name_lbl.add_theme_font_size_override("font_size", 14)
	name_lbl.add_theme_color_override("font_color", Color(1.0, 0.45, 0.25))
	name_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(name_lbl)

	var btn := Button.new()
	btn.text = "Divest\n+%dg" % refund
	btn.custom_minimum_size = Vector2(72, 52)
	btn.disabled = inst.gold_invested == 0
	btn.tooltip_text = "Invested: %dg  →  Refund: %dg (75%%)\nResets all trigger levels to 0." % [inst.gold_invested, refund]
	btn.pressed.connect(func(): triggers_divested.emit())
	row.add_child(btn)
	return row


func _make_effect_divest_row() -> HBoxContainer:
	var invested := _target_card.mage_invested_gold if is_instance_valid(_target_card) else 0
	var refund := floori(invested * 0.75)
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 12)

	var name_lbl := Label.new()
	name_lbl.text = "Divest Investments"
	name_lbl.add_theme_font_size_override("font_size", 14)
	name_lbl.add_theme_color_override("font_color", Color(1.0, 0.45, 0.25))
	name_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(name_lbl)

	var btn := Button.new()
	btn.text = "Divest\n+%dg" % refund
	btn.custom_minimum_size = Vector2(72, 52)
	btn.disabled = invested == 0
	btn.tooltip_text = "Invested: %dg  →  Refund: %dg (75%%)\nResets to Lv.1." % [invested, refund]
	btn.pressed.connect(func(): mage_effect_divested.emit())
	row.add_child(btn)
	return row
