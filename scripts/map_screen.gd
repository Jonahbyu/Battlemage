class_name MapScreen
extends Control

# ── Signals ───────────────────────────────────────────────────────────────────
signal node_selected(node_data: Dictionary)
signal relic_selected(relic_id: String)
signal rest_completed(choice: String)
signal event_completed(gold_delta: int, hp_delta: int)

# ── Constants ─────────────────────────────────────────────────────────────────

# 12 regular rows (0-11) + boss (row 12). One row = one map pick per turn.
const MAP_ROW_COUNT := 12

# Each entry = list of possible 3-node configurations for that row.
# One config is randomly chosen when the map is generated.
const ROW_TEMPLATES: Array = [
	# Row 0 (gentle — player just finished first fight)
	[["combat", "rest", "event"], ["rest", "combat", "combat"]],
	# Row 1
	[["combat", "event", "combat"], ["combat", "rest", "combat_hard"]],
	# Row 2
	[["combat_hard", "combat", "rest"], ["combat", "event", "combat_hard"]],
	# Row 3
	[["combat", "combat_hard", "event"], ["rest", "combat_hard", "combat"]],
	# Row 4
	[["combat_hard", "rest", "combat"], ["event", "combat", "combat_hard"]],
	# Row 5 (first elite available)
	[["elite", "combat_hard", "rest"], ["combat_hard", "elite", "event"]],
	# Row 6
	[["combat_hard", "event", "rest"], ["rest", "combat_hard", "event"]],
	# Row 7
	[["elite", "rest", "combat_hard"], ["combat_hard", "elite", "rest"]],
	# Row 8
	[["combat_hard", "event", "combat_hard"], ["elite", "rest", "combat_hard"]],
	# Row 9
	[["elite", "combat_hard", "rest"], ["combat_hard", "event", "elite"]],
	# Row 10
	[["combat_hard", "elite", "event"], ["rest", "elite", "combat_hard"]],
	# Row 11 (pre-boss, high stakes)
	[["elite", "rest", "elite"], ["combat_hard", "elite", "combat_hard"]],
	# Row 12 (boss — always single node)
	[["boss"]],
]

const NODE_INFO: Dictionary = {
	"combat": {
		"label": "Combat",
		"color": Color(0.5, 0.7, 1.0),
		"desc": "A standard enemy force. Expect a balanced board.",
		"sub": "Standard",
		"difficulty": 1.0,
	},
	"combat_hard": {
		"label": "Hard Combat",
		"color": Color(1.0, 0.45, 0.35),
		"desc": "A reinforced enemy force. Higher stats and tougher synergies.",
		"sub": "Reinforced",
		"difficulty": 1.35,
	},
	"elite": {
		"label": "Elite",
		"color": Color(1.0, 0.82, 0.1),
		"desc": "A champion and their warband. A brutal fight — but worth it.",
		"sub": "Champion",
		"difficulty": 1.75,
	},
	"rest": {
		"label": "Rest Site",
		"color": Color(0.45, 1.0, 0.6),
		"desc": "Recover. Restore 15 HP or fortify one of your units.",
		"sub": "No fight",
		"difficulty": 0.0,
	},
	"event": {
		"label": "Event",
		"color": Color(0.95, 0.9, 0.35),
		"desc": "An unexpected encounter. What happens here is unknown.",
		"sub": "Unknown",
		"difficulty": 0.0,
	},
	"boss": {
		"label": "BOSS",
		"color": Color(1.0, 0.2, 0.2),
		"desc": "The final battle. Defeat the boss to complete your run.",
		"sub": "Final Battle",
		"difficulty": 2.2,
	},
}

