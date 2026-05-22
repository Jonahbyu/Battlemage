class_name MageEffect

enum Effect {
	NONE              = 0,
	SPELLBINDER       = 1,  # removed
	RUNECALLER        = 2,  # Surge: discover a spell to equip and immediately cast (permanent)
	SPELL_POWER_SURGE = 3,  # Surge: permanently +1 ASP and +1 HSP
	VITALITY_SURGE    = 4,  # removed
	DAMAGE_SURGE      = 5,  # removed
	SPELL_FEEDER      = 6,  # Passive: board gets +1/+1 each time any spell fires
	TRIGGER_BOOST     = 7,  # Combat aura: all spell triggers fire +1 extra while alive (Channeler)
	SPELL_DOUBLER     = 8,  # Aura: doubles first trigger of each type (Hexweaver)
	SURGE_TRIGGER_UP  = 9,  # Surge: +1 level on a random trigger on a random allied Mage (Spellwright)
	SURGE_KEYWORD     = 10, # removed
	SPELL_POWER_AURA  = 11, # Aura: +1 ASP while alive (Novice)
	ON_ATTACK_BOOST   = 12, # removed
	ECHO_CASTER       = 13, # Avenge 2: re-cast the last triggered spell the same number of times it fired
	FAMILIAR          = 14, # Passive: gains +1/+1 whenever any spell fires (temp in combat, perm outside)
	DEATH_KNELL_GOLD  = 15, # Death Knell: generate 1 gold coin (Coin Sage)
	DEATH_KNELL_HSP   = 16, # Death Knell: permanently +1 HSP (Warden)
	RUNIC_SCRIBE      = 17, # Death Knell: +1 level on a random trigger on a random friendly Mage
}
