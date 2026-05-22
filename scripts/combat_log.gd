extends Control

const MAX_ENTRIES := 60

@onready var scroll: ScrollContainer = $ScrollContainer
@onready var content: VBoxContainer = $ScrollContainer/Content


func append_entry(text: String) -> void:
	if content.get_child_count() >= MAX_ENTRIES:
		content.get_child(0).queue_free()
	var label := Label.new()
	label.text = text
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	content.add_child(label)
	await get_tree().process_frame
	scroll.scroll_vertical = int(scroll.get_v_scroll_bar().max_value)
