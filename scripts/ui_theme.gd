extends Node
## Global look & feel: "candlelit grimoire".
## Ink-dark lacquered panels, gilded hairline borders, ember + arcane-teal accents,
## Cinzel display type over Alegreya Sans body. Installed on the root Window so
## every Control inherits it; screens only override what they need.

# ── Palette ───────────────────────────────────────────────────────────────────
const INK        := Color(0.043, 0.035, 0.070)
const PANEL      := Color(0.082, 0.066, 0.118, 0.94)
const PANEL_HI   := Color(0.125, 0.098, 0.180, 0.96)
const PANEL_LO   := Color(0.058, 0.046, 0.086, 0.96)
const GOLD       := Color(0.886, 0.737, 0.443)
const GOLD_HI    := Color(1.000, 0.886, 0.620)
const GOLD_DIM   := Color(0.478, 0.388, 0.220)
const BRONZE     := Color(0.230, 0.172, 0.098)
const EMBER      := Color(0.910, 0.430, 0.200)
const ARCANE     := Color(0.435, 0.878, 0.816)
const VIOLET     := Color(0.560, 0.380, 0.900)
const TEXT       := Color(0.930, 0.890, 0.800)
const TEXT_DIM   := Color(0.640, 0.600, 0.540)
const TEXT_FAINT := Color(0.420, 0.390, 0.360)

const BTN_SKEW := 0.12

var font_body: Font
var font_bold: Font
var font_display: Font
var font_display_bold: Font
var theme: Theme

var _fade_layer: CanvasLayer
var _fade_rect: ColorRect
var _backdrop_shader: Shader


func _ready() -> void:
	_load_fonts()
	theme = _build_theme()
	get_tree().root.theme = theme
	_build_fade()
	get_tree().node_added.connect(_on_node_added)
	if get_tree().has_signal("scene_changed"):
		get_tree().connect("scene_changed", _fade_in)


# ── Fonts ─────────────────────────────────────────────────────────────────────

func _load_fonts() -> void:
	var fallbacks: Array[Font] = []
	var symbols := load("res://fonts/symbols_fallback.ttf") as Font
	if symbols:
		fallbacks.append(symbols)
	if ThemeDB.fallback_font:
		fallbacks.append(ThemeDB.fallback_font)

	font_body = _variation("res://fonts/AlegreyaSans-Regular.ttf", fallbacks, 0, {})
	font_bold = _variation("res://fonts/AlegreyaSans-Bold.ttf", fallbacks, 0, {})
	font_display = _variation("res://fonts/Cinzel.ttf", fallbacks, 1, {"wght": 600})
	font_display_bold = _variation("res://fonts/Cinzel.ttf", fallbacks, 2, {"wght": 900})


func _variation(path: String, fallbacks: Array[Font], spacing: int, axes: Dictionary) -> Font:
	var base := load(path) as FontFile
	if base == null:
		return ThemeDB.fallback_font
	var v := FontVariation.new()
	v.base_font = base
	v.fallbacks = fallbacks
	if spacing != 0:
		v.spacing_glyph = spacing
	if not axes.is_empty():
		var coords := {}
		for tag in axes:
			coords[TextServerManager.get_primary_interface().name_to_tag(tag)] = axes[tag]
		v.variation_opentype = coords
	return v


# ── Stylebox helpers (public: screens use these for bespoke panels) ───────────

func panel_box(bg: Color = PANEL, border: Color = Color(GOLD_DIM, 0.6),
		radius: int = 4, shadow: int = 14) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = bg
	s.border_color = border
	s.set_border_width_all(1)
	s.set_corner_radius_all(radius)
	s.shadow_color = Color(0, 0, 0, 0.55)
	s.shadow_size = shadow
	s.shadow_offset = Vector2(0, 4)
	s.anti_aliasing = true
	s.set_content_margin_all(10)
	return s


