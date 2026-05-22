class_name SpellTrigger

enum Trigger {
	ON_ATTACK       = 0,  # fires when a friendly unit attacks
	WHEN_ATTACKED   = 1,  # fires when a friendly unit is attacked
	DEATH_KNELL     = 2,  # fires when any friendly unit dies
	START_OF_COMBAT = 3,  # fires once at combat start
}

static func display_name(trigger: int) -> String:
	match trigger:
		Trigger.ON_ATTACK:       return "On Attack"
		Trigger.WHEN_ATTACKED:   return "When Attacked"
		Trigger.DEATH_KNELL:     return "Death Knell"
		Trigger.START_OF_COMBAT: return "Start of Combat"
	return ""

# Cost to add or upgrade a trigger from current_level to current_level+1
static func upgrade_cost(trigger: int, current_level: int) -> int:
	match trigger:
		Trigger.ON_ATTACK, Trigger.WHEN_ATTACKED:
			return 3 + current_level
		Trigger.DEATH_KNELL:
			return 4 + current_level
		Trigger.START_OF_COMBAT:
			return 5 + current_level
	return 99
