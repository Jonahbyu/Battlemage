extends Control

var _m: bool = false  # true when running on mobile

func _ready() -> void:
	_m = Platform.is_mobile()
	_build_ui()
	# Phone: scale text and touch targets the same way the shops do.
	Platform.adapt_overlay(self)


func _build_ui() -> void:
	for child in get_children():
		child.queue_free()

	# ── Background: animated mist + sigil behind the title ─────────────────────
	add_child(UITheme.backdrop(1.0, Vector2(0.5, 0.22 if not _m else 0.1)))

	# ── Scroll container so slots fit on small screens ──────────────────────────
	var scroll := ScrollContainer.new()
	scroll.set_anchors_preset(Control.PRESET_FULL_RECT)
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	add_child(scroll)

	var center := VBoxContainer.new()
	center.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	center.add_theme_constant_override("separation", 8)
	center.alignment = BoxContainer.ALIGNMENT_CENTER
	scroll.add_child(center)
	scroll.resized.connect(func(): center.custom_minimum_size.y = scroll.size.y)

	var inner := VBoxContainer.new()
	inner.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	inner.add_theme_constant_override("separation", 10)
	var margin := MarginContainer.new()
	var side_margin := 24 if _m else 0
	for s in ["margin_left","margin_right"]:
		margin.add_theme_constant_override(s, side_margin)
	margin.add_theme_constant_override("margin_top", 28 if _m else 22)
	margin.add_theme_constant_override("margin_bottom", 24)
	margin.size_flags_horizontal = Control.SIZE_SHRINK_CENTER if not _m else Control.SIZE_EXPAND_FILL
	if not _m:
		margin.custom_minimum_size.x = 1320
	margin.add_child(inner)
	center.add_child(margin)

	# ── Title ───────────────────────────────────────────────────────────────────
	var title := Label.new()
	title.text = "BATTLEMAGE"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	UITheme.style_title(title, 76 if _m else 88)
	if _m:
		# One line on a phone; skip the overlay text boost that wrapped it.
		title.set_meta("_mobile_adapted", true)
		title.add_theme_font_size_override("font_size", 104)
	inner.add_child(title)

	var sub := Label.new()
	sub.text = "AN  AUTOBATTLER  ROGUELIKE"
	sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	UITheme.style_eyebrow(sub, UITheme.TEXT_DIM)
	sub.add_theme_font_size_override("font_size", 15)
	inner.add_child(sub)

	inner.add_child(UITheme.ornament(0, Color(UITheme.GOLD_DIM, 0.9)))

	# ── Body: slots | (difficulty + gauntlet) ───────────────────────────────────
	var body: BoxContainer = VBoxContainer.new() if _m else HBoxContainer.new()
	body.add_theme_constant_override("separation", 18 if _m else 28)
	inner.add_child(body)

	var left := VBoxContainer.new()
	left.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	left.size_flags_stretch_ratio = 1.6
	left.add_theme_constant_override("separation", 10)
	body.add_child(left)

	left.add_child(_eyebrow("Save Slots"))
	for i in range(GameData.SLOT_COUNT):
		left.add_child(_build_slot_row(i))

	var right := VBoxContainer.new()
	right.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	right.add_theme_constant_override("separation", 16)
	body.add_child(right)

	right.add_child(_framed(_build_difficulty_section()))
	right.add_child(_framed(_build_gauntlet_section()))

	inner.add_child(UITheme.ornament(0, Color(UITheme.GOLD_DIM, 0.6)))

	# ── History & Exit ──────────────────────────────────────────────────────────
	var bottom := HBoxContainer.new()
	bottom.alignment = BoxContainer.ALIGNMENT_CENTER
	bottom.add_theme_constant_override("separation", 12 if _m else 22)
	inner.add_child(bottom)

	var hist_btn := Button.new()
	hist_btn.text = "History" if _m else "Run History"
	hist_btn.custom_minimum_size = Vector2(0 if _m else 220, 56 if _m else 46)
	if _m:
		hist_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hist_btn.pressed.connect(_on_history_pressed)
	bottom.add_child(hist_btn)

	var manual_btn := Button.new()
	manual_btn.text = "Unit Manual"
	manual_btn.custom_minimum_size = Vector2(0 if _m else 220, 56 if _m else 46)
	if _m:
		manual_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	manual_btn.pressed.connect(_on_manual_pressed)
	bottom.add_child(manual_btn)

	var exit_btn := Button.new()
	exit_btn.text = "Exit" if _m else "Exit Game"
	exit_btn.custom_minimum_size = Vector2(0 if _m else 220, 56 if _m else 46)
	if _m:
		exit_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	exit_btn.pressed.connect(_on_exit_pressed)
	bottom.add_child(exit_btn)

	var ui_btn := Button.new()
	ui_btn.text = _ui_mode_label()
	ui_btn.add_theme_font_override("font", UITheme.font_body)
	ui_btn.add_theme_font_size_override("font_size", 16)
	ui_btn.add_theme_color_override("font_color", UITheme.TEXT_FAINT)
	ui_btn.add_theme_color_override("font_hover_color", UITheme.TEXT_DIM)
	ui_btn.flat = true
	ui_btn.pressed.connect(func():
		var next: int = ({0: 1, 1: -1, -1: 0} as Dictionary)[Platform.override_mode]
		Platform.set_override(next)
		_m = Platform.is_mobile()
		_build_ui())
	inner.add_child(ui_btn)

	_stagger_in(inner)