const RELICS: Array = [
	{
		"id": "gold_bonus",
		"name": "Coin Purse",
		"desc": "Earn +4 gold after each combat victory.",
		"color": Color(1.0, 0.85, 0.2),
	},
	{
		"id": "hp_restore",
		"name": "Iron Rations",
		"desc": "Restore 8 HP after each battle won.",
		"color": Color(0.4, 1.0, 0.55),
	},
	{
		"id": "atk_aura",
		"name": "War Banner",
		"desc": "Your units start each combat with +2 ATK.",
		"color": Color(1.0, 0.5, 0.3),
	},
	{
		"id": "hp_aura",
		"name": "Ancestral Shield",
		"desc": "Your units start each combat with +10 max HP.",
		"color": Color(0.4, 0.65, 1.0),
	},
	{
		"id": "income_boost",
		"name": "Midas Touch",
		"desc": "Your gold income grows 1 extra unit per round.",
		"color": Color(1.0, 0.9, 0.15),
	},
	{
		"id": "extra_reroll",
		"name": "Lucky Clover",
		"desc": "+1 extra reroll on all discovery screens.",
		"color": Color(0.3, 1.0, 0.45),
	},
	{
		"id": "double_interest",
		"name": "Banker's Ledger",
		"desc": "Earn interest twice each round instead of once.",
		"color": Color(0.85, 0.7, 0.3),
	},
	{
		"id": "battle_hardened",
		"name": "Whetstone",
		"desc": "Winning 3 combats in a row permanently gives all board units +1 ATK.",
		"color": Color(0.7, 0.7, 0.8),
	},
]

const EVENTS: Array = [
	{
		"title": "Ancient Cache",
		"desc": "You discover a hidden stash of gold buried in the ruins.",
		"options": [
			{"label": "Take the gold  (+8 gold)", "gold": 8, "hp": 0},
		],
	},
	{
		"title": "Wandering Medic",
		"desc": "A travelling healer offers to patch your wounds.",
		"options": [
			{"label": "Accept treatment  (+8 HP)", "gold": 0, "hp": 8},
		],
	},
	{
		"title": "Cursed Merchant",
		"desc": "A shadowy merchant sells forbidden wares at a steep price.",
		"options": [
			{"label": "Buy his wares  (-6 HP,  +10 gold)", "gold": 10, "hp": -6},
			{"label": "Walk away", "gold": 0, "hp": 0},
		],
	},
	{
		"title": "Battlefield Shrine",
		"desc": "An ancient shrine hums with power. It demands a sacrifice.",
		"options": [
			{"label": "Offer gold  (-10 gold,  +12 HP)", "gold": -10, "hp": 12},
			{"label": "Leave it alone", "gold": 0, "hp": 0},
		],
	},
	{
		"title": "Scavenger's Find",
		"desc": "You come across the aftermath of a battle. Spoils are scattered.",
		"options": [
			{"label": "Search thoroughly  (+8 gold,  -4 HP risk)", "gold": 8, "hp": -4},
			{"label": "Take only the obvious  (+4 gold)", "gold": 4, "hp": 0},
		],
	},
	{
		"title": "Mysterious Benefactor",
		"desc": "A cloaked stranger offers a choice of gifts.",
		"options": [
			{"label": "Take the coin  (+10 gold)", "gold": 10, "hp": 0},
			{"label": "Take the remedy  (+10 HP)", "gold": 0, "hp": 10},
		],
	},
	{
		"title": "Ambush!",
		"desc": "Bandits strike without warning. You fend them off but pay a price.",
		"options": [
			{"label": "Fight back  (-8 HP,  +6 gold loot)", "gold": 6, "hp": -8},
			{"label": "Pay them off  (-8 gold)", "gold": -8, "hp": 0},
		],
	},
	{
		"title": "Field Hospital",
		"desc": "A makeshift camp offers basic medical aid in exchange for supplies.",
		"options": [
			{"label": "Trade supplies  (-5 gold,  +12 HP)", "gold": -5, "hp": 12},
			{"label": "Move on", "gold": 0, "hp": 0},
		],
	},
]

# ── State ─────────────────────────────────────────────────────────────────────
var _map_data: Dictionary = {}
var _current_row: int = 0
var _selected_node: Dictionary = {}
var _current_row_buttons: Array = []  # [{button, data}]
var _event_data: Dictionary = {}

# ── Panels ────────────────────────────────────────────────────────────────────
var _map_panel: Control
var _relic_panel: Control
var _rest_panel: Control
var _event_panel: Control

# Map panel refs
var _scroll: ScrollContainer
var _map_grid: VBoxContainer
var _info_label: Label
var _confirm_btn: Button
var _subtitle_label: Label

# Rest panel refs
var _rest_heal_btn: Button
var _rest_fortify_btn: Button
var _rest_fortify_label: Label


