class_name CovenantShopData
extends Resource

var bond_share_percent: int = 50
var berserk_multiplier_percent: int = 0
var bond_share_purchases: int = 0
var berserk_purchases: int = 0
var gold_invested: int = 0


func bond_share_cost() -> int:
	return 5 + bond_share_purchases * 2 + GameData.shop_cost_bonus


func berserk_cost() -> int:
	return 5 + berserk_purchases * 2 + GameData.shop_cost_bonus


func reset() -> void:
	bond_share_percent -= bond_share_purchases * 10
	berserk_multiplier_percent -= berserk_purchases * 10
	bond_share_purchases = 0
	berserk_purchases = 0
	gold_invested = 0


func to_dict() -> Dictionary:
	return {
		"bond_share_percent": bond_share_percent,
		"berserk_multiplier_percent": berserk_multiplier_percent,
		"bond_share_purchases": bond_share_purchases,
		"berserk_purchases": berserk_purchases,
		"gold_invested": gold_invested,
	}


func from_dict(d: Dictionary) -> void:
	bond_share_percent = int(d.get("bond_share_percent", 50))
	berserk_multiplier_percent = int(d.get("berserk_multiplier_percent", 0))
	bond_share_purchases = int(d.get("bond_share_purchases", 0))
	berserk_purchases = int(d.get("berserk_purchases", 0))
	gold_invested = int(d.get("gold_invested", 0))
