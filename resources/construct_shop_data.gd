class_name ConstructShopData
extends Resource

# Charge Cache: Constructs start combat with N bonus Charge. 0 base, +3 per purchase.
var charge_cache: int = 0
var cache_purchases: int = 0

# Recoil: when a Construct is hit, gain +N Charge (if not depowered). Starts at 1, +1 per purchase.
var recoil_charge: int = 1
var recoil_purchases: int = 0

# Resonance: when any friendly attacks, all Constructs gain +N Charge. Starts inactive (0).
var resonance_charge: int = 0
var resonance_purchases: int = 0


func cache_cost() -> int:
	return 5 + cache_purchases * 2 + GameData.shop_cost_bonus


func recoil_cost() -> int:
	return 4 + recoil_purchases * 2 + GameData.shop_cost_bonus


func resonance_cost() -> int:
	return 5 + resonance_purchases * 2 + GameData.shop_cost_bonus


func to_dict() -> Dictionary:
	return {
		"charge_cache": charge_cache,
		"cache_purchases": cache_purchases,
		"recoil_charge": recoil_charge,
		"recoil_purchases": recoil_purchases,
		"resonance_charge": resonance_charge,
		"resonance_purchases": resonance_purchases,
	}


func from_dict(d: Dictionary) -> void:
	charge_cache = int(d.get("charge_cache", 0))
	cache_purchases = int(d.get("cache_purchases", 0))
	recoil_charge = int(d.get("recoil_charge", 1))
	recoil_purchases = int(d.get("recoil_purchases", 0))
	resonance_charge = int(d.get("resonance_charge", 0))
	resonance_purchases = int(d.get("resonance_purchases", 0))
