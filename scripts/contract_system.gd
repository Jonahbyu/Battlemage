class_name ContractSystem
extends RefCounted

# Contracts replace the old map. A contract is a quest tied to the current run
# ("win a fight with 6 Myconids", "upgrade a Human weapon to Lv.7") or an
# optional extra fight (bounty / side boss). See CONTRACTS_DESIGN.md.
#
# Turn index is 0-based: turns 0-11 are regular fights, turn 12 is the boss.

const LAST_REGULAR_TURN := 11
const BOSS_TURN := 12
const MAX_ACTIVE := 2
const SIDE_BOSS_MIN_TURN := 5   # side bosses offered once turn 6 (1-based) is next
const BOUNTY_DIFF_BONUS := 0.15
const SIDE_BOSS_DIFF_BONUS := 0.35

const FACTION_NAMES: Dictionary = {
	RaceType.Race.HUMAN: "Human",
	RaceType.Race.ELF: "Elf",
	RaceType.Race.MAGE: "Mage",
	RaceType.Race.GOBLIN: "Goblin",
	RaceType.Race.COVENANT: "Covenant",
	RaceType.Race.AZTEC: "Aztec",
	RaceType.Race.CONSTRUCT: "Construct",
	RaceType.Race.REAPER: "Reaper",
	RaceType.Race.MYCONID: "Myconid",
	RaceType.Race.SATYR: "Satyr",
}

const TIER_COLORS: Dictionary = {
	"small": Color(0.55, 0.80, 1.0),
	"medium": Color(0.45, 1.0, 0.6),
	"large": Color(1.0, 0.82, 0.2),
	"bounty": Color(1.0, 0.55, 0.35),
	"side_boss": Color(1.0, 0.3, 0.3),
}

const RELICS: Array = [
	{
		"id": "gold_bonus",
		"name": "Coin Purse",
		"desc": "Earn +4 gold after each combat victory.",
		"color": Color(1.0, 0.85, 0.2),
	},
	{
		"id": "hp_restore",
		"name": "Iron Rations",
		"desc": "Restore 8 HP after each battle won.",
		"color": Color(0.4, 1.0, 0.55),
	},
	{
		"id": "atk_aura",
		"name": "War Banner",
		"desc": "Your units start each combat with +2 ATK.",
		"color": Color(1.0, 0.5, 0.3),
	},
	{
		"id": "hp_aura",
		"name": "Ancestral Shield",
		"desc": "Your units start each combat with +10 max HP.",
		"color": Color(0.4, 0.65, 1.0),
	},
	{
		"id": "income_boost",
		"name": "Midas Touch",
		"desc": "Your gold income grows 1 extra unit per round.",
		"color": Color(1.0, 0.9, 0.15),
	},
	{
		"id": "extra_reroll",
		"name": "Lucky Clover",
		"desc": "+1 extra reroll on all discovery screens.",
		"color": Color(0.3, 1.0, 0.45),
	},
	{
		"id": "double_interest",
		"name": "Banker's Ledger",
		"desc": "Earn interest twice each round instead of once.",
		"color": Color(0.85, 0.7, 0.3),
	},
	{
		"id": "battle_hardened",
		"name": "Whetstone",
		"desc": "Winning 3 combats in a row permanently gives all board units +1 ATK.",
		"color": Color(0.7, 0.7, 0.8),
	},
]


# ── Difficulty ────────────────────────────────────────────────────────────────

static func difficulty_for_turn(turn: int) -> float:
	if turn >= BOSS_TURN:
		return 2.2
	if turn >= 11:
		return 1.5
	if turn >= 9:
		return 1.4
	if turn >= 7:
		return 1.3
	if turn >= 5:
		return 1.2
	if turn >= 3:
		return 1.1
	return 1.0


static func faction_name(race: int) -> String:
	return FACTION_NAMES.get(race, "Unit")


static func is_fight(c: Dictionary) -> bool:
	return c.get("goal", "") in ["bounty", "side_boss"]


# ── Offer generation ──────────────────────────────────────────────────────────