# Fade each block in, top to bottom.
func _stagger_in(box: Control) -> void:
	var i := 0
	for c in box.get_children():
		if not (c is CanvasItem):
			continue
		c.modulate.a = 0.0
		var tw := c.create_tween()
		tw.tween_interval(0.05 + i * 0.06)
		tw.tween_property(c, "modulate:a", 1.0, 0.45).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
		i += 1


func _eyebrow(text: String) -> Label:
	var l := Label.new()
	l.text = text.to_upper()
	UITheme.style_eyebrow(l)
	l.add_theme_font_size_override("font_size", 16)
	return l


func _framed(content: Control) -> PanelContainer:
	var p := PanelContainer.new()
	var s := UITheme.panel_box(UITheme.PANEL, Color(UITheme.GOLD_DIM, 0.55), 4, 16)
	s.set_content_margin_all(18)
	p.add_theme_stylebox_override("panel", s)
	p.add_child(content)
	return p


const _ROMAN := ["I", "II", "III", "IV", "V", "VI", "VII", "VIII", "IX", "X"]

# ── Slot row ─────────────────────────────────────────────────────────────────

func _build_slot_row(idx: int) -> Control:
	var slot = GameData.get_slot(idx)
	var occupied: bool = slot != null and slot is Dictionary

	var panel := PanelContainer.new()
	var style := UITheme.panel_box(
		UITheme.PANEL_HI if occupied else Color(UITheme.PANEL, 0.78),
		Color(UITheme.GOLD, 0.75) if occupied else Color(UITheme.GOLD_DIM, 0.35), 4, 10 if occupied else 6)
	if occupied:
		style.border_width_left = 4
	style.set_content_margin_all(0)
	panel.add_theme_stylebox_override("panel", style)

	var hbox := HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 16)
	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 14)
	margin.add_theme_constant_override("margin_right", 12)
	margin.add_theme_constant_override("margin_top", 8)
	margin.add_theme_constant_override("margin_bottom", 8)
	margin.add_child(hbox)
	panel.add_child(margin)

	# Slot numeral
	var badge := Label.new()
	badge.text = _ROMAN[idx] if idx < _ROMAN.size() else str(idx + 1)
	badge.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	badge.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	badge.add_theme_font_override("font", UITheme.font_display_bold)
	badge.add_theme_font_size_override("font_size", 30)
	badge.add_theme_color_override("font_color", UITheme.GOLD if occupied else UITheme.TEXT_FAINT)
	badge.custom_minimum_size = Vector2(56, 0)
	hbox.add_child(badge)

	var vsep := VSeparator.new()
	vsep.add_theme_constant_override("separation", 2)
	hbox.add_child(vsep)

	# Info column
	var info := VBoxContainer.new()
	info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	info.alignment = BoxContainer.ALIGNMENT_CENTER
	info.add_theme_constant_override("separation", 2)
	hbox.add_child(info)

	if occupied:
		var map_row: int   = int(slot.get("map_row", 0))
		var hp: int        = int(slot.get("player_hp", 100))
		var tier: int      = int(slot.get("tier", 1))

		var stats := RichTextLabel.new()
		stats.bbcode_enabled = true
		stats.fit_content = true
		stats.scroll_active = false
		stats.autowrap_mode = TextServer.AUTOWRAP_OFF
		stats.add_theme_font_size_override("normal_font_size", 17)
		stats.add_theme_font_size_override("bold_font_size", 17)
		var dim := UITheme.TEXT_DIM.to_html(false)
		stats.text = "[color=#%s]TURN[/color] [b]%d[/b][color=#%s] / 13[/color]     [color=#%s]♥[/color] [b]%d[/b]     [color=#%s]TIER[/color] [b]%d[/b]" % [
			dim, map_row + 1, dim, UITheme.EMBER.to_html(false), hp, dim, tier]
		info.add_child(stats)

		var names: Array = slot.get("unit_names", [])
		if names.is_empty():
			var board_arr: Array = slot.get("board", [])
			for d in board_arr:
				var ud = load(d.get("path", ""))
				if ud != null:
					names.append(ud.display_name)

		var units_label := Label.new()
		units_label.text = "  ·  ".join(names) if not names.is_empty() else "(empty board)"
		units_label.add_theme_color_override("font_color", UITheme.ARCANE.lerp(UITheme.TEXT, 0.35))
		units_label.add_theme_font_size_override("font_size", 15)
		units_label.autowrap_mode = TextServer.AUTOWRAP_WORD
		info.add_child(units_label)
	else:
		var empty_lbl := Label.new()
		empty_lbl.text = "An unwritten page"
		empty_lbl.add_theme_color_override("font_color", UITheme.TEXT_FAINT)
		empty_lbl.add_theme_font_size_override("font_size", 17)
		info.add_child(empty_lbl)

	# Button column
	var btns := HBoxContainer.new()
	btns.alignment = BoxContainer.ALIGNMENT_CENTER
	btns.add_theme_constant_override("separation", 8)
	hbox.add_child(btns)

	if occupied:
		var cont_btn := Button.new()
		cont_btn.text = "Continue"
		cont_btn.custom_minimum_size = Vector2(130, 48 if _m else 40)
		cont_btn.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		cont_btn.pressed.connect(_on_continue_slot.bind(idx))
		btns.add_child(cont_btn)

		var clear_btn := Button.new()
		clear_btn.text = "✕"
		clear_btn.tooltip_text = "Clear this slot"
		clear_btn.custom_minimum_size = Vector2(48 if _m else 40, 48 if _m else 40)
		clear_btn.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		clear_btn.add_theme_color_override("font_color", UITheme.TEXT_DIM)
		clear_btn.add_theme_color_override("font_hover_color", UITheme.EMBER)
		for st in ["normal", "hover", "pressed"]:
			clear_btn.add_theme_stylebox_override(st, UITheme.button_box(st, UITheme.EMBER))
		clear_btn.pressed.connect(_on_clear_slot.bind(idx))
		btns.add_child(clear_btn)
	else:
		var new_btn := Button.new()
		new_btn.text = "New Run"
		new_btn.custom_minimum_size = Vector2(130, 48 if _m else 40)
		new_btn.size_flags_vertical = Control.SIZE_SHRINK_CENTER
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

	vbox.add_child(_eyebrow("Difficulty"))

	var level := GameData.difficulty_level
	var max_lvl := GameData.max_unlocked_difficulty

	# Level selector row
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 10)
	vbox.add_child(row)

	var prev_btn := Button.new()
	prev_btn.text = "<"
	prev_btn.custom_minimum_size = Vector2(44 if _m else 36, 44 if _m else 36)
	prev_btn.disabled = level <= 0
	prev_btn.pressed.connect(func():
		GameData.set_difficulty(level - 1)
		_build_ui())
	row.add_child(prev_btn)

	var level_name := "Normal" if level == 0 else "Level %d" % level
	var level_lbl := Label.new()
	level_lbl.text = level_name
	level_lbl.custom_minimum_size = Vector2(150, 0)
	level_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	level_lbl.add_theme_font_override("font", UITheme.font_display_bold)
	level_lbl.add_theme_font_size_override("font_size", 22)
	level_lbl.add_theme_color_override("font_color", UITheme.EMBER if level > 0 else UITheme.TEXT)
	row.add_child(level_lbl)

	var next_btn := Button.new()
	next_btn.text = ">"
	next_btn.custom_minimum_size = Vector2(44 if _m else 36, 44 if _m else 36)
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
		none_lbl.add_theme_color_override("font_color", UITheme.TEXT_FAINT)
		none_lbl.add_theme_font_size_override("font_size", 15)
		vbox.add_child(none_lbl)
	else:
		for mod in mods:
			var mod_lbl := Label.new()
			mod_lbl.text = "  •  " + mod
			mod_lbl.add_theme_color_override("font_color", UITheme.EMBER)
			mod_lbl.add_theme_font_size_override("font_size", 15)
			vbox.add_child(mod_lbl)

	# Unlock hint
	if level < GameData.MAX_DIFFICULTY:
		var hint_text := "Beat this run to unlock Level %d." % (level + 1) if level >= max_lvl else ""
		if not hint_text.is_empty():
			var hint_lbl := Label.new()
			hint_lbl.text = hint_text
			hint_lbl.add_theme_color_override("font_color", UITheme.ARCANE.darkened(0.25))
			hint_lbl.add_theme_font_size_override("font_size", 15)
			vbox.add_child(hint_lbl)

	return vbox


