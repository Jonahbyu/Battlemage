extends Control

# Rebuild the whole UI on enter so slot summaries are always fresh.
func _ready() -> void:
	_build_ui()


func _build_ui() -> void:
	for child in get_children():
		child.queue_free()

	# ── Background ──────────────────────────────────────────────────────────────
	var bg := ColorRect.new()
	bg.color = Color(0.07, 0.07, 0.10)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(bg)

	# ── Scroll container so slots fit on small screens ──────────────────────────
	var scroll := ScrollContainer.new()
	scroll.set_anchors_preset(Control.PRESET_FULL_RECT)
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	add_child(scroll)

	var center := VBoxContainer.new()
	center.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	center.add_theme_constant_override("separation", 8)
	scroll.add_child(center)

	var inner := VBoxContainer.new()
	inner.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	inner.add_theme_constant_override("separation", 8)
	var margin := MarginContainer.new()
	for s in ["margin_left","margin_right","margin_top","margin_bottom"]:
		margin.add_theme_constant_override(s, 32)
	margin.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	margin.add_child(inner)
	center.add_child(margin)

	# ── Title ───────────────────────────────────────────────────────────────────
	var title := Label.new()
	title.text = "BATTLEMAGE"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 56)
	title.add_theme_color_override("font_color", Color(1.0, 0.85, 0.30))
	inner.add_child(title)

	var sub := Label.new()
	sub.text = "Autobattler Roguelike"
	sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	sub.add_theme_color_override("font_color", Color(0.60, 0.60, 0.75))
	inner.add_child(sub)

	inner.add_child(_hsep())

	# ── Save slots ──────────────────────────────────────────────────────────────
	var slots_label := Label.new()
	slots_label.text = "SAVE SLOTS"
	slots_label.add_theme_font_size_override("font_size", 14)
	slots_label.add_theme_color_override("font_color", Color(0.55, 0.55, 0.65))
	inner.add_child(slots_label)

	for i in range(GameData.SLOT_COUNT):
		inner.add_child(_build_slot_row(i))

	inner.add_child(_hsep())

	# ── Gauntlet section ────────────────────────────────────────────────────────
	inner.add_child(_build_gauntlet_section())

	inner.add_child(_hsep())

	# ── Difficulty ──────────────────────────────────────────────────────────────
	inner.add_child(_build_difficulty_section())

	inner.add_child(_hsep())

	# ── History & Exit ──────────────────────────────────────────────────────────
	var bottom := HBoxContainer.new()
	bottom.alignment = BoxContainer.ALIGNMENT_CENTER
	bottom.add_theme_constant_override("separation", 16)
	inner.add_child(bottom)

	var hist_btn := Button.new()
	hist_btn.text = "Run History"
	hist_btn.custom_minimum_size = Vector2(180, 44)
	hist_btn.pressed.connect(_on_history_pressed)
	bottom.add_child(hist_btn)

	var manual_btn := Button.new()
	manual_btn.text = "Unit Manual"
	manual_btn.custom_minimum_size = Vector2(180, 44)
	manual_btn.pressed.connect(_on_manual_pressed)
	bottom.add_child(manual_btn)

	var exit_btn := Button.new()
	exit_btn.text = "Exit Game"
	exit_btn.custom_minimum_size = Vector2(180, 44)
	exit_btn.pressed.connect(_on_exit_pressed)
	bottom.add_child(exit_btn)


# ── Slot row ─────────────────────────────────────────────────────────────────