func button_box(state: String, accent: Color = GOLD) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.skew = Vector2(BTN_SKEW, 0)
	s.set_corner_radius_all(2)
	s.anti_aliasing = true
	s.content_margin_left = 12
	s.content_margin_right = 12
	s.content_margin_top = 6
	s.content_margin_bottom = 8
	s.set_border_width_all(1)
	s.border_width_bottom = 3
	match state:
		"normal":
			s.bg_color = Color(0.110, 0.086, 0.157, 0.97)
			s.border_color = accent.darkened(0.45)
			s.shadow_color = Color(0, 0, 0, 0.45)
			s.shadow_size = 6
			s.shadow_offset = Vector2(0, 3)
		"hover":
			s.bg_color = Color(0.170, 0.128, 0.235, 1.0)
			s.border_color = accent
			s.shadow_color = Color(accent, 0.28)
			s.shadow_size = 12
		"pressed":
			s.bg_color = Color(0.060, 0.048, 0.090, 1.0)
			s.border_color = accent
			s.border_width_top = 3
			s.border_width_bottom = 1
			s.content_margin_top = 8
			s.content_margin_bottom = 6
			s.shadow_color = Color(accent, 0.18)
			s.shadow_size = 4
		"disabled":
			s.bg_color = Color(0.075, 0.066, 0.090, 0.75)
			s.border_color = Color(0.22, 0.20, 0.25)
		"focus":
			s.draw_center = false
			s.border_color = Color(ARCANE, 0.7)
			s.set_border_width_all(1)
			s.set_expand_margin_all(2)
	return s


## Apply the gilded display treatment to a heading label.
func style_title(lbl: Label, size: int = -1, col: Color = GOLD_HI, glow: bool = true) -> void:
	lbl.add_theme_font_override("font", font_display_bold)
	if size > 0:
		lbl.add_theme_font_size_override("font_size", size)
	lbl.add_theme_color_override("font_color", col)
	lbl.add_theme_color_override("font_outline_color", Color(0.10, 0.05, 0.02, 0.95))
	lbl.add_theme_constant_override("outline_size", maxi(2, int(lbl.get_theme_font_size("font_size") / 14.0)))
	if glow:
		lbl.add_theme_color_override("font_shadow_color", Color(EMBER, 0.45))
		lbl.add_theme_constant_override("shadow_offset_x", 0)
		lbl.add_theme_constant_override("shadow_offset_y", 0)
		lbl.add_theme_constant_override("shadow_outline_size", maxi(6, int(lbl.get_theme_font_size("font_size") / 4.0)))


## Small-caps section label ("SAVE SLOTS", "DIFFICULTY", …).
func style_eyebrow(lbl: Label, col: Color = GOLD) -> void:
	lbl.add_theme_font_override("font", font_display)
	lbl.add_theme_color_override("font_color", col)
	lbl.add_theme_constant_override("shadow_offset_y", 1)


## Decorative divider: ── ✦ ──
func ornament(width: float = 0.0, col: Color = GOLD_DIM) -> Control:
	var row := HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override("separation", 10)
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if width > 0:
		row.custom_minimum_size.x = width
	for side in 2:
		var line := _FadeLine.new()
		line.col = col
		line.flip = side == 1
		line.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		line.custom_minimum_size = Vector2(40, 12)
		row.add_child(line)
		if side == 0:
			var gem := Label.new()
			gem.text = "✦"
			gem.add_theme_color_override("font_color", col.lightened(0.35))
			gem.add_theme_font_size_override("font_size", 14)
			row.add_child(gem)
	return row


## Animated atmospheric backdrop (nebula mist, drifting embers, vignette).
## `rune` > 0 draws a slowly turning sigil ring at `rune_center` (UV space).
func backdrop(rune: float = 0.0, rune_center: Vector2 = Vector2(0.5, 0.3), tint: Color = VIOLET) -> ColorRect:
	var r := ColorRect.new()
	r.color = INK
	r.mouse_filter = Control.MOUSE_FILTER_IGNORE
	r.set_anchors_preset(Control.PRESET_FULL_RECT)
	apply_backdrop(r, rune, rune_center, tint)
	return r


func apply_backdrop(r: CanvasItem, rune: float = 0.0, rune_center: Vector2 = Vector2(0.5, 0.3), tint: Color = VIOLET) -> void:
	if _backdrop_shader == null:
		_backdrop_shader = load("res://resources/shaders/backdrop.gdshader")
	var m := ShaderMaterial.new()
	m.shader = _backdrop_shader
	m.set_shader_parameter("rune", rune)
	m.set_shader_parameter("rune_center", rune_center)
	m.set_shader_parameter("glow_a", tint)
	r.material = m


# ── Theme ─────────────────────────────────────────────────────────────────────