# ── Lifecycle ─────────────────────────────────────────────────────────────────

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_build_background()
	_build_map_panel()
	_build_relic_panel()
	_build_rest_panel()
	_build_event_panel()
	visible = false


# ── Map generation ─────────────────────────────────────────────────────────────

func generate_map(seed_val: int) -> Dictionary:
	seed(seed_val)
	var nodes: Array = []
	var id_counter := 0
	for row_idx: int in range(ROW_TEMPLATES.size()):
		var options: Array = ROW_TEMPLATES[row_idx]
		var chosen: Array = options[randi() % options.size()]
		for col_idx: int in range(chosen.size()):
			nodes.append({
				"id": id_counter,
				"row": row_idx,
				"col": col_idx,
				"type": chosen[col_idx],
			})
			id_counter += 1
	return {"nodes": nodes, "seed": seed_val}


# ── Public API ────────────────────────────────────────────────────────────────

func show_map(map_data: Dictionary, current_row: int) -> void:
	_map_data = map_data
	_current_row = current_row
	_selected_node = {}
	_show_panel("map")
	_rebuild_map_grid()
	_update_info("Select an encounter for this turn.")
	_confirm_btn.text = "Enter Encounter"
	_confirm_btn.disabled = true
	if current_row < MAP_ROW_COUNT:
		_subtitle_label.text = "Turn  %d / %d" % [current_row + 1, MAP_ROW_COUNT + 1]
	else:
		_subtitle_label.text = "Final Battle"
	# Auto-scroll to current row (top of current section)
	call_deferred("_scroll_to_current")


func show_relic_selection(available_relics: Array) -> void:
	_show_panel("relic")
	_build_relic_ui(available_relics)


func show_rest(player_hp: int, max_hp: int) -> void:
	_show_panel("rest")
	_rest_heal_btn.text = "Rest  (+15 HP)"
	_rest_heal_btn.disabled = player_hp >= max_hp
	_rest_fortify_label.text = "Fortify one of your bench units (+2 ATK, +4 HP permanently)."


func show_event() -> void:
	var idx := randi() % EVENTS.size()
	_event_data = EVENTS[idx]
	_show_panel("event")
	_build_event_ui()


# ── Panel management ──────────────────────────────────────────────────────────

func _show_panel(name: String) -> void:
	_map_panel.visible   = name == "map"
	_relic_panel.visible = name == "relic"
	_rest_panel.visible  = name == "rest"
	_event_panel.visible = name == "event"
	visible = true


# ── Background ────────────────────────────────────────────────────────────────

func _build_background() -> void:
	var bg := ColorRect.new()
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	bg.color = Color(0.05, 0.05, 0.08, 0.96)
	add_child(bg)


# ── Map panel ─────────────────────────────────────────────────────────────────

func _build_map_panel() -> void:
	_map_panel = VBoxContainer.new()
	_map_panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_map_panel.add_theme_constant_override("separation", 4)
	add_child(_map_panel)

	var title := Label.new()
	title.text = "Choose Your Path"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 24)
	title.custom_minimum_size = Vector2(0, 40)
	_map_panel.add_child(title)

	_subtitle_label = Label.new()
	_subtitle_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_subtitle_label.add_theme_font_size_override("font_size", 13)
	_subtitle_label.add_theme_color_override("font_color", Color(0.65, 0.65, 0.65))
	_map_panel.add_child(_subtitle_label)

	_scroll = ScrollContainer.new()
	_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	_map_panel.add_child(_scroll)

	_map_grid = VBoxContainer.new()
	_map_grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_map_grid.add_theme_constant_override("separation", 6)
	_scroll.add_child(_map_grid)

	_map_panel.add_child(HSeparator.new())

	_info_label = Label.new()
	_info_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_info_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_info_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_info_label.custom_minimum_size = Vector2(0, 50)
	_info_label.add_theme_font_size_override("font_size", 13)
	_map_panel.add_child(_info_label)

	_confirm_btn = Button.new()
	_confirm_btn.text = "Enter Encounter"
	_confirm_btn.custom_minimum_size = Vector2(220, 46)
	_confirm_btn.disabled = true
	_confirm_btn.pressed.connect(_on_confirm_pressed)
	var btn_row := CenterContainer.new()
	btn_row.custom_minimum_size = Vector2(0, 56)
	btn_row.add_child(_confirm_btn)
	_map_panel.add_child(btn_row)