func _build_slot_row(idx: int) -> Control:
	var slot = GameData.get_slot(idx)
	var occupied: bool = slot != null and slot is Dictionary

	var panel := PanelContainer.new()
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.11, 0.11, 0.16, 1.0)
	style.set_corner_radius_all(6)
	style.set_border_width_all(1)
	style.border_color = Color(0.30, 0.30, 0.40)
	panel.add_theme_stylebox_override("panel", style)

	var hbox := HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 12)
	var margin := MarginContainer.new()
	for s in ["margin_left","margin_right","margin_top","margin_bottom"]:
		margin.add_theme_constant_override(s, 10)
	margin.add_child(hbox)
	panel.add_child(margin)

	# Slot number badge
	var badge := Label.new()
	badge.text = "SLOT\n%d" % (idx + 1)
	badge.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	badge.add_theme_color_override("font_color", Color(0.55, 0.55, 0.65))
	badge.add_theme_font_size_override("font_size", 12)
	badge.custom_minimum_size = Vector2(48, 0)
	hbox.add_child(badge)

	var vsep := VSeparator.new()
	hbox.add_child(vsep)

	# Info column
	var info := VBoxContainer.new()
	info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	info.add_theme_constant_override("separation", 4)
	hbox.add_child(info)

	if occupied:
		var round_num: int = int(slot.get("round", 0))
		var hp: int        = int(slot.get("player_hp", 100))
		var tier: int      = int(slot.get("tier", 1))

		var stats := Label.new()
		stats.text = "Battle %d / %d   ·   HP %d   ·   Tier %d" % [
			round_num, GameData.MAX_BATTLES, hp, tier]
		stats.add_theme_color_override("font_color", Color(0.85, 0.85, 0.90))
		stats.add_theme_font_size_override("font_size", 13)
		info.add_child(stats)

		var names: Array = slot.get("unit_names", [])
		if names.is_empty():
			var board_arr: Array = slot.get("board", [])
			for d in board_arr:
				var ud = load(d.get("path", ""))
				if ud != null:
					names.append(ud.display_name)

		var units_label := Label.new()
		units_label.text = "Board: " + (", ".join(names) if not names.is_empty() else "(empty)")
		units_label.add_theme_color_override("font_color", Color(0.65, 0.80, 0.65))
		units_label.add_theme_font_size_override("font_size", 12)
		units_label.autowrap_mode = TextServer.AUTOWRAP_WORD
		info.add_child(units_label)
	else:
		var empty_lbl := Label.new()
		empty_lbl.text = "Empty"
		empty_lbl.add_theme_color_override("font_color", Color(0.40, 0.40, 0.50))
		empty_lbl.add_theme_font_size_override("font_size", 14)
		info.add_child(empty_lbl)

	# Button column
	var btns := VBoxContainer.new()
	btns.add_theme_constant_override("separation", 4)
	hbox.add_child(btns)

	if occupied:
		var cont_btn := Button.new()
		cont_btn.text = "Continue"
		cont_btn.custom_minimum_size = Vector2(110, 36)
		cont_btn.pressed.connect(_on_continue_slot.bind(idx))
		btns.add_child(cont_btn)

		var clear_btn := Button.new()
		clear_btn.text = "Clear"
		clear_btn.custom_minimum_size = Vector2(110, 36)
		clear_btn.pressed.connect(_on_clear_slot.bind(idx))
		btns.add_child(clear_btn)
	else:
		var new_btn := Button.new()
		new_btn.text = "New Run"
		new_btn.custom_minimum_size = Vector2(110, 36)
		new_btn.pressed.connect(_on_new_slot.bind(idx))
		btns.add_child(new_btn)

	return panel


# ── Difficulty section ────────────────────────────────────────────────────────

const DIFFICULTY_MODIFIERS := [
	[],
	["Sell 4 units to earn a Discovery (was 3)"],
	["Sell 4 units to earn a Discovery", "Shop upgrades cost +1 gold"],
	["Sell 4 units to earn a Discovery", "Shop upgrades cost +1 gold", "Discovery rerolls reduced to 2"],
	["Sell 4 units to earn a Discovery", "Shop upgrades cost +1 gold", "Discovery rerolls reduced to 2", "Tier upgrades cost 20% more"],
	["Sell 4 units to earn a Discovery", "Shop upgrades cost +1 gold", "Discovery rerolls: 2", "Tier upgrades cost 20% more", "Discover 1 fewer unit per screen"],
	["Sell 4 units", "Shop upgrades +1 gold", "Discovery rerolls: 2", "Tier upgrades +20%", "Discover 1 fewer unit", "Start at 75 HP"],
	["Sell 4 units", "Shop upgrades +2 gold", "Discovery rerolls: 2", "Tier upgrades +20%", "Discover 1 fewer unit", "Start at 75 HP"],
	["Sell 4 units", "Shop upgrades +2 gold", "Discovery rerolls: 2", "Tier upgrades +20%", "Discover 2 fewer units", "Start at 75 HP"],
	["Sell 4 units", "Shop upgrades +2 gold", "Discovery rerolls: 2", "Tier upgrades +20%", "Discover 2 fewer units", "Start at 75 HP", "Enemies have +20% HP"],
	["Sell 4 units", "Shop upgrades +2 gold", "Discovery rerolls: 2", "Tier upgrades +20%", "Discover 2 fewer units", "Start at 75 HP", "Enemies have +20% HP", "Enemies deal +20% damage"],
]