func _build_theme() -> Theme:
	var t := Theme.new()
	t.default_font = font_body
	t.default_font_size = 17

	# Label
	t.set_color("font_color", "Label", TEXT)
	t.set_color("font_shadow_color", "Label", Color(0, 0, 0, 0.55))
	t.set_constant("shadow_offset_x", "Label", 0)
	t.set_constant("shadow_offset_y", "Label", 1)
	t.set_color("font_outline_color", "Label", Color(0, 0, 0, 0.8))

	# RichTextLabel
	t.set_color("default_color", "RichTextLabel", TEXT)
	t.set_font("normal_font", "RichTextLabel", font_body)
	t.set_font("bold_font", "RichTextLabel", font_bold)
	t.set_color("font_shadow_color", "RichTextLabel", Color(0, 0, 0, 0.5))
	t.set_constant("shadow_offset_y", "RichTextLabel", 1)
	t.set_stylebox("normal", "RichTextLabel", StyleBoxEmpty.new())

	# Buttons
	for st in ["normal", "hover", "pressed", "disabled", "focus"]:
		t.set_stylebox(st, "Button", button_box(st))
	var hp := button_box("pressed")
	t.set_stylebox("hover_pressed", "Button", hp)
	t.set_font("font", "Button", font_display_bold)
	t.set_font_size("font_size", "Button", 15)
	t.set_color("font_color", "Button", TEXT)
	t.set_color("font_hover_color", "Button", GOLD_HI)
	t.set_color("font_pressed_color", "Button", GOLD)
	t.set_color("font_hover_pressed_color", "Button", GOLD_HI)
	t.set_color("font_focus_color", "Button", TEXT)
	t.set_color("font_disabled_color", "Button", TEXT_FAINT)
	t.set_color("font_outline_color", "Button", Color(0, 0, 0, 0.85))
	t.set_constant("outline_size", "Button", 0)
	t.set_constant("h_separation", "Button", 8)

	# Toggle-style buttons should not inherit the chunky Button frame.
	for ty in ["CheckBox", "CheckButton"]:
		for st in ["normal", "hover", "pressed", "disabled", "hover_pressed"]:
			var e := StyleBoxEmpty.new()
			e.set_content_margin_all(4)
			t.set_stylebox(st, ty, e)
		t.set_stylebox("focus", ty, StyleBoxEmpty.new())
		t.set_font("font", ty, font_body)
		t.set_color("font_color", ty, TEXT)
		t.set_color("font_hover_color", ty, GOLD_HI)
		t.set_color("font_pressed_color", ty, GOLD)
	for ty in ["LinkButton"]:
		t.set_font("font", ty, font_body)
		t.set_color("font_color", ty, ARCANE)
		t.set_color("font_hover_color", ty, GOLD_HI)

	# Panels
	var p := panel_box()
	t.set_stylebox("panel", "Panel", p)
	t.set_stylebox("panel", "PanelContainer", p)
	var pop := panel_box(PANEL_HI, GOLD_DIM, 4, 18)
	t.set_stylebox("panel", "PopupPanel", pop)
	t.set_stylebox("panel", "PopupMenu", pop)
	t.set_stylebox("panel", "PopupDialog", pop)
	t.set_stylebox("panel", "AcceptDialog", pop)
	var tip := panel_box(Color(0.06, 0.045, 0.085, 0.98), GOLD_DIM, 3, 10)
	tip.set_content_margin_all(8)
	t.set_stylebox("panel", "TooltipPanel", tip)
	t.set_color("font_color", "TooltipLabel", TEXT)
	t.set_font("font", "TooltipLabel", font_body)
	t.set_font_size("font_size", "TooltipLabel", 16)
	t.set_font("font", "PopupMenu", font_body)
	t.set_color("font_color", "PopupMenu", TEXT)
	t.set_color("font_hover_color", "PopupMenu", GOLD_HI)
	var hov := StyleBoxFlat.new()
	hov.bg_color = Color(GOLD, 0.14)
	hov.set_corner_radius_all(2)
	t.set_stylebox("hover", "PopupMenu", hov)

	# Separators
	for ty in ["HSeparator", "VSeparator"]:
		var l := StyleBoxLine.new()
		l.color = Color(GOLD_DIM, 0.55)
		l.thickness = 1
		l.vertical = ty == "VSeparator"
		t.set_stylebox("separator", ty, l)
		t.set_constant("separation", ty, 14)

	# Scrollbars: slim gilded grabbers on an invisible track
	for ty in ["VScrollBar", "HScrollBar"]:
		var track := StyleBoxFlat.new()
		track.bg_color = Color(0, 0, 0, 0.25)
		track.set_corner_radius_all(4)
		track.set_content_margin_all(3)
		t.set_stylebox("scroll", ty, track)
		t.set_stylebox("scroll_focus", ty, track)
		for pair in [["grabber", Color(GOLD_DIM, 0.8)], ["grabber_highlight", GOLD], ["grabber_pressed", GOLD_HI]]:
			var g := StyleBoxFlat.new()
			g.bg_color = pair[1]
			g.set_corner_radius_all(4)
			g.set_content_margin_all(3)
			t.set_stylebox(pair[0], ty, g)

	# Text input
	var le := StyleBoxFlat.new()
	le.bg_color = PANEL_LO
	le.border_color = GOLD_DIM
	le.set_border_width_all(1)
	le.border_width_bottom = 2
	le.set_corner_radius_all(2)
	le.set_content_margin_all(8)
	t.set_stylebox("normal", "LineEdit", le)
	var lef := le.duplicate()
	lef.border_color = GOLD
	t.set_stylebox("focus", "LineEdit", lef)
	t.set_color("font_color", "LineEdit", TEXT)
	t.set_color("caret_color", "LineEdit", GOLD_HI)
	t.set_color("selection_color", "LineEdit", Color(GOLD, 0.3))

	# Progress bars
	var pb_bg := StyleBoxFlat.new()
	pb_bg.bg_color = PANEL_LO
	pb_bg.border_color = BRONZE
	pb_bg.set_border_width_all(1)
	pb_bg.set_corner_radius_all(3)
	t.set_stylebox("background", "ProgressBar", pb_bg)
	var pb_fill := StyleBoxFlat.new()
	pb_fill.bg_color = EMBER
	pb_fill.set_corner_radius_all(3)
	t.set_stylebox("fill", "ProgressBar", pb_fill)
	t.set_color("font_color", "ProgressBar", TEXT)

	# Tabs
	var tab_sel := StyleBoxFlat.new()
	tab_sel.bg_color = PANEL_HI
	tab_sel.border_color = GOLD
	tab_sel.border_width_top = 2
	tab_sel.set_content_margin_all(10)
	var tab_un := tab_sel.duplicate()
	tab_un.bg_color = PANEL_LO
	tab_un.border_color = GOLD_DIM
	tab_un.border_width_top = 1
	for ty in ["TabContainer", "TabBar"]:
		t.set_stylebox("tab_selected", ty, tab_sel)
		t.set_stylebox("tab_unselected", ty, tab_un)
		t.set_stylebox("tab_hovered", ty, tab_un)
		t.set_font("font", ty, font_display)
		t.set_color("font_selected_color", ty, GOLD_HI)
		t.set_color("font_unselected_color", ty, TEXT_DIM)
		t.set_color("font_hovered_color", ty, TEXT)
	t.set_stylebox("panel", "TabContainer", panel_box(PANEL, Color(GOLD_DIM, 0.6), 2, 0))

	# Lists / trees
	for ty in ["ItemList", "Tree"]:
		t.set_stylebox("panel", ty, panel_box(PANEL_LO, Color(GOLD_DIM, 0.5), 3, 0))
		t.set_color("font_color", ty, TEXT)
		var sel := StyleBoxFlat.new()
		sel.bg_color = Color(GOLD, 0.18)
		t.set_stylebox("selected", ty, sel)
		t.set_stylebox("selected_focus", ty, sel)
	return t


