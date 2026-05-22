class_name SpellData
extends Resource

enum SpellType {
	NONE            = 0,
	EMBOLDEN        = 1,
	WILD_CALL       = 2,
	ARCANE_INFUSION = 3,  # permanent +1 ASP and +1 HSP
	WAR_SURGE       = 4,
	KINDRED_SEARCH  = 5,
	ARCANE_SNARE    = 6,  # apply 1 snare stack; each stack deals 1+ASP dmg whenever an enemy attacks
	BATTLE_TRANCE   = 7,
	MENDING_TOUCH   = 8,  # give random friendly +(1+ASP) ATK / +(1+HSP) HP
	NOVICE_BOLT     = 9,
	BOLSTER         = 10,
	FORTIFY         = 11,
	ARCANE_SURGE    = 12, # deal ASP+HSP damage to up to 3 random enemies
}

@export var display_name: String = "Spell"
@export var description: String = ""
@export var spell_type: int = SpellType.NONE
@export var tier: int = 1
@export var is_mage_only: bool = false
@export var buy_price: int = 3
