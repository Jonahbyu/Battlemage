extends Node

# 0 = auto-detect, 1 = force mobile, -1 = force desktop
var override_mode: int = 0

const _SAVE_PATH := "user://ui_mode.json"

# Design resolution the UI is scaled from. Desktop and landscape phones use
# the project setting (1850x900). On a portrait phone that renders everything
# at ~20% size, so portrait uses a narrow base instead. 900 wide is the
# narrowest that still fits a full 7-unit board row. (Landscape can't go
# shorter: the arena's board/bench stack needs ~900px of height.)
const _MOBILE_PORTRAIT_BASE := Vector2i(900, 1600)
var _desktop_base := Vector2i.ZERO

# ── Android back button ───────────────────────────────────────────────────────
# quit_on_go_back is off in project.godot, so the back button lands here instead
# of killing the app. Order: a node in BACK_CLOSABLE (e.g. the Unit Manual) is
# freed; otherwise the current scene's handle_back() gets a chance; the main
# menu (no handle_back) quits. A scene whose handle_back() returns false simply
# ignores the press, so a stray back tap mid-run never throws you out.
const BACK_CLOSABLE := "back_closable"

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_GO_BACK_REQUEST:
		_on_back()

func _on_back() -> void:
	var tree := get_tree()
	var closable := tree.get_nodes_in_group(BACK_CLOSABLE)
	for i in range(closable.size() - 1, -1, -1):
		var n: Node = closable[i]
		if is_instance_valid(n) and not n.is_queued_for_deletion() 				and (not (n is CanvasItem) or (n as CanvasItem).is_visible_in_tree()):
			n.queue_free()
			return
	var scene := tree.current_scene
	if scene != null and scene.has_method("handle_back"):
		scene.call("handle_back")
		return
	tree.quit()

func _ready() -> void:
	if FileAccess.file_exists(_SAVE_PATH):
		var f := FileAccess.open(_SAVE_PATH, FileAccess.READ)
		if f != null:
			var data = JSON.parse_string(f.get_as_text())
			if data is Dictionary:
				override_mode = int(data.get("override", 0))
	_install_symbol_font()
	var window := get_tree().root
	_desktop_base = window.content_scale_size
	window.size_changed.connect(_apply_content_scale)
	_apply_content_scale()

# The web build has no system fonts to fall back on, so symbols like ⚙ ★ ▶
# render as empty boxes. Chain a bundled symbol font behind the default font.
func _install_symbol_font() -> void:
	var symbols := load("res://fonts/symbols_fallback.ttf") as Font
	var base := ThemeDB.fallback_font
	if symbols == null or base == null:
		return
	var fallbacks := base.fallbacks
	fallbacks.append(symbols)
	base.fallbacks = fallbacks

func _apply_content_scale() -> void:
	var window := get_tree().root
	var target := _desktop_base
	if is_mobile() and is_portrait():
		target = _MOBILE_PORTRAIT_BASE
	if window.content_scale_size != target:
		window.content_scale_size = target

func set_override(mode: int) -> void:
	override_mode = mode
	_apply_content_scale()
	var f := FileAccess.open(_SAVE_PATH, FileAccess.WRITE)
	if f != null:
		f.store_string(JSON.stringify({"override": mode}))

func is_portrait() -> bool:
	var win_size := DisplayServer.window_get_size()
	return win_size.y > win_size.x

func is_mobile() -> bool:
	if override_mode == 1:
		return true
	if override_mode == -1:
		return false
	return OS.has_feature("mobile") or OS.has_feature("web_android") or OS.has_feature("web_ios")

# Returns the mobile variant of a scene path if it exists, otherwise the desktop path.
# Mobile scene convention: "foo.tscn" → "foo_mobile.tscn"
func scene(desktop_path: String) -> String:
	if not is_mobile():
		return desktop_path
	var mobile_path := desktop_path.replace(".tscn", "_mobile.tscn")
	if ResourceLoader.exists(mobile_path):
		return mobile_path
	return desktop_path

