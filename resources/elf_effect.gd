class_name ElfEffect

enum Effect {
	NONE                 = 0,
	DEATH_KNELL_ECHO     = 1,  # Elf Scout: on death, gain Echo
	WHEN_ATTACKED_BUFF   = 2,  # Thornguard: when attacked, give a random other friendly unit +1/+1
	ECHO_ADJACENT_BUFF   = 3,  # Spiritbark: SOC: echo both adjacent units and give them +2/+2 permanently
	ON_KILL_STATS        = 4,  # Verdant Archer: on kill: permanently +3/+3
	SURGE_ECHO_STAT      = 5,  # Moonsong: surge: permanently +5% to echo_stat_percent
	ON_ATTACK_BUFF_ECHOED = 6, # Fernweave: on attack: give all echoed friendly units +2/+2 permanently
	DOUBLE_NEXT_ECHO     = 7,  # Soul Tender: the next unit to enter the echo pool spawns at double echo stats (temp, this combat only)
	THORNBORN_GROWTH     = 8,  # Thornborn: live +1/+1 each time any friendly dies; counter persists across run
	DEATH_KNELL_DIVINE_ECHO = 9,  # Dreamhunter: death knell: give a random echoed unit Divine Shield
	DEATH_KNELL_BUFF_ECHOED = 10, # Pale Warden: death knell: all echoed units permanently +4/+4
	AVENGE_BUFF_BOARD    = 11, # Ashveil: avenge 1: give all surviving friendly units +1/+1 permanently
	SURGE_ECHO_UNIT         = 12, # Root Caller: surge: give a target unit Echo + permanently +5/+5
	SOC_DOUBLE_ECHO_STAT    = 13, # The Dreamer: SOC: double echo_stat_percent for this combat (fires once, unit need not survive)
	DEATH_KNELL_SUMMON_ECHO = 14, # Ancient Grove: Echo; death knell: summon a copy of a random echo pool unit into wave 1 (unit stays in pool, still spawns in wave 2)
}
