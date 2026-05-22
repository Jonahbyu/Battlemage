class_name AztecEffect

enum Effect {
	NONE            = 0,
	SUN_PRIEST      = 1,  # Token: opens The Temple shop
	KILL_GOLD       = 2,  # Jade Gatherer: on kill, +1 gold (Radiant: +2)
	BLESSING_AURA   = 3,  # Golden Idol: +1 to blessing_rate while alive (Radiant: +2)
	TRIBUTE_SURGE   = 4,  # Sun Dancer: Surge: Blood Tribute without consuming round use
	SACRIFICE_SURGE = 5,  # Bloodletter: Surge: sacrifice a unit for 2x gold
	WARDEN_AURA     = 6,  # Temple Warden: SOC all friendly Aztecs get +2/+2 flat
	JAGUAR_BONUS    = 7,  # Sun Jaguar: SOC gains +1 ATK per 5 gold (on top of blessing)
	HIGH_PRIEST_AURA = 8, # High Priest: your blessing_rate is doubled while alive
}