# ── Gauntlet section ──────────────────────────────────────────────────────────

func _build_gauntlet_section() -> Control:
	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 8)

	vbox.add_child(_eyebrow("Gauntlet"))

	if not GameData.has_gauntlet_data():
		var lbl := Label.new()
		lbl.text = "Complete a 25-battle run to unlock the Gauntlet."
		lbl.add_theme_color_override("font_color", UITheme.TEXT_FAINT)
		lbl.add_theme_font_size_override("font_size", 16)
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
		no_champ.add_theme_color_override("font_color", UITheme.TEXT_FAINT)
		no_champ.add_theme_font_size_override("font_size", 15)
		no_champ.autowrap_mode = TextServer.AUTOWRAP_WORD
		vbox.add_child(no_champ)

	var enter_btn := Button.new()
	enter_btn.text = "Enter the Gauntlet"
	enter_btn.tooltip_text = "Your last winning board stands as the challenger."
	enter_btn.custom_minimum_size = Vector2(0, 56 if _m else 44)
	enter_btn.add_theme_color_override("font_color", UITheme.GOLD_HI)
	enter_btn.pressed.connect(_on_gauntlet_pressed)
	vbox.add_child(enter_btn)

	return vbox


func _build_gauntlet_board_row(label_text: String, names: Array) -> Control:
	var hbox := HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 12)

	var lbl := Label.new()
	lbl.text = label_text + ":"
	lbl.custom_minimum_size = Vector2(180, 0)
	lbl.add_theme_color_override("font_color", UITheme.TEXT_DIM)
	lbl.add_theme_font_size_override("font_size", 16)
	hbox.add_child(lbl)

	var units_lbl := Label.new()
	units_lbl.text = ", ".join(names) if not names.is_empty() else "(unknown)"
	units_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	units_lbl.add_theme_color_override("font_color", UITheme.ARCANE.lerp(UITheme.TEXT, 0.35))
	units_lbl.add_theme_font_size_override("font_size", 15)
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