const NODE_ICONS: Dictionary = {
	"combat":      "⚔",
	"combat_hard": "⚔⚔",
	"elite":       "★",
	"rest":        "♥",
	"event":       "?",
	"boss":        "☠",
}


func _make_row_style(is_current: bool, is_past: bool, is_boss: bool) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.corner_radius_top_left    = 5
	s.corner_radius_top_right   = 5
	s.corner_radius_bottom_left = 5
	s.corner_radius_bottom_right = 5
	s.content_margin_left   = 8
	s.content_margin_right  = 8
	s.content_margin_top    = 6
	s.content_margin_bottom = 6
	if is_boss:
		s.bg_color     = Color(0.18, 0.06, 0.06)
		s.border_color = Color(0.9, 0.25, 0.25)
		s.set_border_width_all(2)
	elif is_current:
		s.bg_color     = Color(0.13, 0.13, 0.20)
		s.border_color = Color(1.0, 0.88, 0.3)
		s.set_border_width_all(2)
	elif is_past:
		s.bg_color     = Color(0.06, 0.06, 0.07)
		s.border_color = Color(0.18, 0.18, 0.18)
		s.set_border_width_all(1)
	else:
		s.bg_color     = Color(0.09, 0.09, 0.13)
		s.border_color = Color(0.22, 0.22, 0.28)
		s.set_border_width_all(1)
	return s


func _make_node_style(base_col: Color, is_current: bool, is_past: bool, selected: bool = false) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.corner_radius_top_left    = 5
	s.corner_radius_top_right   = 5
	s.corner_radius_bottom_left = 5
	s.corner_radius_bottom_right = 5
	s.content_margin_left   = 6
	s.content_margin_right  = 6
	s.content_margin_top    = 4
	s.content_margin_bottom = 4
	if is_past:
		s.bg_color     = Color(0.10, 0.10, 0.12)
		s.border_color = Color(0.20, 0.20, 0.20)
		s.set_border_width_all(1)
	elif selected:
		s.bg_color     = Color(base_col.r * 0.42, base_col.g * 0.42, base_col.b * 0.42)
		s.border_color = base_col.lightened(0.15)
		s.set_border_width_all(3)
	elif is_current:
		s.bg_color     = Color(base_col.r * 0.22, base_col.g * 0.22, base_col.b * 0.22)
		s.border_color = Color(base_col.r * 0.65, base_col.g * 0.65, base_col.b * 0.65)
		s.set_border_width_all(1)
	else:
		s.bg_color     = Color(base_col.r * 0.09, base_col.g * 0.09, base_col.b * 0.09)
		s.border_color = Color(base_col.r * 0.30, base_col.g * 0.30, base_col.b * 0.30)
		s.set_border_width_all(1)
	return s