func go(tree: SceneTree, desktop_path: String) -> void:
	tree.change_scene_to_file(scene(desktop_path))

# ── Touch-sized overlays ──────────────────────────────────────────────────────
# Shops and other pop-up screens are built in code at desktop sizes (11–22px
# text), which is unreadable once a phone scales the UI down. adapt_overlay()
# marks an overlay so that every control it has — and every control it adds
# later, since shops rebuild their rows on each refresh — gets bigger text and
# touch targets. In portrait, a BoxContainer tagged with the meta
# "mobile_stack" also flips from side-by-side columns to a vertical stack.

const _OVERLAY_GROUP := "mobile_overlay"
const _ADAPTED_META := "_mobile_adapted"

func adapt_overlay(root: Control) -> void:
	if not is_mobile():
		return
	root.add_to_group(_OVERLAY_GROUP)
	if not get_tree().node_added.is_connected(_on_node_added):
		get_tree().node_added.connect(_on_node_added)
	_adapt_subtree.call_deferred(root)

# Text multiplier. The portrait UI is drawn at ~0.43x on a typical phone, so
# 2.5x turns the shops' 12px text into ~13px on screen.
func overlay_scale() -> float:
	return 2.5 if is_portrait() else 1.6

func _on_node_added(node: Node) -> void:
	if not (node is Control):
		return
	var p := node.get_parent()
	# Content swapped into a de-scrolled ScrollContainer goes into its FitContainer.
	if p is ScrollContainer and p.has_meta(_UNSCROLLED_META) and not (node is FitContainer) 			and not (node is ScrollBar):
		_move_into_fit.call_deferred(p, node)
	while p != null:
		if p.is_in_group(_OVERLAY_GROUP):
			_adapt_control.call_deferred(node)
			return
		p = p.get_parent()

func _adapt_subtree(node: Variant) -> void:
	if not is_instance_valid(node):
		return
	if node is Control:
		_adapt_control(node)
	for child in (node as Node).get_children():
		_adapt_subtree(child)

func _adapt_control(c: Variant) -> void:
	if not is_instance_valid(c) or not (c is Control):
		return
	var ctrl := c as Control
	if ctrl.has_meta(_ADAPTED_META):
		return
	ctrl.set_meta(_ADAPTED_META, true)
	var f := overlay_scale()
	var portrait := is_portrait()
	var max_w := get_tree().root.content_scale_size.x * 0.9

	if ctrl is RichTextLabel:
		var rs := ctrl.get_theme_font_size("normal_font_size")
		ctrl.add_theme_font_size_override("normal_font_size", int(round(rs * f)))
		ctrl.add_theme_font_size_override("bold_font_size", int(round(rs * f)))
	elif ctrl is Label or ctrl is Button or ctrl is LineEdit:
		var fs := ctrl.get_theme_font_size("font_size")
		ctrl.add_theme_font_size_override("font_size", int(round(fs * f)))

	# Wrap long text instead of letting it run off the side of a narrow screen.
	# Only where the label is given the row's width — a wrapping label with no
	# width of its own collapses to one letter per line.
	if ctrl is Label and portrait:
		var lbl := ctrl as Label
		var parent := lbl.get_parent()
		var gets_width := parent is VBoxContainer \
			or (lbl.size_flags_horizontal & Control.SIZE_EXPAND) != 0
		if lbl.autowrap_mode == TextServer.AUTOWRAP_OFF and gets_width:
			lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			lbl.clip_text = false

	# Heights grow with the text; widths grow less so rows still fit across.
	if ctrl.custom_minimum_size != Vector2.ZERO:
		var ms := ctrl.custom_minimum_size * Vector2(minf(f, 1.5), f)
		ms.x = minf(ms.x, max_w)
		ctrl.custom_minimum_size = ms

	# Phones don't scroll: the list is fitted to the space instead.
	if ctrl is ScrollContainer and portrait and not ctrl.has_meta("keep_scroll"):
		_unscroll.call_deferred(ctrl)

	if ctrl is BoxContainer:
		var box := ctrl as BoxContainer
		box.add_theme_constant_override("separation",
			int(round(box.get_theme_constant("separation") * minf(f, 1.5))))
		if portrait and box.has_meta("mobile_stack") and not box.vertical:
			_stack_vertically.call_deferred(box)

	# The shops inset their main panel 40px from the screen edge; on a phone
	# that is space the content needs.
	if ctrl.is_in_group(_OVERLAY_GROUP):
		for child in ctrl.get_children():
			if child is Panel and (child as Panel).anchor_right == 1.0 \
					and (child as Panel).anchor_bottom == 1.0:
				var panel := child as Panel
				panel.offset_left = 8
				panel.offset_right = -8
				panel.offset_top = 16 if portrait else 8
				panel.offset_bottom = -16 if portrait else -8

