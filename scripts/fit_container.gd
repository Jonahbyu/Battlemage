class_name FitContainer
extends Container

# Phone replacement for scrolling: lays its one child out at the container's
# width and, if the child is still taller than the space, scales it down
# uniformly until it fits. Asks for no minimum size of its own, so it never
# pushes the screen past its edges. Scaled controls still take touch input
# normally.

const MIN_SCALE := 0.55

var fit_scale := 1.0
var _sorting := false


func _init() -> void:
	clip_contents = true
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	size_flags_vertical = Control.SIZE_EXPAND_FILL


func _get_minimum_size() -> Vector2:
	return Vector2.ZERO


func _notification(what: int) -> void:
	if what == NOTIFICATION_SORT_CHILDREN:
		_fit()


func _fit() -> void:
	if _sorting or size.x < 1.0 or size.y < 1.0:
		return
	_sorting = true
	for c in get_children():
		if not (c is Control) or not (c as Control).visible:
			continue
		var ctrl := c as Control
		# Wrapped text gets shorter as it gets wider, so re-measure a few times.
		var s := 1.0
		for i in range(4):
			var w := size.x / s
			fit_child_in_rect(ctrl, Rect2(Vector2.ZERO, Vector2(w, ctrl.get_combined_minimum_size().y)))
			var m := ctrl.get_combined_minimum_size()
			# Too wide for the screen counts too: shrink so nothing is cut off.
			var want := clampf(minf(size.y / maxf(m.y, 1.0), size.x / maxf(m.x, 1.0)), MIN_SCALE, 1.0)
			if is_equal_approx(want, s):
				break
			s = want
		var final_h := maxf(ctrl.get_combined_minimum_size().y, size.y / s)
		fit_child_in_rect(ctrl, Rect2(Vector2.ZERO, Vector2(size.x / s, final_h)))
		ctrl.pivot_offset = Vector2.ZERO
		ctrl.scale = Vector2(s, s)
		fit_scale = s
	_sorting = false
