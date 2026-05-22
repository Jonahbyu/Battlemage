class_name MyconidEffect

enum Effect {
	NONE              = 0,
	SPOREKEEPER       = 1,  # T1: opens The Grove; each round, adjacent Myconids +1 Spore
	PARASITE          = 2,  # Token: spores transfer to adjacent Myconid on death
	SPORELING_ATTACK  = 3,  # T1: On attack, gain 1 spore (2 if Radiant)
	MYCO_CAP_AURA     = 4,  # T1 (Taunt): Start of Combat: spores give +1 extra +1/+1 for this fight (Radiant: +2)
	BLOOM_EOT         = 5,  # T2: End of turn: give each friendly Myconid 1 spore per Myconid on board
	SPORE_VENT_KNELL  = 6,  # T2: Death Knell: deal 1 damage per spore to a random enemy (Radiant: 2 dmg/spore)
	MYCELIUM_DEATH    = 7,  # T2: When a friendly Myconid dies: gain 2 spores (Radiant: 4)
	DECOMPOSER        = 8,  # T2: Whenever this gains a spore, gain 1 more (Radiant: 2); in and out of combat
	HYPHAE_SURGE      = 9,  # T2: Surge: give all friendly Myconids +1 spore
	SPOREFRONT_ATTACK = 10, # T3: On attack: every other friendly Myconid gains 1 spore (Radiant: 2)
	SPORE_HOARDER_SOC = 11, # T3: SOC: steal half the spores from each adjacent Myconid
	SPOREGUARD        = 12, # T3 (Taunt): at 10+ spores, gain Divine Shield; works in/out of combat
	MYCO_SAGE_KNELL   = 13, # T3: Death Knell: all friendly Myconids +1/+1 per spore this unit had
	CULTIVATOR_AURA      = 14, # T3: Aura: Parasites spawn with 2x spores (Radiant: 3x)
	SPORE_SOVEREIGN_AURA   = 15, # T4: Aura: overflow summons give their stats/spores to a random existing Parasite (or this unit if none)
	FUNGAL_ASCENDANT_KNELL = 16, # T4: Death Knell: permanently +1 spore buff level per living Myconid (Radiant: +2)
}
