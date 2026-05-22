class_name ReaperEffect

enum Effect {
	NONE           = 0,
	GRAVEWARDEN    = 1,   # legacy shop-opener token
	WRAITH         = 2,   # T1: on attack apply 6 doom to target
	PALE_SHROUD    = 3,   # T1: aura — doomed enemies take +1 damage
	GRAVE_STALKER  = 4,   # T2: SOC apply 8 doom to 2 random enemies
	VOID_WRAITH    = 5,   # T2: on attack summon two 2/2 Shadow tokens
	PALE_REAPER    = 6,   # T2: death knell apply 10 doom to all enemies
	DREAD_SEER     = 7,   # T2: surge give board +5 max HP
	DOOM_HERALD    = 8,   # T2: end of turn increase doom damage by 10
	SHADE_STALKER  = 9,   # T2: surge gain Windfury
	WAIL_SPECTER   = 10,  # T3: on attack remove 3 doom from target (Windfury)
	DREAD_LORD     = 11,  # T3: each time doom is applied give board +5/+5
	GRAVE_COLLECTOR = 12, # T3: on attack apply 8 doom to target and adjacent
	SOUL_HARVESTER = 13,  # T3: on attack apply 5 doom; when doom expires +5/+5
	RIFT_CALLER    = 14,  # T3: avenge 2 reduce a random doom by 2
	DEATH_SOVEREIGN = 15, # T4: aura all friendly attacks tick doom by 2
	GRAVE_PACT     = 16,  # T4: SOC apply 10 doom to all units; friendly take 50% doom dmg
}
