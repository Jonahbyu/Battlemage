class_name ConstructEffect

enum Effect {
	NONE            = 0,
	WINDER          = 1,  # T1 token: opens The Coilworks; at SOC, adjacent Constructs +2 Charge
	CAPACITOR       = 2,  # T1: SOC: gain 1 Charge per friendly Construct in play
	VOLT_STRIKER    = 3,  # T1: counter strike deals 2 dmg per spent Charge instead of 1
	REIGNITER       = 4,  # T1: when Depowered, regain 3 Charge once per combat
	COIL_WEAVER     = 5,  # T2: Battlecry: all Constructs gain +1 SOC Charge permanently
	IRON_SENTINEL   = 6,  # T2: Taunt + Divine Shield; when attacked gain 3 Charge
	ARC_COIL        = 7,  # T2: Death Knell: give peak Charge this combat to a random adjacent Construct
	ACCUMULATOR     = 8,  # T2: end of round, gain +3 persistent Charge
	DISCHARGE_ENGINE = 9, # T2: when any friendly Construct loses a Charge point, board +1 ATK
	SURGE_CONDUIT   = 10, # T3: Battlecry: give all friendly Constructs +3 persistent Charge
	CHARGE_SIPHON   = 11, # T3: when another friendly Construct loses Charge, permanently gain +1/+1 per point
	OVERLOAD_CORE   = 12, # T3: Aura: when a friendly Construct is Depowered, give it +10/+10 (this combat)
	MELTDOWN        = 13, # T3: Death Knell: board +3 Charge (Constructs) and +3/+3 permanently (all)
	RELAY_NODE          = 14, # T3: Taunt; Death Knell: trigger a random adjacent unit's Battlecry
	GRAND_CAPACITOR     = 15, # T4: SOC: gain 1 Charge per Charge point among all friendly Constructs
	RECHARGE_PROTOCOL   = 16, # T4: Aura: first time each Construct would Depower per combat, gain 5 Charge instead
	FISSION_CORE        = 17, # T4: Death Knell: give all friendly units +1/+1 permanently per peak Charge this unit reached this combat
}
