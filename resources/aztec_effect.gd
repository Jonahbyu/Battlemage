class_name AztecEffect

enum Effect {
	NONE             = 0,
	GILDED_MARTYR    = 1,  # T1: Death Knell — deal 1 dmg per gold held to random enemy
	BLOOD_WITNESS    = 2,  # T1: when any friendly is sacrificed, permanently +2/+2 (Radiant: +4/+4)
	TRIBUTE_HUNTER   = 3,  # T1: on kill, gain 1 gold (Radiant: +2)
	ANOINTED_VESSEL  = 4,  # T2: gives 2x gold when sacrificed (stacks with Aztec race 2x → 4x total)
	SUN_IDOL         = 5,  # T2: aura — +1 blessing rate while alive (Radiant: +2)
	BLOOD_FEAST      = 6,  # T2: when any friendly is sacrificed, permanently gain its current ATK+HP
	SACRIFICE_SCOUT  = 7,  # T2: surge — target and sacrifice another unit (doesn't consume round flag)
	VAULT_KEEPER     = 8,  # T2: end of turn in combat — gain 1 gold per bench unit
	GOLD_EFFIGY      = 9,  # T3: Death Knell — deal dmg equal to gold held to random enemy
	TITHE_WARDEN     = 10, # T3: aura — all friendly units gain +1 gold on kill
	SUN_SEEKER       = 11, # T3: surge — if you own another Aztec, discover a random Aztec unit
	THE_DEVOURER     = 12, # T3: permanently gains +4/+4 for each sacrifice or tribute this run
	BLOOD_FONT       = 13, # T3: off-board — grants 1 free Blood Tribute per shop phase (Radiant: 2)
	GOLDEN_SOVEREIGN = 14, # T4: aura — doubles gold count for blessing calculation while alive
	THE_STARVED      = 15, # T4: gains +1/+1 per player HP missing at combat start; receives full blessing
	SUN_HERALD       = 16, # T4: Death Knell — summon a Gold Idol token (1/1 Aztec, 2x blessing)
	GOLD_IDOL_TOKEN  = 17, # Token: receives 2x the normal Aztec blessing bonus
}
