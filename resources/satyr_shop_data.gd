class_name SatyrShopData
extends Resource

# Crimson (Sacrifice): on death, deals damage to a random enemy. Base 5, +5 per purchase.
var crimson_damage: int = 5
var crimson_purchases: int = 0

# Gold (Glory): while alive, grants +X ATK to all allies. Base 1, +1 per purchase.
var gold_atk_bonus: int = 1
var gold_purchases: int = 0

# Silver (The Hunt): deals bonus damage to the highest-HP target. Base 5, +5 per purchase.
var silver_bonus_damage: int = 5
var silver_purchases: int = 0

# Green (The Grove): deathknell passes +X/+X to another unit and chains. Base 1, +1 per purchase.
var green_stat_bonus: int = 1
var green_purchases: int = 0

# Black (Forbidden Rites): when hit, debuffs a random enemy's ATK by X%. Base 10%, +10% per purchase.
var black_debuff_percent: int = 10
var black_purchases: int = 0

# Prismatic: board stats +X% per color alive. Base 20%, +5% per purchase. Dynamic.
var prismatic_percent: int = 20
var prismatic_purchases: int = 0

var gold_invested: int = 0


func crimson_cost() -> int:
	return 4 + crimson_purchases * 2 + GameData.shop_cost_bonus


func gold_cost() -> int:
	return 4 + gold_purchases * 2 + GameData.shop_cost_bonus


func silver_cost() -> int:
	return 4 + silver_purchases * 2 + GameData.shop_cost_bonus


func green_cost() -> int:
	return 4 + green_purchases * 2 + GameData.shop_cost_bonus


func black_cost() -> int:
	return 4 + black_purchases * 2 + GameData.shop_cost_bonus


func prismatic_cost() -> int:
	return 6 + prismatic_purchases * 2 + GameData.shop_cost_bonus


func reset() -> void:
	crimson_damage -= crimson_purchases * 5
	gold_atk_bonus -= gold_purchases
	silver_bonus_damage -= silver_purchases * 5
	green_stat_bonus -= green_purchases
	black_debuff_percent -= black_purchases * 10
	prismatic_percent -= prismatic_purchases * 5
	crimson_purchases = 0
	gold_purchases = 0
	silver_purchases = 0
	green_purchases = 0
	black_purchases = 0
	prismatic_purchases = 0
	gold_invested = 0


func to_dict() -> Dictionary:
	return {
		"crimson_damage": crimson_damage,
		"crimson_purchases": crimson_purchases,
		"gold_atk_bonus": gold_atk_bonus,
		"gold_purchases": gold_purchases,
		"silver_bonus_damage": silver_bonus_damage,
		"silver_purchases": silver_purchases,
		"green_stat_bonus": green_stat_bonus,
		"green_purchases": green_purchases,
		"black_debuff_percent": black_debuff_percent,
		"black_purchases": black_purchases,
		"prismatic_percent": prismatic_percent,
		"prismatic_purchases": prismatic_purchases,
		"gold_invested": gold_invested,
	}


func from_dict(d: Dictionary) -> void:
	crimson_damage = int(d.get("crimson_damage", 5))
	crimson_purchases = int(d.get("crimson_purchases", 0))
	gold_atk_bonus = int(d.get("gold_atk_bonus", 1))
	gold_purchases = int(d.get("gold_purchases", 0))
	silver_bonus_damage = int(d.get("silver_bonus_damage", 5))
	silver_purchases = int(d.get("silver_purchases", 0))
	green_stat_bonus = int(d.get("green_stat_bonus", 1))
	green_purchases = int(d.get("green_purchases", 0))
	black_debuff_percent = int(d.get("black_debuff_percent", 10))
	black_purchases = int(d.get("black_purchases", 0))
	prismatic_percent = int(d.get("prismatic_percent", 20))
	prismatic_purchases = int(d.get("prismatic_purchases", 0))
	gold_invested = int(d.get("gold_invested", 0))
