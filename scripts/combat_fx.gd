class_name CombatFX
extends RefCounted

# Cosmetic combat effects: particles, rings, slashes, tracers, floating
# numbers, banners and screen shake. Everything is spawned under the current
# scene, frees itself, and runs on scaled delta so it follows Engine.time_scale.
# Nothing here touches game state.

const Z_FX := 20
const Z_TEXT := 25


static func _host(ctx: Node) -> Node:
	if ctx == null or not ctx.is_inside_tree():
		return null
	return ctx.get_tree().current_scene


# ── Particle node ────────────────────────────────────────────────────────────

class Fx extends Node2D:
	enum Mode { BURST, RING, SLASH, TRACER, FLASH }
	var mode: int = Mode.BURST
	var life := 0.4
	var t := 0.0
	var color := Color.WHITE
	# BURST
	var parts: Array = []      # [pos, vel, size, rot, spin, color]
	var gravity := 0.0
	var drag := 3.0
	var square := false
	# RING / FLASH
	var radius := 40.0
	var width := 4.0
	# SLASH / TRACER
	var a := Vector2.ZERO
	var b := Vector2.ZERO
	var dir := Vector2.RIGHT

	func _ready() -> void:
		z_index = CombatFX.Z_FX
		z_as_relative = false

	func _process(delta: float) -> void:
		t += delta
		if t >= life:
			queue_free()
			return
		if mode == Mode.BURST:
			var damp := exp(-drag * delta)
			for p in parts:
				p[1] = p[1] * damp + Vector2(0, gravity * delta)
				p[0] += p[1] * delta
				p[3] += p[4] * delta
		queue_redraw()

	func _draw() -> void:
		var k := clampf(t / life, 0.0, 1.0)
		match mode:
			Mode.BURST:
				for p in parts:
					var c: Color = p[5]
					c.a *= 1.0 - k * k
					var s: float = p[2] * (1.0 - k * 0.7)
					if square:
						draw_set_transform(p[0], p[3], Vector2.ONE)
						draw_rect(Rect2(-s, -s * 0.6, s * 2.0, s * 1.2), c)
						draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
					else:
						draw_circle(p[0], s, c)
			Mode.RING:
				var e := 1.0 - pow(1.0 - k, 3.0)
				var c := color
				c.a *= 1.0 - k
				draw_arc(Vector2.ZERO, radius * (0.25 + 0.75 * e), 0.0, TAU, 40, c,
					maxf(1.0, width * (1.0 - k)), true)
			Mode.FLASH:
				var c := color
				c.a *= (1.0 - k) * 0.85
				draw_circle(Vector2.ZERO, radius * (0.6 + 0.4 * k), c)
			Mode.SLASH:
				# A crescent swipe that sweeps in then thins out.
				var sweep := clampf(k * 2.2, 0.0, 1.0)
				var fade := 1.0 - clampf((k - 0.35) / 0.65, 0.0, 1.0)
				var base_ang := dir.angle()
				var span := 2.0
				var a0 := base_ang - span * 0.5
				var a1 := a0 + span * sweep
				var steps := 14
				var c := color
				c.a *= fade
				if sweep < 0.02 or c.a <= 0.01:
					return
				var prev := Vector2.from_angle(a0) * radius
				for i in range(1, steps + 1):
					var f := float(i) / steps
					var p := Vector2.from_angle(lerpf(a0, a1, f)) * radius
					var thick := maxf(1.0, sin(f * PI) * width * fade)
					draw_line(prev, p, c, thick, true)
					prev = p
			Mode.TRACER:
				var head := clampf(k * 3.0, 0.0, 1.0)
				var tail := clampf((k - 0.15) * 1.6, 0.0, 1.0)
				var p0 := a.lerp(b, tail)
				var p1 := a.lerp(b, head)
				var c := color
				c.a *= 1.0 - k * 0.6
				draw_line(p0, p1, Color(c, c.a * 0.35), width * 2.6, true)
				draw_line(p0, p1, c, width, true)
				draw_line(p0, p1, Color(1, 1, 1, c.a), maxf(1.0, width * 0.4), true)


static func _add(ctx: Node, fx: Fx, pos: Vector2) -> Fx:
	var host := _host(ctx)
	if host == null:
		return null
	host.add_child(fx)
	fx.global_position = pos
	return fx


# ── Primitives ───────────────────────────────────────────────────────────────

static func burst(ctx: Node, pos: Vector2, colors: Array, count: int = 14,
		speed: float = 320.0, size: float = 4.0, life: float = 0.45,
		gravity: float = 600.0, dir: Vector2 = Vector2.ZERO, spread: float = TAU,
		square: bool = false) -> void:
	var fx := Fx.new()
	fx.mode = Fx.Mode.BURST
	fx.life = life
	fx.gravity = gravity
	fx.square = square
	var base_ang := dir.angle() if dir != Vector2.ZERO else 0.0
	for i in range(count):
		var ang := base_ang + randf_range(-spread * 0.5, spread * 0.5)
		var v := Vector2.from_angle(ang) * speed * randf_range(0.35, 1.0)
		var c: Color = colors[randi() % colors.size()]
		fx.parts.append([Vector2.ZERO, v, size * randf_range(0.6, 1.3),
			randf() * TAU, randf_range(-12.0, 12.0), c])
	_add(ctx, fx, pos)