# An HBoxContainer can't be switched to vertical, so swap in a VBoxContainer at
# the same spot and move the columns into it.
func _stack_vertically(box: Variant) -> void:
	if not is_instance_valid(box) or box.get_parent() == null:
		return
	var h := box as BoxContainer
	var v := VBoxContainer.new()
	v.set_meta(_ADAPTED_META, true)
	v.size_flags_horizontal = h.size_flags_horizontal
	v.size_flags_vertical = h.size_flags_vertical
	v.add_theme_constant_override("separation", h.get_theme_constant("separation"))
	var parent := h.get_parent()
	parent.add_child(v)
	parent.move_child(v, h.get_index())
	for child in h.get_children():
		h.remove_child(child)
		v.add_child(child)
		if child is Control:
			var col := child as Control
			col.custom_minimum_size.x = 0
			col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	parent.remove_child(h)
	h.queue_free()
	# Side by side, both columns share the full height. Stacked, an info column
	# that doesn't scroll should be as tall as its text, and the last column
	# (usually the scrolling list) takes whatever is left.
	var cols := v.get_children().filter(func(n): return n is Control)
	for i in range(cols.size() - 1):
		var col: Control = cols[i]
		if col is Container or col.get_child_count() == 0 or not (col.get_child(0) is Control):
			continue
		var content: Control = col.get_child(0)
		if _contains_scroll(content):
			continue
		col.size_flags_vertical = Control.SIZE_FILL
		var fit := func():
			if is_instance_valid(col) and is_instance_valid(content):
				col.custom_minimum_size.y = content.get_combined_minimum_size().y
		content.minimum_size_changed.connect(fit)
		col.set_meta("_fit_cb", [content, fit])
		fit.call()
	# If stacking leaves a list too cramped to read, switch to tabs instead.
	v.sort_children.connect(func(): _check_stack_overflow.call_deferred(v))
	_check_stack_overflow.call_deferred(v)

func _contains_scroll(n: Node) -> bool:
	if n is ScrollContainer:
		return true
	for child in n.get_children():
		if _contains_scroll(child):
			return true
	return false


# ── No scrolling on phones ───────────────────────────────────────────────────

const _UNSCROLLED_META := "_unscrolled"
const _TABBED_META := "_tabbed"
# Below this, stacked text is too small to read; use tabs instead.
const _STACK_MIN_SCALE := 0.9

# For screens that aren't adapt_overlay() overlays but still shouldn't scroll.
func no_scroll(scroll: ScrollContainer) -> void:
	if is_mobile() and is_portrait():
		_unscroll(scroll)

func _unscroll(sc: Variant) -> void:
	if not is_instance_valid(sc) or not (sc is ScrollContainer) or sc.has_meta(_UNSCROLLED_META):
		return
	var scroll := sc as ScrollContainer
	scroll.set_meta(_UNSCROLLED_META, true)
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	var fit := FitContainer.new()
	fit.set_meta(_ADAPTED_META, true)
	var kids := scroll.get_children().filter(func(n): return n is Control and not (n is ScrollBar))
	scroll.add_child(fit)
	for k in kids:
		_move_into_fit(scroll, k)

