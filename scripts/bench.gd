class_name Bench
extends Control

const MAX_UNITS = 10

var units: Array = []

@onready var bench_label: Label = $VBox/BenchLabel
@onready var slots_container: HFlowContainer = $VBox/SlotsContainer

# Bench height for one row of cards; a portrait phone can't fit 10 cards in
# one row, so the bench grows to two rows there.
var _one_row_height: float = 0.0


func _ready() -> void:
	_one_row_height = custom_minimum_size.y
	get_viewport().size_changed.connect(_update_rows)
	_update_rows()


func _update_rows() -> void:
	var two_rows := Platform.is_mobile() and Platform.is_portrait()
	custom_minimum_size.y = _one_row_height * 2.0 if two_rows else _one_row_height
	slots_container.add_theme_constant_override("h_separation", 10 if Platform.is_mobile() else 24)


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


func get_insert_index_for_x(screen_x: float, screen_y: float = NAN) -> int:
	var children := slots_container.get_children()
	for i in children.size():
		var c := children[i] as Control
		if c == null:
			continue
		if not is_nan(screen_y):
			# Cards wrap onto rows: skip rows above the drop point, and stop at
			# the first card of a row below it.
			if c.global_position.y + c.size.y < screen_y:
				continue
			if c.global_position.y > screen_y:
				return i
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