static func ring(ctx: Node, pos: Vector2, color: Color, radius: float = 50.0,
		width: float = 5.0, life: float = 0.35) -> void:
	var fx := Fx.new()
	fx.mode = Fx.Mode.RING
	fx.color = color
	fx.radius = radius
	fx.width = width
	fx.life = life
	_add(ctx, fx, pos)


static func flash(ctx: Node, pos: Vector2, color: Color, radius: float = 26.0,
		life: float = 0.12) -> void:
	var fx := Fx.new()
	fx.mode = Fx.Mode.FLASH
	fx.color = color
	fx.radius = radius
	fx.life = life
	_add(ctx, fx, pos)


static func slash(ctx: Node, pos: Vector2, dir: Vector2, color: Color,
		radius: float = 46.0) -> void:
	var fx := Fx.new()
	fx.mode = Fx.Mode.SLASH
	fx.color = color
	# Swipe across the direction of travel.
	fx.dir = dir.rotated(PI * 0.5 * (1.0 if randf() < 0.5 else -1.0))
	fx.radius = radius
	fx.width = 9.0
	fx.life = 0.24
	_add(ctx, fx, pos - dir.normalized() * radius * 0.4)


static func tracer(ctx: Node, from: Vector2, to: Vector2, color: Color,
		width: float = 3.0, life: float = 0.16) -> void:
	var fx := Fx.new()
	fx.mode = Fx.Mode.TRACER
	fx.color = color
	fx.width = width
	fx.life = life
	fx.a = Vector2.ZERO
	fx.b = to - from
	_add(ctx, fx, from)


# ── Composite effects ────────────────────────────────────────────────────────

static func melee_impact(ctx: Node, pos: Vector2, dir: Vector2, tint: Color,
		heavy: bool = false) -> void:
	var n := dir.normalized()
	var hot := [Color(1, 1, 1), Color(1, 0.92, 0.6), Color(1, 0.7, 0.3), tint]
	flash(ctx, pos, Color(1, 1, 0.9), 34.0 if heavy else 24.0, 0.1)
	burst(ctx, pos, hot, 22 if heavy else 14, 520.0 if heavy else 380.0, 3.5,
		0.4, 500.0, n, PI * 0.9)
	ring(ctx, pos, Color(1, 0.95, 0.8, 0.9), 60.0 if heavy else 42.0, 5.0, 0.3)
	slash(ctx, pos, n, Color(1, 1, 1, 0.9), 44.0 if heavy else 36.0)


static func shot_impact(ctx: Node, pos: Vector2, dir: Vector2) -> void:
	var sparks := [Color(1, 0.95, 0.7), Color(1, 0.75, 0.3), Color(1, 0.5, 0.2)]
	flash(ctx, pos, Color(1, 0.9, 0.6), 16.0, 0.08)
	burst(ctx, pos, sparks, 9, 340.0, 2.5, 0.3, 700.0, dir.normalized(), PI * 0.8)


static func muzzle(ctx: Node, pos: Vector2, dir: Vector2) -> void:
	flash(ctx, pos, Color(1, 0.85, 0.4), 18.0, 0.08)
	burst(ctx, pos, [Color(1, 0.95, 0.7), Color(1, 0.6, 0.2)], 6, 260.0, 2.5,
		0.18, 0.0, dir.normalized(), 0.7)
	burst(ctx, pos, [Color(0.6, 0.6, 0.6, 0.5)], 4, 60.0, 6.0, 0.5, -60.0,
		dir.normalized(), 1.2)


static func shatter(ctx: Node, rect: Rect2, tint: Color) -> void:
	var c := rect.get_center()
	var cols := [tint, tint.lightened(0.3), tint.darkened(0.3), Color(0.9, 0.9, 0.95)]
	burst(ctx, c, cols, 26, 420.0, 7.0, 0.7, 900.0, Vector2.UP, TAU, true)
	burst(ctx, c, [Color(1, 1, 1, 0.8), Color(0.8, 0.8, 0.85, 0.6)], 10, 120.0,
		9.0, 0.6, -80.0)
	ring(ctx, c, Color(1, 1, 1, 0.8), rect.size.x * 0.75, 6.0, 0.4)


static func shield_break(ctx: Node, pos: Vector2, radius: float) -> void:
	var gold := [Color(1, 0.95, 0.55), Color(1, 0.85, 0.3), Color(1, 1, 0.85)]
	burst(ctx, pos, gold, 24, 380.0, 5.0, 0.55, 700.0, Vector2.ZERO, TAU, true)
	ring(ctx, pos, Color(1, 0.9, 0.4), radius, 7.0, 0.4)
	flash(ctx, pos, Color(1, 0.95, 0.6), radius * 0.6, 0.12)


