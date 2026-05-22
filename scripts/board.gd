class_name Board
extends Control

var units: Array = []
var attack_dir: Vector2 = Vector2(0, -25)
var is_draggable: bool = false
var is_locked: bool = false

@onready var board_label: Label = $VBox/BoardLabel
@onready var slots_container: HBoxContainer = $VBox/SlotsContainer


func setup(is_player: bool) -> void:
	attack_dir = Vector2(0, -25) if is_player else Vector2(0, 25)
	board_label.text = "PLAYER" if is_player else "ENEMY"
	is_draggable = is_player


func add_unit(card: UnitCard) -> void:
	units.append(card)
	slots_container.add_child(card)
	card.attack_direction = attack_dir
	card.is_draggable = is_draggable


func remove_unit(card: UnitCard) -> void:
	units.erase(card)
	card.queue_free()


func clear_units() -> void:
	for card in units.duplicate():
		remove_unit(card)


func get_valid_targets() -> Array:
	var alive := units.filter(func(u): return not u.is_dead)
	var taunters := alive.filter(func(u):
		return (u.current_keywords & KeywordFlags.Keyword.TAUNT) != 0)
	if taunters.size() > 0:
		return taunters
	var visible := alive.filter(func(u):
		return (u.current_keywords & KeywordFlags.Keyword.STEALTH) == 0)
	return visible if visible.size() > 0 else alive


func has_living_units() -> bool:
	return units.any(func(u): return not u.is_dead)


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
