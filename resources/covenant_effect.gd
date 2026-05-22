class_name CovenantEffect

enum Effect {
	NONE         = 0,
	TETHER       = 1,   # SOC: Bond adjacent ally
	SEEKER       = 2,   # SOC: Bond ally with highest ATK
	PACT_KIN     = 3,   # On attack: +2 HP perm; if bonded also +2 ATK perm
	FURY_KIN     = 4,   # Berserk bonus doubled for this unit
	WEAVE_KIN    = 5,   # End of turn: permanently +5% bond share (global)
	OATH_BINDER  = 6,   # Surge: Bond self to target ally
	BOND_WARDEN  = 7,   # Aura: all bonded units gain +3/+3 at SOC
	MARTYR_KIN   = 8,   # Death Knell: give this unit's stats to a bonded unit
	RITE_HERALD  = 9,   # When a friendly attacks, board +2/+2 (combat-only)
	VOW_GUARD    = 10,  # Aura: berserk grants Divine Shield
	BOND_SHATTER = 11,  # When a bond breaks, board +5/+5 (combat-only)
	RITE_SAGE    = 12,  # Surge: permanently +5% berserk multiplier
	SOUL_TETHER  = 13,  # SOC: Bond adjacent ally AND adjacent enemy
	CHAIN_HUNTER = 14,  # On attack: Bond target; cascade kill = berserk + attack again
	GRIEF_KIN    = 15,  # Avenge 2: Bond a random friendly unit
	RITE_SPAWNER = 16,  # On attack: Summon+Bond Covenantling (2/2), it attacks first
}