func _ui_mode_label() -> String:
	if _m:
		match Platform.override_mode:
			1:  return "UI: Mobile · tap to change"
			-1: return "UI: Desktop · tap to change"
			_:  return "UI: Auto · tap to change"
	match Platform.override_mode:
		1:  return "UI Mode: Force Mobile  (click to → Desktop)"
		-1: return "UI Mode: Force Desktop  (click to → Auto)"
		_:
			var detected := "Mobile" if (OS.has_feature("mobile") or OS.has_feature("web_android") or OS.has_feature("web_ios")) else "Desktop"
			return "UI Mode: Auto (%s detected)  (click to → Force Mobile)" % detected


# ── Button callbacks ──────────────────────────────────────────────────────────

func _on_continue_slot(idx: int) -> void:
	GameData.current_slot = idx
	GameData.gauntlet_mode = false
	Platform.go(get_tree(), "res://scenes/combat_arena.tscn")


func _on_new_slot(idx: int) -> void:
	GameData.clear_slot(idx)
	GameData.current_slot = idx
	GameData.gauntlet_mode = false
	Platform.go(get_tree(), "res://scenes/combat_arena.tscn")


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
	Platform.go(get_tree(), "res://scenes/combat_arena.tscn")


func _on_manual_pressed() -> void:
	UnitManual.open(self)


# Android back button (see Platform._on_back). The confirm and history pop-ups
# are pairs of z_index 200/201 siblings: close them; with none open, exit.
func handle_back() -> bool:
	var popups := get_children().filter(func(c):
		return c is CanvasItem and (c as CanvasItem).z_index >= 200 and not c.is_queued_for_deletion())
	if popups.is_empty():
		get_tree().quit()
		return true
	for c in popups:
		c.queue_free()
	return true


func _on_history_pressed() -> void:
	_show_history_overlay()


func _on_exit_pressed() -> void:
	get_tree().quit()


# ── Confirm dialog ────────────────────────────────────────────────────────────

