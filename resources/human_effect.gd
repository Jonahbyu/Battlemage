class_name HumanEffect

enum Effect {
	NONE                 = 0,  # Grunt
	DEATH_KNELL_FIRE     = 1,  # Gunslinger
	ON_FRIENDLY_DEATH_ATK = 2, # Recruit
	SNIPER_BONUS         = 3,  # Sharpshooter
	UPGRADE_DISCOUNT     = 4,  # Arms Dealer
	COUNTER_FIRE         = 5,  # Brawler
	SHOTGUN_BONUS        = 6,  # Demolitionist
	MACHINEGUN_BONUS     = 7,  # Gunner
	COMMANDER_AURA       = 8,  # Commander
	WEAPON_LEVEL_SURGE   = 9,  # Breacher/Ranger/Heavy: surge gives own weapon +2 levels (radiant: +4)
	DOUBLE_FIRE_AURA     = 10, # Aura: all friendly guns fire twice
	GUN_UPGRADE_SURGE    = 11, # Surge: give a friendly human +1 weapon level
	DUAL_WIELD           = 12, # Fires both equipped and backpack weapon; both gain levels on upgrade
	COST_REDUCTION_SURGE = 13, # Surge: next weapon buy or upgrade costs 2 less gold
}