# ── Motion: button hover lift + press squash, scene fade-in ───────────────────

func _on_node_added(n: Node) -> void:
	if n is Control:
		_reskin.call_deferred(n)
	if n.name == "CombatArena" and n is Control:
		_skin_arena.call_deferred(n)
	if n is Button and not (n is CheckBox or n is CheckButton):
		var b := n as Button
		# A button moved to a new parent is "added" again; hook it up only once.
		if b.has_meta("_ui_motion"):
			return
		b.set_meta("_ui_motion", true)
		b.mouse_entered.connect(_btn_tween.bind(b, 1.04))
		b.mouse_exited.connect(_btn_tween.bind(b, 1.0))
		b.button_down.connect(_btn_tween.bind(b, 0.96))
		b.button_up.connect(func(): _btn_tween(b, 1.04 if b.is_hovered() else 1.0))
		b.resized.connect(func(): b.pivot_offset = b.size * 0.5)


func _btn_tween(b: Button, s: float) -> void:
	if not is_instance_valid(b) or b.disabled or b.flat:
		return
	b.pivot_offset = b.size * 0.5
	var tw := b.create_tween().set_trans(Tween.TRANS_BACK if s > 1.0 else Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tw.tween_property(b, "scale", Vector2(s, s), 0.14 if s >= 1.0 else 0.06)


func _build_fade() -> void:
	_fade_layer = CanvasLayer.new()
	_fade_layer.layer = 120
	add_child(_fade_layer)
	_fade_rect = ColorRect.new()
	_fade_rect.color = INK
	_fade_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_fade_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	_fade_layer.add_child(_fade_rect)
	_fade_in()


func _fade_in() -> void:
	_fade_rect.modulate.a = 1.0
	var tw := _fade_rect.create_tween()
	tw.tween_property(_fade_rect, "modulate:a", 0.0, 0.45).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)