func _rebuild_map_grid() -> void:
	for child in _map_grid.get_children():
		child.queue_free()
	_current_row_buttons.clear()

	var nodes: Array = _map_data.get("nodes", [])
	var max_row := 0
	for n: Dictionary in nodes:
		if n.row > max_row:
			max_row = n.row

	# Boss at top, row 0 at bottom
	for row_idx: int in range(max_row, -1, -1):
		var row_nodes: Array = nodes.filter(func(n: Dictionary) -> bool: return n.row == row_idx)
		if row_nodes.is_empty():
			continue

		var is_current := row_idx == _current_row
		var is_past    := row_idx < _current_row
		var is_boss    := row_idx == max_row

		# Styled panel wrapping each row
		var row_panel := PanelContainer.new()
		row_panel.add_theme_stylebox_override("panel", _make_row_style(is_current, is_past, is_boss))
		_map_grid.add_child(row_panel)

		var row_vbox := VBoxContainer.new()
		row_vbox.add_theme_constant_override("separation", 5)
		row_panel.add_child(row_vbox)

		# Header row
		var header := HBoxContainer.new()
		header.add_theme_constant_override("separation", 6)
		row_vbox.add_child(header)

		var num_lbl := Label.new()
		num_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		num_lbl.add_theme_font_size_override("font_size", 11)
		if is_boss:
			num_lbl.text = "☠  FINAL BOSS"
			num_lbl.add_theme_color_override("font_color", Color(1.0, 0.35, 0.35))
		elif is_current:
			num_lbl.text = "▶  Turn %d" % (row_idx + 1)
			num_lbl.add_theme_color_override("font_color", Color(1.0, 0.92, 0.45))
		elif is_past:
			num_lbl.text = "✓  Turn %d" % (row_idx + 1)
			num_lbl.add_theme_color_override("font_color", Color(0.32, 0.52, 0.32))
		else:
			num_lbl.text = "   Turn %d" % (row_idx + 1)
			num_lbl.add_theme_color_override("font_color", Color(0.42, 0.42, 0.48))
		header.add_child(num_lbl)

		if is_current and not is_boss:
			var hint := Label.new()
			hint.text = "Choose ↓"
			hint.add_theme_font_size_override("font_size", 10)
			hint.add_theme_color_override("font_color", Color(0.85, 0.75, 0.3))
			header.add_child(hint)

		# Node buttons
		var hbox := HBoxContainer.new()
		hbox.alignment = BoxContainer.ALIGNMENT_CENTER
		hbox.add_theme_constant_override("separation", 10)
		row_vbox.add_child(hbox)

		for nd: Dictionary in row_nodes:
			var btn := _make_node_button(nd, is_current, is_past)
			hbox.add_child(btn)
			if is_current:
				_current_row_buttons.append({"button": btn, "data": nd})


func _make_node_button(nd: Dictionary, is_current: bool, is_past: bool) -> Button:
	var info: Dictionary = NODE_INFO.get(nd.type, NODE_INFO["combat"])
	var base_col: Color = info.color
	var w := 185 if nd.type == "boss" else 148
	var btn := Button.new()
	btn.custom_minimum_size = Vector2(w, 66)

	var normal_style := _make_node_style(base_col, is_current, is_past)
	btn.add_theme_stylebox_override("normal",   normal_style)
	btn.add_theme_stylebox_override("disabled", normal_style)
	if is_current:
		var hover_style := _make_node_style(base_col, true, false)
		hover_style.bg_color     = Color(base_col.r * 0.30, base_col.g * 0.30, base_col.b * 0.30)
		hover_style.border_color = base_col
		hover_style.set_border_width_all(2)
		btn.add_theme_stylebox_override("hover",    hover_style)
		btn.add_theme_stylebox_override("pressed",  hover_style)
	else:
		btn.add_theme_stylebox_override("hover",   normal_style)
		btn.add_theme_stylebox_override("pressed", normal_style)

	var inner := VBoxContainer.new()
	inner.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	inner.add_theme_constant_override("separation", 2)
	inner.alignment = BoxContainer.ALIGNMENT_CENTER
	btn.add_child(inner)

	var icon: String = NODE_ICONS.get(nd.type, "")
	var name_lbl := Label.new()
	name_lbl.text = ("%s  %s" % [icon, info.label]) if icon != "" else info.label
	name_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_lbl.add_theme_font_size_override("font_size", 13)
	name_lbl.add_theme_color_override("font_color",
		Color(0.30, 0.30, 0.30) if is_past else info.color)
	inner.add_child(name_lbl)

	var sub_lbl := Label.new()
	sub_lbl.text = info.get("sub", "")
	sub_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	sub_lbl.add_theme_font_size_override("font_size", 9)
	var sub_color: Color
	if is_past:
		sub_color = Color(0.24, 0.24, 0.24)
	elif nd.type == "elite":
		sub_color = Color(1.0, 0.75, 0.15)
	elif nd.type == "boss":
		sub_color = Color(1.0, 0.4, 0.4)
	else:
		sub_color = Color(0.52, 0.52, 0.58)
	sub_lbl.add_theme_color_override("font_color", sub_color)
	inner.add_child(sub_lbl)

	if is_past:
		btn.disabled = true
	elif not is_current:
		btn.disabled = true
		btn.modulate = Color(1, 1, 1, 0.5)
	else:
		btn.pressed.connect(_on_node_btn_pressed.bind(nd))
		btn.mouse_entered.connect(_on_node_btn_hover.bind(info))

	return btn


