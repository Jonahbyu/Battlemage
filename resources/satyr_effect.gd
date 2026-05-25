class_name SatyrEffect

enum Effect {
	NONE   = 0,
	CRIMSON = 1,  # T1: on death, deals damage to a random enemy
	GOLD    = 2,  # T1: grants +ATK to all allies while alive
	SILVER  = 3,  # T1: targets highest-HP enemy, deals bonus damage
	GREEN   = 4,  # T1: deathknell passes +X/+X to next unit and chains
	BLACK   = 5,  # T1: swarm; each hit debuffs a random enemy's ATK%
	CRIMSON_T2 = 6,  # T2: Reborn; death knell permanently increases crimson_damage by 1
	GOLD_T2    = 7,  # T2: death knell increases prismatic_percent by 5%
	SILVER_T2  = 8,  # T2: Moon Striker — Divine Shield + Windfury, targets highest-HP
	GREEN_T2   = 9,  # T2: death knell summons 2 Green Satyrs
	BLACK_T2   = 10, # T2: end of turn, permanently increases black_debuff_percent by 5
	CRIMSON_T3 = 11, # T3: death knell deals crimson_damage to 2 random enemies (3 total with passive)
	GOLD_T3    = 12, # T3: for every 2 ATK given by gold aura, also give 1 HP
	SILVER_T3  = 13, # T3: on attack, give all satyrs +2/+2 per Silver Satyr on board
	GREEN_T3   = 14, # T3: Reborn; death knell permanently increases green_stat_bonus by 1
	BLACK_T3   = 15, # T3: on attack, apply black debuff to both enemies adjacent to the target
	PRISMATIC_T4 = 16, # T4: whenever any friendly satyr dies, summon a random color satyr token in its place
	BLACK_T4   = 17, # T4: whenever any friendly satyr attacks, apply black debuff to that target
	GOLD_T4    = 18, # T4: each Silver Satyr on board also counts as a Gold Satyr for aura purposes
	GREEN_T4   = 19, # T4: when a Green Satyr dies, resummon it at full current stats (max 2x per fight)
	CRIMSON_T4 = 20, # T4: each time this unit deals damage, permanently gain +3/+3
	SILVER_T4  = 21, # T4: after each kill by any friendly, permanently give the whole board +3/+3
}
