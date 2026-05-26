class_name WeaponData
extends Resource

enum WeaponType {
	PISTOL      = 0,
	SHOTGUN     = 1,
	SNIPER      = 2,
	MACHINE_GUN = 3,
}

@export var weapon_type: int = WeaponType.PISTOL
@export var display_name: String = "Pistol"
@export var buy_price: int = 2
@export var level: int = 0
@export var base_damage: int = 2
@export var base_shots: int = 1  # machine gun uses 3

var gold_invested: int = 0


func get_total_damage() -> int:
	var total := base_damage
	for k in range(1, level + 1):
		total += _bonus_at_level(k)
	return total


func get_total_shots() -> int:
	if weapon_type != WeaponType.MACHINE_GUN:
		return 1
	var bonus: int = 0
	for i in range(1, level + 1):
		bonus += i
	return base_shots + bonus


func get_splash_damage() -> int:
	if weapon_type != WeaponType.SHOTGUN:
		return 0
	return max(1, get_total_damage() >> 1)


func get_upgrade_cost() -> int:
	var n := level + 1
	if weapon_type == WeaponType.PISTOL:
		# 3, 6, 10, 15, 21... formula: n*(n+3)/2 + 1
		return (n * (n + 3) >> 1) + 1
	# shotgun/sniper/mg: 5, 10, 18, 29... formula: n*(3n+1)/2 + 3
	return (n * (3 * n + 1) >> 1) + 3


func get_sell_value() -> int:
	if gold_invested > 0:
		return floori(gold_invested * 0.75)
	return 2 + level


func _bonus_at_level(k: int) -> int:
	match weapon_type:
		WeaponType.PISTOL:
			# +2, +5, +9, +14, +20... formula: k*(k+3)/2
			return k * (k + 3) >> 1
		WeaponType.SHOTGUN:
			# +3, +6, +11, +20, +37... formula: 2^k + k
			return int(pow(2, k)) + k
		WeaponType.SNIPER:
			# +4, +8, +15, +28, +53... formula: 3 * 2^(k-1) + k
			return int(3 * pow(2, k - 1)) + k
		WeaponType.MACHINE_GUN:
			return 0  # upgrades add shots, not damage
	return 0
