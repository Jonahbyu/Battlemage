class_name ElfShopData
extends Resource

var echo_stat_percent: int = 50
var max_echoes: int = 2
var echo_stat_purchases: int = 0
var max_echoes_purchases: int = 0


func echo_stat_cost() -> int:
	return 5 + echo_stat_purchases * 2 + GameData.shop_cost_bonus


func max_echoes_cost() -> int:
	return 5 + max_echoes_purchases * 2 + GameData.shop_cost_bonus


func to_dict() -> Dictionary:
	return {
		"echo_stat_percent": echo_stat_percent,
		"max_echoes": max_echoes,
		"echo_stat_purchases": echo_stat_purchases,
		"max_echoes_purchases": max_echoes_purchases,
	}


func from_dict(d: Dictionary) -> void:
	echo_stat_percent = int(d.get("echo_stat_percent", 50))
	max_echoes = int(d.get("max_echoes", 2))
	echo_stat_purchases = int(d.get("echo_stat_purchases", 0))
	max_echoes_purchases = int(d.get("max_echoes_purchases", 0))
