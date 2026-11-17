# Updater — Android only. Once per launch, asks GitHub for the newest release and, if it is
# newer than this install, offers to update. Releases come from .github/workflows/android.yml:
# each is tagged android-<build> and carries one APK. "Update" opens the APK link in the
# browser; Android downloads it and shows its own install screen. Saves live in user:// and
# survive the update because every release is signed with the same key.
extends Node

const LATEST := "https://api.github.com/repos/Jonahbyu/Battlemage/releases/latest"
const BuildInfo := preload("res://scripts/build_info.gd")

var _http: HTTPRequest

func _ready() -> void:
	if not OS.has_feature("android") or BuildInfo.BUILD <= 0:
		return
	_http = HTTPRequest.new()
	_http.timeout = 15.0
	add_child(_http)
	_http.request_completed.connect(_on_latest)
	_http.request(LATEST, PackedStringArray([
		"Accept: application/vnd.github+json", "User-Agent: Battlemage-Android"]))

# "android-42" -> 42; anything else -> -1
static func parse_build(tag: String) -> int:
	if not tag.begins_with("android-"):
		return -1
	var n := tag.substr(8)
	return n.to_int() if n.is_valid_int() else -1

func _on_latest(result: int, code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
	_http.queue_free()
	if result != HTTPRequest.RESULT_SUCCESS or code != 200:
		return
	var json = JSON.parse_string(body.get_string_from_utf8())
	if not (json is Dictionary):
		return
	if parse_build(str(json.get("tag_name", ""))) <= BuildInfo.BUILD:
		return
	for a in json.get("assets", []):
		if a is Dictionary and str(a.get("name", "")).ends_with(".apk"):
			_prompt(str(json.get("name", "")), str(a.get("browser_download_url", "")))
			return

func _prompt(release_name: String, apk_url: String) -> void:
	var layer := CanvasLayer.new()
	layer.layer = 100
	add_child(layer)

	var dim := ColorRect.new()
	dim.color = Color(0, 0, 0, 0.72)
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	layer.add_child(dim)

	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	layer.add_child(center)

	var panel := PanelContainer.new()
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.11, 0.11, 0.16)
	style.border_color = Color(1.0, 0.85, 0.30)
	style.set_border_width_all(2)
	style.set_corner_radius_all(10)
	style.set_content_margin_all(28)
	panel.add_theme_stylebox_override("panel", style)
	center.add_child(panel)

	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 16)
	box.custom_minimum_size = Vector2(560, 0)
	panel.add_child(box)

	var title := Label.new()
	title.text = "Update available"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 40)
	title.add_theme_color_override("font_color", Color(1.0, 0.85, 0.30))
	box.add_child(title)

	var sub := Label.new()
	sub.text = release_name
	sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	sub.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	sub.add_theme_font_size_override("font_size", 26)
	box.add_child(sub)

	var text := Label.new()
	text.text = "It downloads in your browser. Open the file when it finishes to install. Your saves are kept."
	text.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	text.add_theme_font_size_override("font_size", 24)
	text.add_theme_color_override("font_color", Color(0.70, 0.70, 0.80))
	box.add_child(text)

	var row := HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override("separation", 24)
	box.add_child(row)

	var yes := Button.new()
	yes.text = "Update"
	yes.custom_minimum_size = Vector2(220, 80)
	yes.add_theme_font_size_override("font_size", 30)
	yes.pressed.connect(func():
		layer.queue_free()
		OS.shell_open(apk_url))
	row.add_child(yes)

	var no := Button.new()
	no.text = "Later"
	no.custom_minimum_size = Vector2(220, 80)
	no.add_theme_font_size_override("font_size", 30)
	no.pressed.connect(func(): layer.queue_free())
	row.add_child(no)