# snapshot keys: turn, faction_counts {race:int}, active_factions [race],
# best_weapon (int, -1 if no Human weapon), tier, gold, active [contracts]
static func generate_offers(snap: Dictionary) -> Array:
	var turn: int = snap.get("turn", 0)
	if turn >= LAST_REGULAR_TURN:
		return []
	var active: Array = snap.get("active", [])
	var factions: Array = snap.get("active_factions", [])
	if factions.is_empty():
		factions = FACTION_NAMES.keys()
	var counts: Dictionary = snap.get("faction_counts", {})
	var fights_left: int = LAST_REGULAR_TURN - turn

	var offers: Array = []

	# 1) Build: grow the faction you're playing most.
	var top_race := -1
	var top_count := 0
	for r in factions:
		var n: int = int(counts.get(r, 0))
		if n > top_count:
			top_count = n
			top_race = r
	if top_race < 0:
		top_race = factions.pick_random()
	var own := _faction_contract(top_race, top_count, false, turn, fights_left)
	if not own.is_empty():
		offers.append(own)

	# 2) Build: pivot faction / weapon / tier / triple.
	var picks: Array = []
	var others: Array = factions.filter(func(r): return r != top_race)
	if not others.is_empty():
		picks.append("pivot")
	var best_weapon: int = snap.get("best_weapon", -1)
	if best_weapon >= 1:
		picks.append("weapon")
	if int(snap.get("tier", 1)) < 4:
		picks.append("tier")
	picks.append("triple")
	picks.shuffle()
	for p in picks:
		var c: Dictionary = {}
		match p:
			"pivot":
				var pr: int = others.pick_random()
				c = _faction_contract(pr, int(counts.get(pr, 0)), true, turn, fights_left)
			"weapon":
				var gap := 2 if randf() < 0.5 else 3
				var target := maxi(best_weapon + gap, 4)
				c = _make("weapon_level", "medium" if gap == 2 else "large",
					target, _deadline(turn, 3 if gap == 2 else 4))
			"tier":
				c = _make("tier", "small", int(snap.get("tier", 1)) + 1, _deadline(turn, 3))
			"triple":
				c = _make("triple", "medium", 1, _deadline(turn, 4))
		if not c.is_empty() and not _duplicates(c, active + offers):
			offers.append(c)
			break

	# 3) Feat or optional fight.
	var has_bounty := active.any(func(a): return is_fight(a))
	var feats: Array = ["win_streak", "small_win", "gold_hold"]
	if not has_bounty:
		feats.append("bounty")
		feats.append("bounty")
		if turn >= SIDE_BOSS_MIN_TURN:
			feats.append("side_boss")
	feats.shuffle()
	for f in feats:
		var c: Dictionary = {}
		match f:
			"win_streak":
				var target := 3 if fights_left >= 4 and randf() < 0.5 else 2
				if fights_left < target:
					continue
				c = _make("win_streak", "medium" if target == 3 else "small",
					target, _deadline(turn, target + 1))
			"small_win":
				c = _make("small_win", "small", 4, _deadline(turn, 3))
			"gold_hold":
				var target := maxi(15, int(snap.get("gold", 0)) + 8)
				c = _make("gold_hold", "small", target, _deadline(turn, 3))
			"bounty":
				c = _make("bounty", "bounty", 1, turn + 1)
				c["race"] = factions.pick_random()
			"side_boss":
				c = _make("side_boss", "side_boss", 1, turn + 1)
				c["race"] = factions.pick_random()
		if not c.is_empty() and not _duplicates(c, active + offers):
			offers.append(c)
			break

	for c in offers:
		c["reward"] = _roll_reward(c, factions)
	return offers


static func _faction_contract(race: int, have: int, pivot: bool, turn: int, fights_left: int) -> Dictionary:
	var gap := 3 if pivot else (2 if randf() < 0.6 else 3)
	var target := clampi(have + gap, 3, 7)
	if target <= have:
		return {}
	var tier := "large" if pivot or target >= 6 else "medium"
	var c := _make("faction_win", tier, target, _deadline(turn, 4 if tier == "large" else 3))
	c["race"] = race
	return c


static func _make(goal: String, tier: String, target: int, deadline: int) -> Dictionary:
	return {
		"goal": goal,
		"tier": tier,
		"target": target,
		"deadline": deadline,
		"progress": 0,
		"race": -1,
		"state": "active",
	}


static func _deadline(turn: int, length: int) -> int:
	return mini(turn + length, LAST_REGULAR_TURN)


static func _duplicates(c: Dictionary, others: Array) -> bool:
	for o in others:
		if o.get("goal") == c.get("goal") and int(o.get("race", -1)) == int(c.get("race", -1)):
			return true
	return false


static func _roll_reward(c: Dictionary, factions: Array) -> Array:
	match c.get("tier", "small"):
		"small":
			return [[{"type": "gold", "amount": 8}, {"type": "hp", "amount": 10},
				{"type": "reroll", "amount": 1}].pick_random()]
		"medium":
			var race: int = int(c.get("race", -1))
			if race < 0:
				race = factions.pick_random()
			return [[{"type": "gold", "amount": 15}, {"type": "fortify", "amount": 1},
				{"type": "free_unit", "race": race}].pick_random()]
		"large":
			return [{"type": "relic"}]
		"bounty":
			return [[{"type": "gold", "amount": 12}, {"type": "fortify", "amount": 1}].pick_random()]
		"side_boss":
			return [{"type": "relic"}, {"type": "gold", "amount": 10}]
	return [{"type": "gold", "amount": 8}]


# ── Progress ──────────────────────────────────────────────────────────────────