func _build_difficulty_section() -> Control:
	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 8)

	var header := Label.new()
	header.text = "DIFFICULTY"
	header.add_theme_font_size_override("font_size", 14)
	header.add_theme_color_override("font_color", Color(0.55, 0.55, 0.65))
	vbox.add_child(header)

	var level := GameData.difficulty_level
	var max_lvl := GameData.max_unlocked_difficulty

	# Level selector row
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 10)
	vbox.add_child(row)

	var prev_btn := Button.new()
	prev_btn.text = "<"
	prev_btn.custom_minimum_size = Vector2(36, 36)
	prev_btn.disabled = level <= 0
	prev_btn.pressed.connect(func():
		GameData.set_difficulty(level - 1)
		_build_ui())
	row.add_child(prev_btn)

	var level_name := "Normal" if level == 0 else "Level %d" % level
	var level_lbl := Label.new()
	level_lbl.text = level_name
	level_lbl.custom_minimum_size = Vector2(100, 0)
	level_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	level_lbl.add_theme_font_size_override("font_size", 16)
	level_lbl.add_theme_color_override("font_color", Color(1.0, 0.85, 0.30) if level > 0 else Color(0.80, 0.85, 0.90))
	row.add_child(level_lbl)

	var next_btn := Button.new()
	next_btn.text = ">"
	next_btn.custom_minimum_size = Vector2(36, 36)
	next_btn.disabled = level >= max_lvl
	next_btn.pressed.connect(func():
		GameData.set_difficulty(level + 1)
		_build_ui())
	row.add_child(next_btn)

	# Active modifiers
	var mods: Array = DIFFICULTY_MODIFIERS[level]
	if mods.is_empty():
		var none_lbl := Label.new()
		none_lbl.text = "No modifiers active."
		none_lbl.add_theme_color_override("font_color", Color(0.45, 0.45, 0.55))
		none_lbl.add_theme_font_size_override("font_size", 12)
		vbox.add_child(none_lbl)
	else:
		for mod in mods:
			var mod_lbl := Label.new()
			mod_lbl.text = "  •  " + mod
			mod_lbl.add_theme_color_override("font_color", Color(0.90, 0.55, 0.30))
			mod_lbl.add_theme_font_size_override("font_size", 12)
			vbox.add_child(mod_lbl)

	# Unlock hint
	if level < GameData.MAX_DIFFICULTY:
		var hint_text := "Beat this run to unlock Level %d." % (level + 1) if level >= max_lvl else ""
		if not hint_text.is_empty():
			var hint_lbl := Label.new()
			hint_lbl.text = hint_text
			hint_lbl.add_theme_color_override("font_color", Color(0.45, 0.55, 0.65))
			hint_lbl.add_theme_font_size_override("font_size", 12)
			vbox.add_child(hint_lbl)

	return vbox


# ── Gauntlet section ──────────────────────────────────────────────────────────

