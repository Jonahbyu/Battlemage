class_name GoblinEffect

enum Effect {
	NONE             = 0,
	SUMMON_ON_ATTACK = 1,  # Mob Runt: on attack, summon a Peon
	PACK_LEADER_AURA = 2,  # Pack Leader: all other Goblins and Peons +2 ATK
	DEATH_BOMB       = 3,  # Scrap Bomber: on death, deal 2 dmg + summon a Peon
	BROOD_WITCH      = 4,  # On attack: give all friendly Peons +3/+3 this fight
	WARCHIEF_AURA    = 5,  # Aura: when any friendly Goblin dies, summon a replacement Peon
	DEATH_KNELL_CHAIN = 6, # Litter Lord: Death Knell: summon a Peon with Reborn
	DEATH_KNELL_ONCE  = 7, # Death Knell: summon a regular Peon (used by the chain Peon, no further recursion)
	STAT_BUDGET_SURGE = 8,   # Rabble Riser: Surge: permanently increase Peon stat budget by 2
	DOUBLE_BUDGET_AURA = 9,  # Taskmaster: aura: all Peons spawned use 2x stat budget
	DEATH_KNELL_PEON_BURST = 10, # Chaos Caller: Death Knell: summon 4 Peons at 2x budget (Radiant: 3x)
	DEATH_PEON_DAMAGE = 11,  # Bomb King: when a friendly Peon dies, deal 2 dmg to random enemy
	ATK_SKEW_AURA = 12,     # Rage Brand: SOC all Peons have ATK >= HP*1.25; new Peons inherit skew
	AVENGE_BUDGET = 13,        # Reckoner: Avenge 2 - permanently +1 Peon stat budget; Death Knell: summon a Peon
	WITCH_DOCTOR_BLESS   = 14, # Witch Doctor: prep-phase: choose Reborn or Taunt, then pick a friendly unit
	DEATH_KNELL_BUDGET = 15,   # Grub Grabber: Death Knell: permanently +1 Peon stat budget
	KILL_BUDGET = 16,          # Sneak: on kill, permanently +1 Peon stat budget
}
