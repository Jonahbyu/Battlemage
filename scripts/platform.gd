extends Node

# 0 = auto-detect, 1 = force mobile, -1 = force desktop
var override_mode: int = 0

const _SAVE_PATH := "user://ui_mode.json"

# Design resolution the UI is scaled from. Desktop and landscape phones use
# the project setting (1850x900). On a portrait phone that renders everything
# at ~20% size, so portrait uses a narrow base instead. (Landscape can't go
# shorter: the arena's board/bench stack needs ~900px of height.)
const _MOBILE_PORTRAIT_BASE := Vector2i(720, 1280)
var _desktop_base := Vector2i.ZERO

func _ready() -> void:
	if FileAccess.file_exists(_SAVE_PATH):
		var f := FileAccess.open(_SAVE_PATH, FileAccess.READ)
		if f != null:
			var data = JSON.parse_string(f.get_as_text())
			if data is Dictionary:
				override_mode = int(data.get("override", 0))
	var window := get_tree().root
	_desktop_base = window.content_scale_size
	window.size_changed.connect(_apply_content_scale)
	_apply_content_scale()

func _apply_content_scale() -> void:
	var window := get_tree().root
	var target := _desktop_base
	if is_mobile():
		var win_size := DisplayServer.window_get_size()
		if win_size.y > win_size.x:
			target = _MOBILE_PORTRAIT_BASE
	if window.content_scale_size != target:
		window.content_scale_size = target

func set_override(mode: int) -> void:
	override_mode = mode
	_apply_content_scale()
	var f := FileAccess.open(_SAVE_PATH, FileAccess.WRITE)
	if f != null:
		f.store_string(JSON.stringify({"override": mode}))

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