func _on_node_btn_pressed(nd: Dictionary) -> void:
	_selected_node = nd
	_confirm_btn.disabled = false
	var info: Dictionary = NODE_INFO.get(nd.type, NODE_INFO["combat"])
	# Re-style all current row buttons: selected = bright, others = dim
	for entry: Dictionary in _current_row_buttons:
		var b: Button = entry.button
		var b_info: Dictionary = NODE_INFO.get(entry.data.type, NODE_INFO["combat"])
		var sel: bool = entry.data.id == nd.id
		var new_style := _make_node_style(b_info.color, true, false, sel)
		b.add_theme_stylebox_override("normal", new_style)
		b.add_theme_stylebox_override("hover",  new_style)
		if not sel:
			b.modulate = Color(1, 1, 1, 0.6)
		else:
			b.modulate = Color(1, 1, 1, 1)
	_confirm_btn.text = "Enter  %s" % info.label
	_update_info(info.get("desc", ""))


func _on_node_btn_hover(info: Dictionary) -> void:
	if _selected_node.is_empty():
		_update_info(info.get("desc", ""))


func _on_confirm_pressed() -> void:
	if _selected_node.is_empty():
		return
	visible = false
	node_selected.emit(_selected_node)


func _update_info(text: String) -> void:
	if is_instance_valid(_info_label):
		_info_label.text = text


func _scroll_to_current() -> void:
	if not is_instance_valid(_scroll) or not is_instance_valid(_map_grid):
		return
	# Find the approximate Y of the current row in the grid
	# The grid displays rows top-to-bottom (boss first, row 0 last)
	# current row is at index: (max_row - current_row) in display order
	var nodes: Array = _map_data.get("nodes", [])
	var max_row := 0
	for n: Dictionary in nodes:
		if n.row > max_row:
			max_row = n.row
	var display_index := max_row - _current_row  # 0 = top (boss)
	# Each row panel ≈ 100px (header + buttons + padding + separation)
	var approx_y := display_index * 100
	_scroll.scroll_vertical = maxi(0, approx_y - 60)


# ── Relic panel ───────────────────────────────────────────────────────────────

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
	sub.text = "You defeated the champion. Choose a permanent bonus for the rest of your run."
	sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	sub.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	sub.add_theme_color_override("font_color", Color(0.78, 0.78, 0.78))
	sub.add_theme_font_size_override("font_size", 13)
	_relic_panel.add_child(sub)

	var spacer := Control.new()
	spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_relic_panel.add_child(spacer)

	# Relic buttons inserted by _build_relic_ui


func _build_relic_ui(available_relics: Array) -> void:
	# Remove previously added relic hbox (anything after index 3)
	var children := _relic_panel.get_children()
	while children.size() > 3:
		children.back().queue_free()
		children = _relic_panel.get_children()

	var hbox := HBoxContainer.new()
	hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	hbox.add_theme_constant_override("separation", 22)
	_relic_panel.add_child(hbox)

	for relic: Dictionary in available_relics:
		hbox.add_child(_make_relic_button(relic))

	var spacer2 := Control.new()
	spacer2.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_relic_panel.add_child(spacer2)


func _make_relic_button(relic: Dictionary) -> Button:
	var btn := Button.new()
	btn.custom_minimum_size = Vector2(210, 140)

	var vb := VBoxContainer.new()
	vb.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	vb.alignment = BoxContainer.ALIGNMENT_CENTER
	btn.add_child(vb)

	var name_lbl := Label.new()
	name_lbl.text = relic.get("name", "?")
	name_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_lbl.add_theme_font_size_override("font_size", 16)
	name_lbl.add_theme_color_override("font_color", relic.get("color", Color.WHITE))
	vb.add_child(name_lbl)

	var sep := Control.new()
	sep.custom_minimum_size = Vector2(0, 6)
	vb.add_child(sep)

	var desc_lbl := Label.new()
	desc_lbl.text = relic.get("desc", "")
	desc_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	desc_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	desc_lbl.add_theme_font_size_override("font_size", 11)
	desc_lbl.add_theme_color_override("font_color", Color(0.8, 0.8, 0.8))
	vb.add_child(desc_lbl)

	btn.pressed.connect(func():
		visible = false
		relic_selected.emit(relic.get("id", ""))
	)
	return btn


