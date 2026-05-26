class_name ReaperShopData
extends Resource

# Doom Damage: damage dealt when doom reaches 0. Starts 100, +25 per purchase.
var doom_damage: int = 100
var damage_purchases: int = 0

# Reaper Aura: +N/+N per total doom counter on field. 0 = not yet purchased.
var reaper_aura_bonus: int = 0
var aura_purchases: int = 0

var gold_invested: int = 0


func damage_cost() -> int:
	return 7 + GameData.shop_cost_bonus


func aura_cost() -> int:
	return (10 if aura_purchases == 0 else 5) + GameData.shop_cost_bonus


func reset() -> void:
	doom_damage -= damage_purchases * 25
	reaper_aura_bonus -= aura_purchases
	damage_purchases = 0
	aura_purchases = 0
	gold_invested = 0


func to_dict() -> Dictionary:
	return {
		"doom_damage": doom_damage,
		"damage_purchases": damage_purchases,
		"reaper_aura_bonus": reaper_aura_bonus,
		"aura_purchases": aura_purchases,
		"gold_invested": gold_invested,
	}


func from_dict(d: Dictionary) -> void:
	doom_damage = int(d.get("doom_damage", 100))
	damage_purchases = int(d.get("damage_purchases", 0))
	reaper_aura_bonus = int(d.get("reaper_aura_bonus", 0))
	aura_purchases = int(d.get("aura_purchases", 0))
	gold_invested = int(d.get("gold_invested", 0))