static func sparkle_up(ctx: Node, rect: Rect2, color: Color, count: int = 12) -> void:
	var fx := Fx.new()
	fx.mode = Fx.Mode.BURST
	fx.life = 0.7
	fx.gravity = -220.0
	fx.drag = 2.0
	for i in range(count):
		var p := Vector2(randf_range(-rect.size.x * 0.4, rect.size.x * 0.4),
			randf_range(0.0, rect.size.y * 0.4))
		var v := Vector2(randf_range(-30, 30), randf_range(-120, -40))
		var c := color.lightened(randf_range(0.0, 0.4))
		fx.parts.append([p, v, randf_range(2.0, 4.0), 0.0, 0.0, c])
	_add(ctx, fx, rect.get_center())


# ── Floating text ────────────────────────────────────────────────────────────

static func number(ctx: Node, pos: Vector2, text: String, color: Color,
		big: bool = false) -> void:
	var host := _host(ctx)
	if host == null:
		return
	var l := Label.new()
	l.text = text
	l.add_theme_font_size_override("font_size", 34 if big else 26)
	l.add_theme_color_override("font_color", color)
	l.add_theme_color_override("font_outline_color", Color(0.05, 0.02, 0.02))
	l.add_theme_constant_override("outline_size", 8)
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	l.z_index = Z_TEXT
	l.z_as_relative = false
	host.add_child(l)
	l.size = l.get_minimum_size()
	l.pivot_offset = l.size * 0.5
	var start := pos - l.size * 0.5 + Vector2(randf_range(-10, 10), 0)
	l.global_position = start
	l.scale = Vector2(0.4, 0.4)
	var tw := l.create_tween()
	tw.set_parallel(true)
	tw.tween_property(l, "scale", Vector2(1.25, 1.25) if big else Vector2.ONE, 0.12) \
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tw.tween_property(l, "global_position", start + Vector2(0, -54), 0.75) \
		.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tw.tween_property(l, "modulate:a", 0.0, 0.3).set_delay(0.5)
	tw.chain().tween_callback(l.queue_free)


static func banner(ctx: Node, text: String, color: Color, hold: float = 0.45) -> void:
	var host := _host(ctx)
	if host == null or not (host is Control):
		return
	var l := Label.new()
	l.text = text
	l.add_theme_font_size_override("font_size", 72)
	l.add_theme_color_override("font_color", color)
	l.add_theme_color_override("font_outline_color", Color(0.05, 0.03, 0.02))
	l.add_theme_constant_override("outline_size", 14)
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	l.z_index = Z_TEXT
	l.z_as_relative = false
	host.add_child(l)
	l.size = l.get_minimum_size()
	l.pivot_offset = l.size * 0.5
	var vp := (host as Control).get_viewport_rect().size
	l.global_position = vp * 0.5 - l.size * 0.5
	l.scale = Vector2(2.6, 2.6)
	l.modulate.a = 0.0
	var tw := l.create_tween()
	tw.set_parallel(true)
	tw.tween_property(l, "scale", Vector2.ONE, 0.16) \
		.set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_IN)
	tw.tween_property(l, "modulate:a", 1.0, 0.1)
	tw.chain().tween_callback(func(): shake(ctx, 9.0, 0.2))
	tw.chain().tween_interval(hold)
	tw.chain().set_parallel(true)
	tw.tween_property(l, "scale", Vector2(1.15, 1.15), 0.2)
	tw.tween_property(l, "modulate:a", 0.0, 0.2)
	tw.chain().tween_callback(l.queue_free)


# ── Screen shake ─────────────────────────────────────────────────────────────

static func shake(ctx: Node, strength: float = 6.0, duration: float = 0.18) -> void:
	var host := _host(ctx)
	if host == null or not (host is CanvasItem):
		return
	var ci := host as CanvasItem
	if not ci.has_meta("fx_shake_base"):
		ci.set_meta("fx_shake_base", host.get("position"))
	var base: Vector2 = ci.get_meta("fx_shake_base")
	var prev = ci.get_meta("fx_shake_tween") if ci.has_meta("fx_shake_tween") else null
	if prev is Tween and (prev as Tween).is_valid():
		(prev as Tween).kill()
	var tw := ci.create_tween()
	ci.set_meta("fx_shake_tween", tw)
	var steps := maxi(3, int(duration / 0.03))
	for i in range(steps):
		var falloff := 1.0 - float(i) / steps
		var off := Vector2(randf_range(-1, 1), randf_range(-1, 1)) * strength * falloff
		tw.tween_property(host, "position", base + off, duration / steps)
	tw.tween_property(host, "position", base, 0.03)
	tw.tween_callback(func():
		if is_instance_valid(ci):
			ci.remove_meta("fx_shake_base")
			ci.remove_meta("fx_shake_tween"))
