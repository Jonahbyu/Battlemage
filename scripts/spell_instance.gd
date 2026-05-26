class_name SpellInstance
extends RefCounted

var spell_data: SpellData
# SpellTrigger.Trigger (int) -> fire count (int)
var triggers: Dictionary = {}
var gold_invested: int = 0


func _init(data: SpellData) -> void:
	spell_data = data


func get_fire_count(trigger: int) -> int:
	return int(triggers.get(trigger, 0))


func has_any_trigger() -> bool:
	for t in triggers:
		if int(triggers[t]) > 0:
			return true
	return false


func upgrade_trigger(trigger: int) -> void:
	triggers[trigger] = int(triggers.get(trigger, 0)) + 1


func reset_triggers() -> void:
	triggers.clear()
	gold_invested = 0


func get_upgrade_cost(trigger: int) -> int:
	return SpellTrigger.upgrade_cost(trigger, int(triggers.get(trigger, 0)))


func describe_triggers() -> String:
	if triggers.is_empty():
		return "No triggers"
	var parts: Array[String] = []
	for t: int in [SpellTrigger.Trigger.ON_ATTACK, SpellTrigger.Trigger.WHEN_ATTACKED,
			SpellTrigger.Trigger.DEATH_KNELL, SpellTrigger.Trigger.START_OF_COMBAT]:
		var lvl: int = int(triggers.get(t, 0))
		if lvl > 0:
			parts.append("%s Lv.%d" % [SpellTrigger.display_name(t), lvl])
	return "  |  ".join(parts)
