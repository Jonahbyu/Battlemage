extends Node

const SAVE_PATH   := "user://game_data.json"
const SLOT_COUNT  := 5
const MAX_BATTLES := 25

const MAX_DIFFICULTY := 10

var _data: Dictionary = {
	"slots": [null, null, null, null, null],
	"gauntlet": {
		# Each field stores a full slot-data Dictionary (board + shops + resources).
		"last_winning_slot": null,
		"champion_slot":     null,
	},
	"history": [],
	"difficulty_level": 0,
	"max_unlocked_difficulty": 0,
}

# ── Difficulty ────────────────────────────────────────────────────────────────

var difficulty_level: int:
	get: return int(_data.get("difficulty_level", 0))
	set(v): _data["difficulty_level"] = v

var max_unlocked_difficulty: int:
	get: return int(_data.get("max_unlocked_difficulty", 0))
	set(v): _data["max_unlocked_difficulty"] = v

var sell_threshold: int:
	get: return 4 if difficulty_level >= 1 else 3

var shop_cost_bonus: int:
	get: return (1 if difficulty_level >= 2 else 0) + (1 if difficulty_level >= 7 else 0)

var discovery_rerolls: int:
	get: return 2 if difficulty_level >= 3 else 3

var tier_cost_mult: float:
	get: return 1.2 if difficulty_level >= 4 else 1.0

var discovery_reduction: int:
	get: return (1 if difficulty_level >= 5 else 0) + (1 if difficulty_level >= 8 else 0)

var starting_player_hp: int:
	get: return 75 if difficulty_level >= 6 else 100

var enemy_hp_mult: float:
	get: return 1.0 + (0.2 if difficulty_level >= 9 else 0.0)

var enemy_atk_mult: float:
	get: return 1.0 + (0.2 if difficulty_level >= 10 else 0.0)


func unlock_next_difficulty() -> void:
	if difficulty_level >= max_unlocked_difficulty:
		max_unlocked_difficulty = mini(difficulty_level + 1, MAX_DIFFICULTY)
		save()


func set_difficulty(level: int) -> void:
	difficulty_level = clampi(level, 0, max_unlocked_difficulty)
	save()


# ── Runtime flags (not persisted) ─────────────────────────────────────────────
var current_slot: int = -1

# Gauntlet runtime state
var gauntlet_mode:  bool = false
var gauntlet_stage: int  = 0   # 0 = vs last_winning, 1 = vs champion
var gauntlet_player_wins: int = 0
var gauntlet_enemy_wins:  int = 0
var gauntlet_player_slot: Dictionary = {}   # full slot dict for the challenging board


func _ready() -> void:
	_load()


# ── Persistence ───────────────────────────────────────────────────────────────

func _load() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		return
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		return
	var parsed = JSON.parse_string(file.get_as_text())
	file.close()
	if not (parsed is Dictionary):
		return
	var slots = parsed.get("slots", [])
	if slots is Array:
		for i in range(mini(SLOT_COUNT, slots.size())):
			_data["slots"][i] = slots[i]
	var g = parsed.get("gauntlet", {})
	if g is Dictionary:
		for k in g:
			_data["gauntlet"][k] = g[k]
	var h = parsed.get("history", [])
	if h is Array:
		_data["history"] = h
	_data["difficulty_level"] = int(parsed.get("difficulty_level", 0))
	_data["max_unlocked_difficulty"] = int(parsed.get("max_unlocked_difficulty", 0))


func save() -> void:
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(_data))
		file.close()


# ── Slot API ──────────────────────────────────────────────────────────────────

func get_slot(idx: int) -> Variant:
	if idx < 0 or idx >= SLOT_COUNT:
		return null
	return _data["slots"][idx]


func set_slot(idx: int, slot_data: Dictionary) -> void:
	if idx < 0 or idx >= SLOT_COUNT:
		return
	_data["slots"][idx] = slot_data
	save()


func clear_slot(idx: int) -> void:
	if idx < 0 or idx >= SLOT_COUNT:
		return
	_data["slots"][idx] = null
	save()


# ── Gauntlet API ──────────────────────────────────────────────────────────────

func has_gauntlet_data() -> bool:
	return _data["gauntlet"].get("last_winning_slot") != null


func has_champion() -> bool:
	return _data["gauntlet"].get("champion_slot") != null


func get_gauntlet_opponent_slot() -> Dictionary:
	var key := "last_winning_slot" if gauntlet_stage == 0 else "champion_slot"
	var s = _data["gauntlet"].get(key)
	return s if s is Dictionary else {}


func get_gauntlet_opponent_board() -> Array:
	var s := get_gauntlet_opponent_slot()
	var b = s.get("board", [])
	return b if b is Array else []


func record_winning_run(slot_data: Dictionary) -> void:
	_data["gauntlet"]["last_winning_slot"] = slot_data
	save()


func record_champion(slot_data: Dictionary) -> void:
	_data["gauntlet"]["champion_slot"] = slot_data
	save()


func begin_gauntlet(player_slot: Dictionary) -> void:
	gauntlet_mode        = true
	gauntlet_stage       = 0
	gauntlet_player_wins = 0
	gauntlet_enemy_wins  = 0
	gauntlet_player_slot = player_slot


# ── History API ───────────────────────────────────────────────────────────────

func add_history(entry: Dictionary) -> void:
	_data["history"].push_front(entry)
	if _data["history"].size() > 50:
		_data["history"].resize(50)
	save()


func get_history() -> Array:
	return _data["history"]
