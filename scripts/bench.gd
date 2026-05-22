class_name Bench
extends Control

const MAX_UNITS = 10

var units: Array = []

@onready var bench_label: Label = $VBox/BenchLabel
@onready var slots_container: HBoxContainer = $VBox/SlotsContainer


func add_unit(card: UnitCard) -> bool:
	if units.size() >= MAX_UNITS:
		return false
	units.append(card)
	slots_container.add_child(card)
	return true


func remove_unit_from_display(card: UnitCard) -> void:
	units.erase(card)
	if card.get_parent() == slots_container:
		slots_container.remove_child(card)


func get_unit_at_screen_pos(pos: Vector2) -> UnitCard:
	for card: UnitCard in units:
		if not is_instance_valid(card):
			continue
		if Rect2(card.global_position, card.size).has_point(pos):
			return card
	return null


func get_insert_index_for_x(screen_x: float) -> int:
	var children := slots_container.get_children()
	for i in children.size():
		var c := children[i] as Control
		if c == null:
			continue
		if c.global_position.x + c.size.x * 0.5 > screen_x:
			return i
	return children.size()


func get_unit_insert_idx_for_visual_idx(visual_idx: int) -> int:
	var children := slots_container.get_children()
	var count := 0
	for i in mini(visual_idx, children.size()):
		if children[i] is UnitCard:
			count += 1
	return count


func contains_screen_point(pos: Vector2) -> bool:
	return Rect2(global_position, size).has_point(pos)


func clear_units() -> void:
	for card in units.duplicate():
		if is_instance_valid(card):
			card.queue_free()
	units.clear()
