class_name MyconidShopData
extends Resource

# Persistent spore pool — distributed freely between combats
var spore_pool: int = 0

# Sporulation: spores gained per round per starting Myconid. Starts 1.
var sporulation_rate: int = 1
var sporulation_purchases: int = 0

# Spore Buff: ATK+HP bonus per spore. Starts +1/+1, upgrades to +2/+2 etc.
var spore_buff_level: int = 1
var spore_buff_purchases: int = 0


func sporulation_cost() -> int:
	return 4 + sporulation_purchases * 2 + GameData.shop_cost_bonus


func spore_buff_cost() -> int:
	return 6 + spore_buff_purchases * 3 + GameData.shop_cost_bonus


func to_dict() -> Dictionary:
	return {
		"spore_pool": spore_pool,
		"sporulation_rate": sporulation_rate,
		"sporulation_purchases": sporulation_purchases,
		"spore_buff_level": spore_buff_level,
		"spore_buff_purchases": spore_buff_purchases,
	}


func from_dict(d: Dictionary) -> void:
	spore_pool = int(d.get("spore_pool", 0))
	sporulation_rate = int(d.get("sporulation_rate", 1))
	sporulation_purchases = int(d.get("sporulation_purchases", 0))
	spore_buff_level = int(d.get("spore_buff_level", 1))
	spore_buff_purchases = int(d.get("spore_buff_purchases", 0))