# event: "win" | "loss" | "fight_start" | "triple" | "state"
# info: snapshot plus event extras (board_counts, board_size)
# Returns true when the contract is completed by this event.
static func on_event(c: Dictionary, event: String, info: Dictionary) -> bool:
	var target: int = c.get("target", 1)
	match c.get("goal", ""):
		"faction_win":
			if event == "win":
				var counts: Dictionary = info.get("board_counts", {})
				return int(counts.get(int(c.get("race", -1)), 0)) >= target
		"weapon_level":
			return int(info.get("best_weapon", -1)) >= target
		"tier":
			return int(info.get("tier", 1)) >= target
		"triple":
			if event == "triple":
				c["progress"] = int(c.get("progress", 0)) + 1
			return int(c.get("progress", 0)) >= target
		"win_streak":
			if event == "win":
				c["progress"] = int(c.get("progress", 0)) + 1
			elif event == "loss":
				c["progress"] = 0
			return int(c.get("progress", 0)) >= target
		"small_win":
			return event == "win" and int(info.get("board_size", 99)) <= target
		"gold_hold":
			return event == "fight_start" and int(info.get("gold", 0)) >= target
	return false


# ── Text ──────────────────────────────────────────────────────────────────────

static func kind_label(c: Dictionary) -> String:
	match c.get("goal", ""):
		"bounty":
			return "BOUNTY"
		"side_boss":
			return "SIDE BOSS"
		"win_streak", "small_win", "gold_hold":
			return "FEAT"
	return "BUILD"


static func title(c: Dictionary) -> String:
	var race_name := faction_name(int(c.get("race", -1)))
	match c.get("goal", ""):
		"faction_win":
			return "%s Muster" % race_name
		"weapon_level":
			return "Master Armorer"
		"tier":
			return "Climb the Ranks"
		"triple":
			return "Strength in Threes"
		"win_streak":
			return "Unbroken"
		"small_win":
			return "Few Against Many"
		"gold_hold":
			return "War Chest"
		"bounty":
			return "%s Raiders" % race_name
		"side_boss":
			return "%s Warlord" % race_name
	return "Contract"


static func goal_text(c: Dictionary) -> String:
	var t: int = c.get("target", 1)
	var race_name := faction_name(int(c.get("race", -1)))
	match c.get("goal", ""):
		"faction_win":
			return "Win a fight with %d %s units on your board." % [t, race_name]
		"weapon_level":
			return "Upgrade a Human weapon to Lv.%d." % t
		"tier":
			return "Reach shop tier %d." % t
		"triple":
			return "Make a triple."
		"win_streak":
			return "Win %d fights in a row." % t
		"small_win":
			return "Win a fight with %d or fewer units on your board." % t
		"gold_hold":
			return "Start a fight holding %d or more gold." % t
		"bounty":
			return "Extra fight against %s %s raiding party, right after your next fight." \
				% [_article(race_name), race_name]
		"side_boss":
			return "Extra fight against %s %s warlord, right after your next fight. Very tough." \
				% [_article(race_name), race_name]
	return ""


static func _article(word: String) -> String:
	return "an" if word.length() > 0 and word[0].to_lower() in ["a", "e", "i", "o", "u"] else "a"


static func deadline_text(c: Dictionary) -> String:
	if is_fight(c):
		return "After your next fight"
	return "By turn %d" % (int(c.get("deadline", 0)) + 1)


static func reward_text(c: Dictionary) -> String:
	var parts: Array = []
	for r: Dictionary in c.get("reward", []):
		parts.append(reward_item_text(r))
	return " + ".join(parts)


static func reward_item_text(r: Dictionary) -> String:
	match r.get("type", ""):
		"gold":
			return "+%d gold" % int(r.get("amount", 0))
		"hp":
			return "+%d HP" % int(r.get("amount", 0))
		"reroll":
			return "+%d reroll" % int(r.get("amount", 1))
		"fortify":
			return "Fortify a unit (+2 ATK, +4 HP)"
		"free_unit":
			return "Free %s unit" % faction_name(int(r.get("race", -1)))
		"relic":
			return "Choose a relic"
	return "?"


# Short status for the battle-screen tracker.
static func progress_text(c: Dictionary, snap: Dictionary) -> String:
	var t: int = c.get("target", 1)
	var s := ""
	match c.get("goal", ""):
		"faction_win":
			var counts: Dictionary = snap.get("faction_counts", {})
			s = "%s %d/%d" % [faction_name(int(c.get("race", -1))),
				int(counts.get(int(c.get("race", -1)), 0)), t]
		"weapon_level":
			s = "Weapon Lv.%d/%d" % [maxi(0, int(snap.get("best_weapon", 0))), t]
		"tier":
			s = "Tier %d/%d" % [int(snap.get("tier", 1)), t]
		"triple":
			s = "Triple %d/%d" % [int(c.get("progress", 0)), t]
		"win_streak":
			s = "Streak %d/%d" % [int(c.get("progress", 0)), t]
		"small_win":
			s = "Win with ≤%d units" % t
		"gold_hold":
			s = "Fight with %d/%d gold" % [int(snap.get("gold", 0)), t]
		"bounty", "side_boss":
			s = "%s: %s" % [title(c), "fight now" if c.get("state") == "ready" else "after next fight"]
			return s
	return "%s (by turn %d)" % [s, int(c.get("deadline", 0)) + 1]