# ── Re-skin legacy inline styles ──────────────────────────────────────────────
# Screens build StyleBoxFlats with neutral slate/grey colours. Remap those into
# the palette as they enter the tree; saturated colours (race tints, spell
# purple, danger red) are meaningful and left alone.

func _is_slate(c: Color) -> bool:
	return c.s < 0.38 or (c.h > 0.52 and c.h < 0.72 and c.s < 0.62)


# Checked by scene path, not class: referencing UnitCard here would create a
# load cycle (unit_card.gd uses this autoload).
func _is_card(n: Node) -> bool:
	return n.scene_file_path.ends_with("unit_card.tscn")


func _in_card(n: Node) -> bool:
	var p := n.get_parent()
	while p != null:
		if _is_card(p):
			return true
		p = p.get_parent()
	return false


func _reskin(c: Control) -> void:
	if not is_instance_valid(c) or _is_card(c) or _in_card(c):
		return
	if c is Panel or c is PanelContainer:
		var sb = c.get_theme_stylebox("panel") if c.has_theme_stylebox_override("panel") else null
		if sb is StyleBoxFlat and not sb.has_meta("_ui_skinned"):
			_remap_box(sb, true)
	elif c is ColorRect:
		var cr := c as ColorRect
		if cr.color.v < 0.06 and cr.color.a < 0.99 and cr.material == null:
			cr.color = Color(INK, cr.color.a)
	elif c is Label:
		var l := c as Label
		if l.has_theme_color_override("font_color"):
			var fc := l.get_theme_color("font_color")
			if _is_slate(fc) and fc.v < 0.9:
				var warm := TEXT_FAINT.lerp(TEXT_DIM, clampf((fc.v - 0.35) / 0.3, 0, 1)) if fc.v < 0.65 					else TEXT_DIM.lerp(TEXT, clampf((fc.v - 0.65) / 0.25, 0, 1))
				l.add_theme_color_override("font_color", Color(warm, fc.a))
		if l.has_theme_font_size_override("font_size") and not l.has_meta("_ui_sized"):
			var fs := l.get_theme_font_size("font_size")
			if fs >= 20 and not l.has_theme_font_override("font"):
				_promote_heading(l)
			if fs <= 12:
				l.add_theme_font_size_override("font_size", fs + 1)
			l.set_meta("_ui_sized", true)


# Large legacy labels are screen/section titles: give them the display face.
func _promote_heading(l: Label) -> void:
	l.add_theme_font_override("font", font_display_bold)
	var fc := l.get_theme_color("font_color")
	var is_plain := fc.s < 0.25 or (fc.h > 0.1 and fc.h < 0.18)  # white/grey or yellow
	if is_plain:
		l.add_theme_color_override("font_color", GOLD_HI)
	l.add_theme_color_override("font_outline_color", Color(0.10, 0.05, 0.02, 0.9))
	l.add_theme_constant_override("outline_size", 4)


func _remap_box(sb: StyleBoxFlat, add_shadow: bool) -> void:
	sb.set_meta("_ui_skinned", true)
	var bg := sb.bg_color
	if bg.a > 0.0 and bg.v < 0.36 and _is_slate(bg):
		var target := PANEL if bg.v < 0.13 else PANEL_HI
		if bg.v < 0.07:
			target = PANEL_LO
		sb.bg_color = Color(target.r, target.g, target.b, bg.a)
	var bc := sb.border_color
	if _is_slate(bc) and bc.v > 0.18:
		var t := clampf((bc.v - 0.3) * 1.6, 0.0, 1.0)
		sb.border_color = Color(GOLD_DIM.lerp(GOLD, t * 0.6), maxf(bc.a, 0.7))
	if add_shadow and sb.shadow_size == 0 and sb.bg_color.a > 0.85:
		sb.shadow_color = Color(0, 0, 0, 0.5)
		sb.shadow_size = 12
		sb.shadow_offset = Vector2(0, 4)
	sb.anti_aliasing = true