func _build_gauntlet_section() -> Control:
	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 8)

	var header := Label.new()
	header.text = "GAUNTLET"
	header.add_theme_font_size_override("font_size", 14)
	header.add_theme_color_override("font_color", Color(0.55, 0.55, 0.65))
	vbox.add_child(header)

	if not GameData.has_gauntlet_data():
		var lbl := Label.new()
		lbl.text = "Complete a 25-battle run to unlock the Gauntlet."
		lbl.add_theme_color_override("font_color", Color(0.45, 0.45, 0.55))
		lbl.add_theme_font_size_override("font_size", 13)
		vbox.add_child(lbl)
		return vbox

	# Last winning board row
	var lw_slot = GameData._data["gauntlet"].get("last_winning_slot")
	var lw_names: Array = _names_from_slot(lw_slot)
	vbox.add_child(_build_gauntlet_board_row("Last Winning Run", lw_names))

	# Champion board row
	if GameData.has_champion():
		var champ_slot = GameData._data["gauntlet"].get("champion_slot")
		var champ_names: Array = _names_from_slot(champ_slot)
		vbox.add_child(_build_gauntlet_board_row("Champion", champ_names))
	else:
		var no_champ := Label.new()
		no_champ.text = "Champion: None yet — beat the Last Winning Run in the Gauntlet to set one."
		no_champ.add_theme_color_override("font_color", Color(0.50, 0.50, 0.60))
		no_champ.add_theme_font_size_override("font_size", 12)
		no_champ.autowrap_mode = TextServer.AUTOWRAP_WORD
		vbox.add_child(no_champ)

	var enter_btn := Button.new()
	enter_btn.text = "Enter Gauntlet  (use last winning board as challenger)"
	enter_btn.custom_minimum_size = Vector2(0, 44)
	enter_btn.add_theme_color_override("font_color", Color(1.0, 0.80, 0.20))
	enter_btn.pressed.connect(_on_gauntlet_pressed)
	vbox.add_child(enter_btn)

	return vbox


func _build_gauntlet_board_row(label_text: String, names: Array) -> Control:
	var hbox := HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 12)

	var lbl := Label.new()
	lbl.text = label_text + ":"
	lbl.custom_minimum_size = Vector2(180, 0)
	lbl.add_theme_color_override("font_color", Color(0.80, 0.80, 0.90))
	lbl.add_theme_font_size_override("font_size", 13)
	hbox.add_child(lbl)

	var units_lbl := Label.new()
	units_lbl.text = ", ".join(names) if not names.is_empty() else "(unknown)"
	units_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	units_lbl.add_theme_color_override("font_color", Color(0.65, 0.85, 0.65))
	units_lbl.add_theme_font_size_override("font_size", 12)
	units_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD
	hbox.add_child(units_lbl)

	return hbox


func _names_from_slot(slot) -> Array:
	var board: Array = []
	if slot is Dictionary:
		var b = slot.get("unit_names")
		if b is Array and not b.is_empty():
			return b
		b = slot.get("board", [])
		if b is Array:
			board = b
	elif slot is Array:
		board = slot
	var names: Array = []
	for d in board:
		if not (d is Dictionary):
			continue
		var ud = load(d.get("path", ""))
		if ud != null:
			names.append(ud.display_name)
	return names


# ── Helpers ───────────────────────────────────────────────────────────────────

func _hsep() -> HSeparator:
	return HSeparator.new()


# ── Button callbacks ──────────────────────────────────────────────────────────

func _on_continue_slot(idx: int) -> void:
	GameData.current_slot = idx
	GameData.gauntlet_mode = false
	get_tree().change_scene_to_file("res://scenes/combat_arena.tscn")


func _on_new_slot(idx: int) -> void:
	GameData.clear_slot(idx)
	GameData.current_slot = idx
	GameData.gauntlet_mode = false
	get_tree().change_scene_to_file("res://scenes/combat_arena.tscn")


func _on_clear_slot(idx: int) -> void:
	_show_confirm(
		"Clear slot %d? This cannot be undone." % (idx + 1),
		func():
			GameData.clear_slot(idx)
			_build_ui()
	)


func _on_gauntlet_pressed() -> void:
	var last_slot = GameData._data["gauntlet"].get("last_winning_slot")
	if not (last_slot is Dictionary) or last_slot.is_empty():
		return
	GameData.begin_gauntlet(last_slot)
	GameData.current_slot = -1
	get_tree().change_scene_to_file("res://scenes/combat_arena.tscn")


