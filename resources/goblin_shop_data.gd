class_name GoblinShopData
extends Resource

var stat_budget: int = 7
var reborn_chance: int = 0
var divine_shield_chance: int = 0
var poisonous_chance: int = 0
var taunt_chance: int = 0
var windfury_chance: int = 0


func roll_peon() -> Dictionary:
	return roll_peon_with_budget(stat_budget)


func roll_peon_with_budget(budget: int) -> Dictionary:
	var b := maxi(2, budget)
	var atk := randi_range(1, b - 1)
	var hp := b - atk
	var kw := 0
	if randf() < float(reborn_chance) / 100.0:
		kw |= KeywordFlags.Keyword.REBORN
	if randf() < float(divine_shield_chance) / 100.0:
		kw |= KeywordFlags.Keyword.DIVINE_SHIELD
	if randf() < float(poisonous_chance) / 100.0:
		kw |= KeywordFlags.Keyword.POISONOUS
	if randf() < float(taunt_chance) / 100.0:
		kw |= KeywordFlags.Keyword.TAUNT
	if randf() < float(windfury_chance) / 100.0:
		kw |= KeywordFlags.Keyword.WINDFURY
	return {"atk": atk, "hp": hp, "keywords": kw}


func to_dict() -> Dictionary:
	return {
		"stat_budget": stat_budget,
		"reborn_chance": reborn_chance,
		"divine_shield_chance": divine_shield_chance,
		"poisonous_chance": poisonous_chance,
		"taunt_chance": taunt_chance,
		"windfury_chance": windfury_chance,
	}


func from_dict(d: Dictionary) -> void:
	stat_budget = int(d.get("stat_budget", 7))
	reborn_chance = int(d.get("reborn_chance", 0))
	divine_shield_chance = int(d.get("divine_shield_chance", 0))
	poisonous_chance = int(d.get("poisonous_chance", 0))
	taunt_chance = int(d.get("taunt_chance", 0))
	windfury_chance = int(d.get("windfury_chance", 0))
