class_name ContractScreen
extends Control

# Overlay for the Contract Board (pick 1 of 3 contracts, or skip) and the
# relic pick that some contracts reward. Replaces the old map screen.

signal offer_chosen(index: int)      # -1 = skipped
signal relic_selected(relic_id: String)

var _board_panel: VBoxContainer
var _board_cards: HBoxContainer
var _board_sub: Label
var _relic_panel: VBoxContainer
var _relic_cards: HBoxContainer


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	var bg := ColorRect.new()
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	bg.color = Color(0.05, 0.05, 0.08, 1.0 if Platform.is_mobile() else 0.96)
	add_child(bg)
	_build_board_panel()
	_build_relic_panel()
	Platform.adapt_overlay(self)
	visible = false


# ── Public API ────────────────────────────────────────────────────────────────

func show_offers(offers: Array, active_count: int, max_active: int) -> void:
	for child in _board_cards.get_children():
		child.queue_free()
	for i in range(offers.size()):
		_board_cards.add_child(_make_offer_card(offers[i], i))
	_board_sub.text = "Take one, or skip. Active contracts: %d / %d" % [active_count, max_active]
	_show("board")


func show_relic_selection(relics: Array) -> void:
	for child in _relic_cards.get_children():
		child.queue_free()
	for relic: Dictionary in relics:
		_relic_cards.add_child(_make_relic_button(relic))
	_show("relic")


func _show(which: String) -> void:
	_board_panel.visible = which == "board"
	_relic_panel.visible = which == "relic"
	visible = true


# ── Contract Board ────────────────────────────────────────────────────────────

func _build_board_panel() -> void:
	_board_panel = VBoxContainer.new()
	_board_panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_board_panel.add_theme_constant_override("separation", 14)
	add_child(_board_panel)

	var title := Label.new()
	title.text = "Contract Board"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 26)
	title.custom_minimum_size = Vector2(0, 56)
	_board_panel.add_child(title)

	_board_sub = Label.new()
	_board_sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_board_sub.add_theme_font_size_override("font_size", 13)
	_board_sub.add_theme_color_override("font_color", Color(0.7, 0.7, 0.75))
	_board_panel.add_child(_board_sub)

	var top_spacer := Control.new()
	top_spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_board_panel.add_child(top_spacer)

	_board_cards = HBoxContainer.new()
	_board_cards.set_meta("mobile_stack", true)
	_board_cards.alignment = BoxContainer.ALIGNMENT_CENTER
	_board_cards.add_theme_constant_override("separation", 18)
	_board_panel.add_child(_board_cards)

	var bottom_spacer := Control.new()
	bottom_spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_board_panel.add_child(bottom_spacer)

	var skip := Button.new()
	skip.text = "Skip"
	skip.custom_minimum_size = Vector2(160, 44)
	skip.pressed.connect(func():
		visible = false
		offer_chosen.emit(-1))
	var skip_row := CenterContainer.new()
	skip_row.custom_minimum_size = Vector2(0, 64)
	skip_row.add_child(skip)
	_board_panel.add_child(skip_row)


func _make_offer_card(c: Dictionary, index: int) -> Button:
	var col: Color = ContractSystem.TIER_COLORS.get(c.get("tier", "small"), Color.WHITE)
	var btn := Button.new()
	btn.custom_minimum_size = Vector2(230, 210)

	var normal := StyleBoxFlat.new()
	normal.bg_color = Color(col.r * 0.12, col.g * 0.12, col.b * 0.12)
	normal.border_color = Color(col.r * 0.6, col.g * 0.6, col.b * 0.6)
	normal.set_border_width_all(2)
	normal.set_corner_radius_all(8)
	var hover := normal.duplicate() as StyleBoxFlat
	hover.bg_color = Color(col.r * 0.22, col.g * 0.22, col.b * 0.22)
	hover.border_color = col
	btn.add_theme_stylebox_override("normal", normal)
	btn.add_theme_stylebox_override("hover", hover)
	btn.add_theme_stylebox_override("pressed", hover)
	btn.add_theme_stylebox_override("focus", hover)

	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	margin.mouse_filter = Control.MOUSE_FILTER_IGNORE
	for side in ["left", "right", "top", "bottom"]:
		margin.add_theme_constant_override("margin_" + side, 12)
	btn.add_child(margin)

	var vb := VBoxContainer.new()
	vb.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vb.add_theme_constant_override("separation", 6)
	margin.add_child(vb)

	vb.add_child(_label(ContractSystem.kind_label(c), 10, col))
	vb.add_child(_label(ContractSystem.title(c), 17, Color(0.95, 0.95, 0.95)))
	var goal := _label(ContractSystem.goal_text(c), 12, Color(0.82, 0.82, 0.85))
	goal.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	goal.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vb.add_child(goal)
	vb.add_child(_label(ContractSystem.deadline_text(c), 11, Color(0.65, 0.65, 0.7)))
	var reward := _label("Reward: " + ContractSystem.reward_text(c), 12, Color(1.0, 0.85, 0.35))
	reward.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	vb.add_child(reward)

	btn.pressed.connect(func():
		visible = false
		offer_chosen.emit(index))
	return btn


func _label(text: String, size: int, color: Color) -> Label:
	var l := Label.new()
	l.text = text
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	l.add_theme_font_size_override("font_size", size)
	l.add_theme_color_override("font_color", color)
	return l


# ── Relic pick ────────────────────────────────────────────────────────────────

func _build_relic_panel() -> void:
	_relic_panel = VBoxContainer.new()
	_relic_panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_relic_panel.add_theme_constant_override("separation", 18)
	_relic_panel.visible = false
	add_child(_relic_panel)

	var title := Label.new()
	title.text = "Choose a Relic"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 26)
	title.custom_minimum_size = Vector2(0, 60)
	_relic_panel.add_child(title)

	var sub := Label.new()
	sub.text = "Contract complete. Choose a permanent bonus for the rest of your run."
	sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	sub.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	sub.add_theme_color_override("font_color", Color(0.78, 0.78, 0.78))
	sub.add_theme_font_size_override("font_size", 13)
	_relic_panel.add_child(sub)

	var spacer := Control.new()
	spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_relic_panel.add_child(spacer)

	_relic_cards = HBoxContainer.new()
	_relic_cards.set_meta("mobile_stack", true)
	_relic_cards.alignment = BoxContainer.ALIGNMENT_CENTER
	_relic_cards.add_theme_constant_override("separation", 22)
	_relic_panel.add_child(_relic_cards)

	var spacer2 := Control.new()
	spacer2.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_relic_panel.add_child(spacer2)


func _make_relic_button(relic: Dictionary) -> Button:
	var btn := Button.new()
	btn.custom_minimum_size = Vector2(210, 140)

	var vb := VBoxContainer.new()
	vb.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	vb.alignment = BoxContainer.ALIGNMENT_CENTER
	vb.mouse_filter = Control.MOUSE_FILTER_IGNORE
	btn.add_child(vb)

	vb.add_child(_label(relic.get("name", "?"), 16, relic.get("color", Color.WHITE)))
	var desc := _label(relic.get("desc", ""), 11, Color(0.8, 0.8, 0.8))
	desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	vb.add_child(desc)

	btn.pressed.connect(func():
		visible = false
		relic_selected.emit(relic.get("id", "")))
	return btn