func _move_into_fit(scroll: Variant, node: Variant) -> void:
	if not is_instance_valid(scroll) or not is_instance_valid(node):
		return
	if (node as Node).get_parent() != scroll:
		return
	var fit: FitContainer = null
	for c in (scroll as Node).get_children():
		if c is FitContainer:
			fit = c
	if fit == null or node == fit:
		return
	(scroll as Node).remove_child(node)
	fit.add_child(node)
	if node is Control:
		(node as Control).size_flags_horizontal = Control.SIZE_EXPAND_FILL

func _min_fit_scale(n: Node) -> float:
	var m := 1.0
	if n is FitContainer and (n as Control).is_visible_in_tree():
		m = (n as FitContainer).fit_scale
	for c in n.get_children():
		m = minf(m, _min_fit_scale(c))
	return m

func _check_stack_overflow(v: Variant) -> void:
	if not is_instance_valid(v) or (v as Node).has_meta(_TABBED_META):
		return
	var box := v as Control
	if not box.is_visible_in_tree() or box.size.y < 1.0:
		return
	await get_tree().process_frame
	if not is_instance_valid(box) or box.has_meta(_TABBED_META):
		return
	var cols := box.get_children().filter(func(n): return n is Control)
	var need := 0.0
	for c: Control in cols:
		need += c.get_combined_minimum_size().y
	if _min_fit_scale(box) < _STACK_MIN_SCALE or need > box.size.y + 1.0:
		_tabify(box)

# Show one column at a time with a tab row above. The column with the most
# buttons (the one you act in) opens first.
func _tabify(box: Control) -> void:
	box.set_meta(_TABBED_META, true)
	var cols: Array = box.get_children().filter(func(n): return n is Control)
	if cols.size() < 2:
		return
	var bar := HBoxContainer.new()
	bar.set_meta(_ADAPTED_META, true)
	bar.add_theme_constant_override("separation", 10)
	box.add_child(bar)
	box.move_child(bar, 0)
	var group := ButtonGroup.new()
	var best := 0
	var best_buttons := -1
	for i in range(cols.size()):
		var col: Control = cols[i]
		if col.has_meta("_fit_cb"):
			var cb: Array = col.get_meta("_fit_cb")
			if is_instance_valid(cb[0]) and (cb[0] as Control).minimum_size_changed.is_connected(cb[1]):
				(cb[0] as Control).minimum_size_changed.disconnect(cb[1])
			col.remove_meta("_fit_cb")
		col.custom_minimum_size.y = 0
		col.size_flags_vertical = Control.SIZE_EXPAND_FILL
		var n := _count_buttons(col)
		if n > best_buttons:
			best_buttons = n
			best = i
		var b := Button.new()
		b.set_meta(_ADAPTED_META, true)
		b.toggle_mode = true
		b.button_group = group
		b.text = _tab_name(col, i)
		b.custom_minimum_size = Vector2(0, 76)
		b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		b.add_theme_font_size_override("font_size", 30)
		b.focus_mode = Control.FOCUS_NONE
		bar.add_child(b)
		b.toggled.connect(func(on: bool):
			if on:
				for j in range(cols.size()):
					if is_instance_valid(cols[j]):
						(cols[j] as Control).visible = j == i
				b.text = _tab_name(col, i))
	(bar.get_child(best) as Button).button_pressed = true

func _count_buttons(n: Node) -> int:
	var c := 1 if n is Button else 0
	for k in n.get_children():
		c += _count_buttons(k)
	return c

func _tab_name(col: Node, i: int) -> String:
	var t := _first_label(col)
	if t == "":
		return "Page %d" % (i + 1)
	t = t.split("
")[0].strip_edges()
	return t if t.length() <= 22 else t.substr(0, 20) + "…"

func _first_label(n: Node) -> String:
	if n is Label and (n as Label).text.strip_edges() != "":
		return (n as Label).text
	for c in n.get_children():
		var t := _first_label(c)
		if t != "":
			return t
	return ""