# ── Arena HUD (kept here so combat_arena.gd stays untouched) ─────────────────

func _skin_arena(arena: Control) -> void:
	if not is_instance_valid(arena):
		return
	var rb := arena.get_node_or_null("RootHBox/MainLayout/ResourceBar")
	if rb:
		rb.add_theme_constant_override("separation", 18)
		for n in ["GoldLabel", "HPLabel", "TierLabel"]:
			var l := rb.get_node_or_null(n) as Label
			if l == null:
				continue
			l.add_theme_font_override("font", font_bold)
			l.add_theme_font_size_override("font_size", 20)
			l.add_theme_constant_override("outline_size", 4)
			l.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.7))
		var g := rb.get_node_or_null("GoldLabel") as Label
		if g:
			g.add_theme_color_override("font_color", GOLD_HI)
		var t := rb.get_node_or_null("TierLabel") as Label
		if t:
			t.add_theme_color_override("font_color", ARCANE)
	var fight := arena.get_node_or_null("RootHBox/MainLayout/CenterRow/FightButton") as Button
	if fight:
		for st in ["normal", "hover", "pressed"]:
			var b := button_box(st, EMBER)
			if st == "normal":
				b.bg_color = Color(0.32, 0.10, 0.05, 0.98)
				b.border_color = EMBER
				b.shadow_color = Color(EMBER, 0.35)
				b.shadow_size = 14
			elif st == "hover":
				b.bg_color = Color(0.45, 0.15, 0.06, 1.0)
				b.shadow_color = Color(EMBER, 0.55)
				b.shadow_size = 22
			fight.add_theme_stylebox_override(st, b)
		fight.add_theme_font_size_override("font_size", 26)
		fight.add_theme_color_override("font_color", GOLD_HI)
		fight.add_theme_color_override("font_hover_color", Color.WHITE)
		fight.add_theme_color_override("font_outline_color", Color(0.2, 0.05, 0.0))
		fight.add_theme_constant_override("outline_size", 6)
		fight.custom_minimum_size.x = maxf(fight.custom_minimum_size.x, 190)
	var cont := arena.get_node_or_null("RootHBox/MainLayout/CenterRow/ContinueButton") as Button
	if cont:
		cont.add_theme_font_size_override("font_size", 22)
	var banner := arena.get_node_or_null("RootHBox/MainLayout/CenterRow/ResultBanner") as Label
	if banner:
		style_title(banner, 44)
	var sell := arena.get_node_or_null("RootHBox/MainLayout/SellZone") as Panel
	if sell:
		var s := StyleBoxFlat.new()
		s.bg_color = Color(0.20, 0.05, 0.04, 0.78)
		s.border_color = Color(EMBER, 0.55)
		s.set_border_width_all(1)
		s.border_width_top = 2
		s.set_corner_radius_all(6)
		s.shadow_color = Color(EMBER, 0.12)
		s.shadow_size = 16
		s.set_meta("_ui_skinned", true)
		sell.add_theme_stylebox_override("panel", s)
		var sl := sell.get_node_or_null("SellLabel") as Label
		if sl:
			sl.add_theme_font_override("font", font_display_bold)
			sl.add_theme_font_size_override("font_size", 18)
			sl.add_theme_color_override("font_color", Color(1.0, 0.78, 0.62))
			sl.set_meta("_ui_sized", true)


# ── Fading hairline used by ornament() ─────────────────────────────────────────

class _FadeLine extends Control:
	var col: Color = Color.WHITE
	var flip: bool = false
	func _ready() -> void:
		mouse_filter = Control.MOUSE_FILTER_IGNORE
		resized.connect(queue_redraw)
	func _draw() -> void:
		var y := size.y * 0.5
		var n := 24
		for i in n:
			var t0 := float(i) / n
			var t1 := float(i + 1) / n
			var a := t1 if not flip else 1.0 - t0
			draw_line(Vector2(size.x * t0, y), Vector2(size.x * t1, y), Color(col, a * col.a), 1.0, true)
		# small diamond cap at the inner end
		var cx := size.x if not flip else 0.0
		var d := 3.0
		draw_colored_polygon(PackedVector2Array([
			Vector2(cx - d, y), Vector2(cx, y - d), Vector2(cx + d, y), Vector2(cx, y + d)]), col)
