class_name AztecShopData
extends Resource

# How much ATK/HP each unit gains per gold saved at combat start
var blessing_rate: int = 1
var blessing_purchases: int = 0

# Gold gained per use of Blood Tribute (multiplied by player tier); costs 5 HP
var tribute_rate: int = 1
var tribute_purchases: int = 0

# Gold gained per tier of the sacrificed unit
var sacrifice_rate: int = 2
var sacrifice_purchases: int = 0


func blessing_cost() -> int:
	return 5 + blessing_purchases * 2


func tribute_cost() -> int:
	return 5 + tribute_purchases * 2


func sacrifice_cost() -> int:
	return 5 + sacrifice_purchases * 2


func tribute_gold(player_tier: int) -> int:
	return player_tier * tribute_rate


func to_dict() -> Dictionary:
	return {
		"blessing_rate": blessing_rate,
		"blessing_purchases": blessing_purchases,
		"tribute_rate": tribute_rate,
		"tribute_purchases": tribute_purchases,
		"sacrifice_rate": sacrifice_rate,
		"sacrifice_purchases": sacrifice_purchases,
	}


func from_dict(d: Dictionary) -> void:
	blessing_rate = int(d.get("blessing_rate", 1))
	blessing_purchases = int(d.get("blessing_purchases", 0))
	tribute_rate = int(d.get("tribute_rate", 1))
	tribute_purchases = int(d.get("tribute_purchases", 0))
	sacrifice_rate = int(d.get("sacrifice_rate", 2))
	sacrifice_purchases = int(d.get("sacrifice_purchases", 0))
