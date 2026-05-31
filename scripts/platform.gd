extends Node

# 0 = auto-detect, 1 = force mobile, -1 = force desktop
var override_mode: int = 0

const _SAVE_PATH := "user://ui_mode.json"

func _ready() -> void:
	if FileAccess.file_exists(_SAVE_PATH):
		var f := FileAccess.open(_SAVE_PATH, FileAccess.READ)
		if f != null:
			var data = JSON.parse_string(f.get_as_text())
			if data is Dictionary:
				override_mode = int(data.get("override", 0))

func set_override(mode: int) -> void:
	override_mode = mode
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