func _show_confirm(message: String, on_confirm: Callable) -> void:
	var overlay := ColorRect.new()
	overlay.color = Color(UITheme.INK, 0.78)
	overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	overlay.z_index = 200
	add_child(overlay)

	var box := PanelContainer.new()
	box.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	box.grow_horizontal = Control.GROW_DIRECTION_BOTH
	box.grow_vertical = Control.GROW_DIRECTION_BOTH
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
	yes.custom_minimum_size = Vector2(100, 48 if _m else 36)
	yes.pressed.connect(func():
		overlay.queue_free()
		box.queue_free()
		on_confirm.call())
	row.add_child(yes)

	var no := Button.new()
	no.text = "Cancel"
	no.custom_minimum_size = Vector2(100, 48 if _m else 36)
	no.pressed.connect(func():
		overlay.queue_free()
		box.queue_free())
	row.add_child(no)


# ── History overlay ───────────────────────────────────────────────────────────

func _show_history_overlay() -> void:
	var overlay := ColorRect.new()
	overlay.color = Color(UITheme.INK, 0.85)
	overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	overlay.z_index = 200
	add_child(overlay)

	var panel := PanelContainer.new()
	if _m:
		# Phone: fill the screen inside a margin; pages instead of a scroll list.
		panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		panel.offset_left = 24
		panel.offset_right = -24
		panel.offset_top = 80
		panel.offset_bottom = -80
	else:
		panel.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
		panel.grow_horizontal = Control.GROW_DIRECTION_BOTH
		panel.grow_vertical = Control.GROW_DIRECTION_BOTH
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
	UITheme.style_title(title, 30)
	vb.add_child(title)
	vb.add_child(UITheme.ornament())

	var list := VBoxContainer.new()
	list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	list.add_theme_constant_override("separation", 4)
	var history := GameData.get_history()
	var per_page := 5 if _m else history.size()
	var pages := maxi(1, ceili(float(history.size()) / maxf(1.0, per_page)))
	var page := [0]
	var page_lbl := Label.new()
	var fill := func():
		for c in list.get_children():
			c.queue_free()
		if history.is_empty():
			var empty := Label.new()
			empty.text = "No completed runs yet."
			empty.add_theme_color_override("font_color", UITheme.TEXT_FAINT)
			empty.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			list.add_child(empty)
			return
		var first: int = page[0] * per_page
		var last: int = mini(history.size(), first + per_page)
		for i in range(first, last):
			var entry: Dictionary = history[i]
			var lbl := Label.new()
			var result: String = entry.get("result", "?")
			var battles: int   = int(entry.get("battles", 0))
			var date: String   = entry.get("date", "")
			var units: String  = ", ".join(entry.get("unit_names", []))
			lbl.text = "#%d  %s  —  %d battles  [%s]
  %s" % [
				i + 1, result.to_upper(), battles, date, units]
			lbl.add_theme_font_size_override("font_size", 15)
			lbl.autowrap_mode = TextServer.AUTOWRAP_WORD
			list.add_child(lbl)
			if i < last - 1:
				list.add_child(HSeparator.new())
		page_lbl.text = "Page %d / %d" % [page[0] + 1, pages]

	if _m:
		list.size_flags_vertical = Control.SIZE_EXPAND_FILL
		vb.add_child(list)
	else:
		var scroll := ScrollContainer.new()
		scroll.custom_minimum_size = Vector2(0, 340)
		scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
		vb.add_child(scroll)
		scroll.add_child(list)
	fill.call()

	if _m and pages > 1:
		var nav := HBoxContainer.new()
		nav.alignment = BoxContainer.ALIGNMENT_CENTER
		nav.add_theme_constant_override("separation", 16)
		vb.add_child(nav)
		var prev := Button.new()
		prev.text = "<"
		prev.custom_minimum_size = Vector2(64, 48)
		nav.add_child(prev)
		page_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		page_lbl.custom_minimum_size = Vector2(160, 0)
		nav.add_child(page_lbl)
		var next := Button.new()
		next.text = ">"
		next.custom_minimum_size = Vector2(64, 48)
		nav.add_child(next)
		prev.pressed.connect(func():
			page[0] = (page[0] - 1 + pages) % pages
			fill.call())
		next.pressed.connect(func():
			page[0] = (page[0] + 1) % pages
			fill.call())

	var close_btn := Button.new()
	close_btn.text = "Close"
	close_btn.custom_minimum_size = Vector2(160 if _m else 120, 48 if _m else 36)
	close_btn.pressed.connect(func():
		overlay.queue_free()
		panel.queue_free())
	vb.add_child(close_btn)