# ── Rest panel ────────────────────────────────────────────────────────────────

func _build_rest_panel() -> void:
	_rest_panel = VBoxContainer.new()
	_rest_panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_rest_panel.add_theme_constant_override("separation", 22)
	_rest_panel.visible = false
	add_child(_rest_panel)

	var title := Label.new()
	title.text = "Rest Site"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 28)
	title.custom_minimum_size = Vector2(0, 64)
	_rest_panel.add_child(title)

	var desc := Label.new()
	desc.text = "You find a place to rest your forces."
	desc.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	desc.add_theme_color_override("font_color", Color(0.78, 0.78, 0.78))
	desc.add_theme_font_size_override("font_size", 14)
	_rest_panel.add_child(desc)

	var spacer := Control.new()
	spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_rest_panel.add_child(spacer)

	var hbox := HBoxContainer.new()
	hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	hbox.add_theme_constant_override("separation", 30)
	_rest_panel.add_child(hbox)

	_rest_heal_btn = Button.new()
	_rest_heal_btn.text = "Rest\n(+15 HP)"
	_rest_heal_btn.custom_minimum_size = Vector2(175, 85)
	_rest_heal_btn.add_theme_font_size_override("font_size", 14)
	_rest_heal_btn.pressed.connect(func():
		visible = false
		rest_completed.emit("heal")
	)
	hbox.add_child(_rest_heal_btn)

	var fortify_col := VBoxContainer.new()
	fortify_col.alignment = BoxContainer.ALIGNMENT_CENTER
	fortify_col.add_theme_constant_override("separation", 8)
	hbox.add_child(fortify_col)

	_rest_fortify_btn = Button.new()
	_rest_fortify_btn.text = "Fortify Unit\n(+2 ATK, +4 HP)"
	_rest_fortify_btn.custom_minimum_size = Vector2(175, 85)
	_rest_fortify_btn.add_theme_font_size_override("font_size", 14)
	_rest_fortify_btn.pressed.connect(func():
		visible = false
		rest_completed.emit("fortify")
	)
	fortify_col.add_child(_rest_fortify_btn)

	_rest_fortify_label = Label.new()
	_rest_fortify_label.text = ""
	_rest_fortify_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_rest_fortify_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_rest_fortify_label.add_theme_font_size_override("font_size", 11)
	_rest_fortify_label.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7))
	_rest_fortify_label.custom_minimum_size = Vector2(200, 0)
	fortify_col.add_child(_rest_fortify_label)

	var spacer2 := Control.new()
	spacer2.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_rest_panel.add_child(spacer2)


# ── Event panel ───────────────────────────────────────────────────────────────

func _build_event_panel() -> void:
	_event_panel = VBoxContainer.new()
	_event_panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_event_panel.add_theme_constant_override("separation", 20)
	_event_panel.visible = false
	add_child(_event_panel)


func _build_event_ui() -> void:
	for child in _event_panel.get_children():
		child.queue_free()

	var title := Label.new()
	title.text = _event_data.get("title", "Event")
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 26)
	title.custom_minimum_size = Vector2(0, 64)
	_event_panel.add_child(title)

	var desc := Label.new()
	desc.text = _event_data.get("desc", "")
	desc.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	desc.add_theme_color_override("font_color", Color(0.85, 0.85, 0.85))
	desc.add_theme_font_size_override("font_size", 15)
	desc.custom_minimum_size = Vector2(500, 0)
	_event_panel.add_child(desc)

	var spacer := Control.new()
	spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_event_panel.add_child(spacer)

	for opt: Dictionary in _event_data.get("options", []):
		var btn := Button.new()
		btn.text = opt.get("label", "?")
		btn.custom_minimum_size = Vector2(380, 58)
		btn.add_theme_font_size_override("font_size", 13)
		var gold: int = opt.get("gold", 0)
		var hp: int = opt.get("hp", 0)
		btn.pressed.connect(func():
			visible = false
			event_completed.emit(gold, hp)
		)
		var center := CenterContainer.new()
		center.add_child(btn)
		_event_panel.add_child(center)

	var spacer2 := Control.new()
	spacer2.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_event_panel.add_child(spacer2)