func _on_manual_pressed() -> void:
	UnitManual.open(self)


func _on_history_pressed() -> void:
	_show_history_overlay()


func _on_exit_pressed() -> void:
	get_tree().quit()


# ── Confirm dialog ────────────────────────────────────────────────────────────

func _show_confirm(message: String, on_confirm: Callable) -> void:
	var overlay := ColorRect.new()
	overlay.color = Color(0, 0, 0, 0.6)
	overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	overlay.z_index = 200
	add_child(overlay)

	var box := PanelContainer.new()
	box.set_anchors_preset(Control.PRESET_CENTER)
	box.z_index = 201
	add_child(box)

	var vb := VBoxContainer.new()
	vb.add_theme_constant_override("separation", 16)
	var mg := MarginContainer.new()
	for s in ["margin_left","margin_right","margin_top","margin_bottom"]:
		mg.add_theme_constant_override(s, 24)
	mg.add_child(vb)
	box.add_child(mg)

	var lbl := Label.new()
	lbl.text = message
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vb.add_child(lbl)

	var row := HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override("separation", 16)
	vb.add_child(row)

	var yes := Button.new()
	yes.text = "Confirm"
	yes.custom_minimum_size = Vector2(100, 36)
	yes.pressed.connect(func():
		overlay.queue_free()
		box.queue_free()
		on_confirm.call())
	row.add_child(yes)

	var no := Button.new()
	no.text = "Cancel"
	no.custom_minimum_size = Vector2(100, 36)
	no.pressed.connect(func():
		overlay.queue_free()
		box.queue_free())
	row.add_child(no)


# ── History overlay ───────────────────────────────────────────────────────────

func _show_history_overlay() -> void:
	var overlay := ColorRect.new()
	overlay.color = Color(0, 0, 0, 0.75)
	overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	overlay.z_index = 200
	add_child(overlay)

	var panel := PanelContainer.new()
	panel.set_anchors_preset(Control.PRESET_CENTER)
	panel.custom_minimum_size = Vector2(560, 480)
	panel.z_index = 201
	add_child(panel)

	var mg := MarginContainer.new()
	for s in ["margin_left","margin_right","margin_top","margin_bottom"]:
		mg.add_theme_constant_override(s, 16)
	panel.add_child(mg)

	var vb := VBoxContainer.new()
	vb.add_theme_constant_override("separation", 8)
	mg.add_child(vb)

	var title := Label.new()
	title.text = "RUN HISTORY"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 20)
	vb.add_child(title)
	vb.add_child(HSeparator.new())

	var scroll := ScrollContainer.new()
	scroll.custom_minimum_size = Vector2(0, 340)
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	vb.add_child(scroll)

	var list := VBoxContainer.new()
	list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	list.add_theme_constant_override("separation", 4)
	scroll.add_child(list)

	var history := GameData.get_history()
	if history.is_empty():
		var empty := Label.new()
		empty.text = "No completed runs yet."
		empty.add_theme_color_override("font_color", Color(0.5, 0.5, 0.6))
		empty.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		list.add_child(empty)
	else:
		for i in range(history.size()):
			var entry: Dictionary = history[i]
			var lbl := Label.new()
			var result: String = entry.get("result", "?")
			var battles: int   = int(entry.get("battles", 0))
			var date: String   = entry.get("date", "")
			var units: String  = ", ".join(entry.get("unit_names", []))
			lbl.text = "#%d  %s  —  %d battles  [%s]\n  %s" % [
				i + 1, result.to_upper(), battles, date, units]
			lbl.add_theme_font_size_override("font_size", 12)
			lbl.autowrap_mode = TextServer.AUTOWRAP_WORD
			list.add_child(lbl)
			if i < history.size() - 1:
				list.add_child(HSeparator.new())

	var close_btn := Button.new()
	close_btn.text = "Close"
	close_btn.custom_minimum_size = Vector2(120, 36)
	close_btn.pressed.connect(func():
		overlay.queue_free()
		panel.queue_free())
	vb.add_child(close_btn)
