class_name CombatManager
extends Node

@export var unit_card_scene: PackedScene

var player_board: Board
var enemy_board: Board
var log_node: Control
var result_banner: Label
var fight_button: Button
var continue_button: Button

signal combat_ended(player_damage: int)
signal relay_surge_requested(candidates: Array)

var player_attacks_next: bool = false
var is_running: bool = false

var _player_slot_idx: int = 0
var _enemy_slot_idx: int = 0

var active_spells: Array = []
var asp: int = 1          # Attack Spell Power
var hsp: int = 1          # Healing Spell Power
var _snare_stacks: int = 0
var _last_spell_cast: SpellData = null
var _last_spell_fire_count: int = 0
var pending_gold_reward: int = 0   # accumulated by Coin Sage death knells, read by combat_arena
var pending_hsp_bonus: int = 0     # accumulated by Warden death knells, read by combat_arena
var pending_permanent_stats: Dictionary = {}  # UnitCard → Vector2i(atk, hp) — read by combat_arena
var support_card: UnitCard = null
var goblin_shop_data: GoblinShopData = null
var aztec_shop_data: AztecShopData = null
var aztec_gold: int = 0
var aztec_player_hp: int = 100
var aztec_bench_count: int = 0
var construct_shop_data: ConstructShopData = null
var reaper_shop_data: ReaperShopData = null
var myconid_shop_data: MyconidShopData = null
var elf_shop_data: ElfShopData = null
var covenant_shop_data: CovenantShopData = null

# Enemy-side equivalents — created by combat_arena._build_enemy_shop_data()
var enemy_goblin_shop_data: GoblinShopData = null
var enemy_aztec_shop_data: AztecShopData = null
var enemy_aztec_gold: int = 0
var enemy_construct_shop_data: ConstructShopData = null
var enemy_reaper_shop_data: ReaperShopData = null
var enemy_myconid_shop_data: MyconidShopData = null
var enemy_elf_shop_data: ElfShopData = null
var enemy_covenant_shop_data: CovenantShopData = null

# Covenant: tracks last killer per dead unit for berserk targeting
var _unit_killers: Dictionary = {}  # dead UnitCard -> killer UnitCard

# Elf / Echo pool
var _echo_pool: Array = []               # Array of {data, attack, health, keywords, double_mult}
var _echo_wave_used: bool = false
var _next_echo_mult: float = 1.0
var _soc_echo_stat_mult: float = 1.0

var _myco_cap_soc_bonus: int = 0             # set at start of combat by Myco Cap; held for full fight

var _construct_atk_applied: Dictionary = {}  # UnitCard → int (ATK bonus applied this combat)
var _doom_counters: Dictionary = {}          # enemy UnitCard → int
var _friendly_doom_counters: Dictionary = {} # friendly UnitCard → int (from Grave Pact)
var _reaper_aura_applied: Dictionary = {}    # UnitCard → int (ATK/HP bonus applied from aura)
var _spore_bonus_applied: Dictionary = {}    # UnitCard → int (ATK+HP bonus applied from spores)

# Myconid: last unit to die (for post-combat 75% retention on loss)
var _last_myconid_spores: int = 0
var _last_myconid_path: String = ""
var _last_myconid_is_parasite: bool = false

const MYCONID_PARASITE_PATH := "res://resources/units/myconids/parasite.tres"

var _avenge_counters: Dictionary = {}      # UnitCard → int, counts deaths toward Avenge threshold
var _goblin_summon_uses: Dictionary = {}   # UnitCard → int, reset each combat

var satyr_shop_data: SatyrShopData = null
var enemy_satyr_shop_data: SatyrShopData = null
var _satyr_gold_aura_applied: Dictionary = {}  # UnitCard → int (total ATK bonus from Gold auras)
var _eternal_grove_spawns: Dictionary = {}     # String path → int (times resummoned this fight)

const MAX_BOARD_SIZE := 7
const GOBLIN_PEON_PATH := "res://resources/units/goblins/goblin_peon.tres"
const GOBLIN_PEON_CHAIN_PATH := "res://resources/units/goblins/goblin_peon_chain.tres"
const GREEN_SATYR_PATH := "res://resources/units/satyrs/green_satyr.tres"
const SATYR_TOKEN_PATHS: Dictionary = {
	1: "res://resources/units/satyrs/crimson_token.tres",
	2: "res://resources/units/satyrs/gold_token.tres",
	3: "res://resources/units/satyrs/silver_token.tres",
	4: "res://resources/units/satyrs/green_token.tres",
	5: "res://resources/units/satyrs/black_token.tres",
}


func setup(
		p_board: Board,
		e_board: Board,
		log_panel: Control,
		banner: Label,
		fight_btn: Button,
		continue_btn: Button) -> void:
	player_board = p_board
	enemy_board = e_board
	log_node = log_panel
	result_banner = banner
	fight_button = fight_btn
	continue_button = continue_btn


func start_combat() -> void:
	if is_running:
		return
	is_running = true
	_last_spell_cast = null
	_last_spell_fire_count = 0
	_snare_stacks = 0
	pending_gold_reward = 0
	pending_hsp_bonus = 0
	_avenge_counters.clear()
	_goblin_summon_uses.clear()
	_satyr_gold_aura_applied.clear()
	_eternal_grove_spawns.clear()
	_unit_killers.clear()
	for card in player_board.units:
		if is_instance_valid(card):
			card.bonded_units.clear()
	for card in enemy_board.units:
		if is_instance_valid(card):
			card.bonded_units.clear()
	_construct_atk_applied.clear()
	pending_permanent_stats.clear()
	_doom_counters.clear()
	_friendly_doom_counters.clear()
	_reaper_aura_applied.clear()
	_spore_bonus_applied.clear()
	_myco_cap_soc_bonus = 0
	_last_myconid_spores = 0
	_last_myconid_path = ""
	_last_myconid_is_parasite = false
	_echo_pool.clear()
	_echo_wave_used = false
	_next_echo_mult = 1.0
	_soc_echo_stat_mult = 1.0
	fight_button.visible = false
	_player_slot_idx = 0
	_enemy_slot_idx = 0
	var p_count := player_board.units.size()
	var e_count := enemy_board.units.size()
	if p_count > e_count:
		player_attacks_next = true
	elif e_count > p_count:
		player_attacks_next = false
	else:
		player_attacks_next = randi() % 2 == 0
	_log("=== Combat Start! ===")
	_init_combat_weapons(player_board)
	_init_combat_weapons(enemy_board)
	_apply_pack_leader_aura(player_board)
	_apply_pack_leader_aura(enemy_board)
	_apply_atk_skew_aura(player_board)
	_apply_atk_skew_aura(enemy_board)
	_apply_aztec_blessing(player_board)
	_apply_construct_charges(player_board)
	_init_myco_cap_bonus(player_board)
	_init_spore_hoarder(player_board)
	_apply_all_spore_buffs(player_board)
	_apply_elf_soc_effects()
	_apply_covenant_soc_effects()
	_apply_reaper_soc_effects()
	_apply_satyr_soc_effects()
	_apply_enemy_faction_setup()
	_fire_start_of_combat_spells()
	await _process_deaths()
	await _process_next_attack()


# ── Weapon setup ─────────────────────────────────────────────────────────────

func _init_combat_weapons(board: Board) -> void:
	for card in board.units:
		if is_instance_valid(card):
			_setup_unit_combat_state(card)
	_apply_commander_aura(board)


func _setup_unit_combat_state(card: UnitCard) -> void:
	card.combat_bonus_damage = 0
	card.combat_shot_bonus = 0
	if card.data.race != RaceType.Race.HUMAN or card.equipped_weapon == null:
		card.combat_gun_damage = 0
		card.combat_shots = 0
		return

	var weapon := card.equipped_weapon
	card.combat_gun_damage = weapon.get_total_damage()
	card.combat_shots = weapon.get_total_shots()

	var mult := 2 if card.is_radiant else 1
	match card.data.human_effect:
		HumanEffect.Effect.SNIPER_BONUS:
			if weapon.weapon_type == WeaponData.WeaponType.SNIPER:
				card.combat_gun_damage += weapon.level * 2 * mult
		HumanEffect.Effect.SHOTGUN_BONUS:
			if weapon.weapon_type == WeaponData.WeaponType.SHOTGUN:
				card.combat_bonus_damage += 2 * mult
		HumanEffect.Effect.MACHINEGUN_BONUS:
			if weapon.weapon_type == WeaponData.WeaponType.MACHINE_GUN:
				card.combat_shot_bonus = 1 * mult


func _apply_commander_aura(board: Board) -> void:
	var sources := board.units.duplicate()
	if board == player_board and support_card != null and is_instance_valid(support_card) \
			and not support_card.is_dead:
		sources.append(support_card)
	for card in sources:
		if not is_instance_valid(card) or card.is_dead:
			continue
		if card.data.race != RaceType.Race.HUMAN:
			continue
		if card.data.human_effect != HumanEffect.Effect.COMMANDER_AURA:
			continue
		var bonus := 2 if card.is_radiant else 1
		for target in board.units:
			if not is_instance_valid(target) or target == card:
				continue
			if target.data.race == RaceType.Race.HUMAN:
				target.combat_bonus_damage += bonus
		_log("%s aura: all other Humans +%d dmg!" % [card.data.display_name, bonus])


# ── Attack loop ───────────────────────────────────────────────────────────────

func _process_next_attack() -> void:
	if not player_board.has_living_units() or not enemy_board.has_living_units():
		if not player_board.has_living_units() and not _echo_wave_used and not _echo_pool.is_empty():
			await _spawn_echo_wave()
			await _process_next_attack()
			return
		_end_combat()
		return

	var attacker_board: Board = player_board if player_attacks_next else enemy_board
	var defender_board: Board = enemy_board if player_attacks_next else player_board

	var slot_idx := _player_slot_idx if player_attacks_next else _enemy_slot_idx
	var attacker: UnitCard = _get_attacker_for_slot(attacker_board, slot_idx)
	if attacker == null:
		_end_combat()
		return
	var defender: UnitCard = _pick_target(attacker, defender_board)
	if defender == null:
		_end_combat()
		return

	_log("%s attacks %s!" % [attacker.data.display_name, defender.data.display_name])
	defender.show_targeted(true)
	await get_tree().create_timer(0.22).timeout
	await attacker.flash_attack_toward(defender.global_position + defender.size * 0.5)
	defender.show_targeted(false)
	# Covenant pre-attack: Chain Hunter bonds target before attacking (Radiant: twice)
	if is_instance_valid(attacker) and not attacker.is_dead \
			and attacker_board == player_board \
			and attacker.data.race == RaceType.Race.COVENANT \
			and attacker.data.covenant_effect == CovenantEffect.Effect.CHAIN_HUNTER:
		_apply_covenant_bond(attacker, defender)
		if attacker.is_radiant:
			_apply_covenant_bond(attacker, defender)

	# Rite Spawner: summon Covenantling to attack first
	if is_instance_valid(attacker) and not attacker.is_dead \
			and attacker_board == player_board \
			and attacker.data.race == RaceType.Race.COVENANT \
			and attacker.data.covenant_effect == CovenantEffect.Effect.RITE_SPAWNER:
		await _rite_spawner_covenantling_attack(attacker, defender, attacker_board, defender_board)

	if player_attacks_next and construct_shop_data != null and construct_shop_data.resonance_charge > 0:
		_apply_resonance_charge()
	await _resolve_attack(attacker, defender, attacker_board, defender_board)

	attacker.refresh_display()
	defender.refresh_display()

	if defender.current_health <= 0:
		_unit_killers[defender] = attacker
	if attacker_board == player_board and defender.current_health <= 0:
		_check_kill_budget(attacker)
		_check_kill_gold(attacker)
		_check_elf_on_kill(attacker)
		_check_satyr_kill_effects(attacker)

	await _process_deaths()

	# Windfury: attack a second time if still alive
	if is_instance_valid(attacker) and not attacker.is_dead \
			and (attacker.current_keywords & KeywordFlags.Keyword.WINDFURY) != 0 \
			and defender_board.has_living_units():
		var second_target := _pick_target(attacker, defender_board)
		if second_target != null:
			_log("%s strikes again (Windfury)!" % attacker.data.display_name)
			second_target.show_targeted(true)
			await get_tree().create_timer(0.15).timeout
			await attacker.flash_attack_toward(second_target.global_position + second_target.size * 0.5)
			second_target.show_targeted(false)
			await _resolve_attack(attacker, second_target, attacker_board, defender_board)
			attacker.refresh_display()
			second_target.refresh_display()
			if second_target.current_health <= 0:
				_unit_killers[second_target] = attacker
				_check_kill_budget(attacker)
				_check_kill_gold(attacker)
				_check_elf_on_kill(attacker)
				_check_satyr_kill_effects(attacker)
			await _process_deaths()
			if is_instance_valid(attacker) and attacker_board == player_board:
				_fire_reaper_attack_effects(attacker, second_target)

	var is_friendly_attack := player_attacks_next
	var trigger_unit: UnitCard = attacker if is_instance_valid(attacker) and not attacker.is_dead else null
	if is_friendly_attack:
		_tick_doom_all()
		_fire_triggered_spells(SpellTrigger.Trigger.ON_ATTACK, trigger_unit)
		# Fire on-attack effects even if the attacker died — "On Attack" triggers on attack, not on survival
		if is_instance_valid(attacker):
			_fire_goblin_attack_effects(attacker)
			_fire_myconid_attack_effects(attacker)
			_fire_elf_attack_effects(attacker)
			_fire_covenant_attack_effects(attacker, defender)
			_fire_reaper_attack_effects(attacker, defender)
			_fire_satyr_attack_effects(attacker, defender, attacker_board, defender_board)
	else:
		_tick_friendly_doom_all()
		_fire_triggered_spells(SpellTrigger.Trigger.WHEN_ATTACKED, trigger_unit)
		if _snare_stacks > 0 and is_instance_valid(trigger_unit) and not trigger_unit.is_dead:
			var snare_dmg := _snare_stacks * (1 + _get_total_asp())
			trigger_unit.current_health -= snare_dmg
			trigger_unit.refresh_display()
			_log("Arcane Snare: %d stack(s) deal %d damage to %s!" % [_snare_stacks, snare_dmg, trigger_unit.data.display_name])
	await _process_deaths()

	var attacker_pos := attacker_board.units.find(attacker)
	if attacker_pos >= 0:
		var next := (attacker_pos + 1) % attacker_board.units.size()
		if player_attacks_next:
			_player_slot_idx = next
		else:
			_enemy_slot_idx = next

	player_attacks_next = not player_attacks_next
	if player_attacks_next:
		if myconid_shop_data != null:
			_sporulate()
		_covenant_end_of_turn()
		_reaper_end_of_turn()
		_aztec_end_of_turn()
		_satyr_end_of_turn()
	await get_tree().create_timer(0.35).timeout
	await _process_next_attack()


func _get_attacker_for_slot(board: Board, slot_idx: int) -> UnitCard:
	var size := board.units.size()
	if size == 0:
		return null
	for i in range(size):
		var unit: UnitCard = board.units[(slot_idx + i) % size]
		if is_instance_valid(unit) and not unit.is_dead:
			return unit
	return null


func _pick_target(attacker: UnitCard, defender_board: Board) -> UnitCard:
	var valid_targets := defender_board.get_valid_targets()
	if valid_targets.is_empty():
		return null
	if attacker.data.race == RaceType.Race.HUMAN \
			and attacker.data.human_effect == HumanEffect.Effect.SNIPER_BONUS:
		var all_alive := defender_board.units.filter(func(u): return not u.is_dead)
		return _get_lowest_hp_target(all_alive)
	if attacker.data.race == RaceType.Race.SATYR \
			and _is_silver_satyr(attacker.data.satyr_effect):
		return _get_highest_hp_target(valid_targets)
	return valid_targets[randi() % valid_targets.size()]


func _get_lowest_hp_target(targets: Array) -> UnitCard:
	var lowest: UnitCard = targets[0]
	for t: UnitCard in targets:
		if t.current_health < lowest.current_health:
			lowest = t
	return lowest


func _get_board_neighbors(board: Board, target: UnitCard) -> Array:
	var alive := board.units.filter(func(u): return not u.is_dead)
	var idx := alive.find(target)
	var neighbors: Array = []
	if idx > 0:
		neighbors.append(alive[idx - 1])
	if idx < alive.size() - 1:
		neighbors.append(alive[idx + 1])
	return neighbors


# ── Damage resolution ─────────────────────────────────────────────────────────

func _resolve_attack(
		attacker: UnitCard, defender: UnitCard,
		attacker_board: Board, defender_board: Board) -> void:
	var def_shield_broken := false
	var atk_shield_broken := false
	var def_hit := false

	# Thornguard: when attacked, give a random other friendly unit +1/+1
	if defender_board == player_board \
			and defender.data.race == RaceType.Race.ELF \
			and defender.data.elf_effect == ElfEffect.Effect.WHEN_ATTACKED_BUFF:
		var buff := 2 if defender.is_radiant else 1
		var others := defender_board.units.filter(
			func(u): return is_instance_valid(u) and not u.is_dead and u != defender)
		if not others.is_empty():
			var targ: UnitCard = others[randi() % others.size()]
			targ.current_attack += buff
			targ.current_health += buff
			targ.refresh_display()
			_log("Thornguard: %s +%d/+%d!" % [targ.data.display_name, buff, buff])

	# Attacker → Defender
	if (defender.current_keywords & KeywordFlags.Keyword.DIVINE_SHIELD) != 0:
		defender.current_keywords &= ~KeywordFlags.Keyword.DIVINE_SHIELD
		def_shield_broken = true
	elif attacker.data.race == RaceType.Race.HUMAN and attacker.equipped_weapon != null:
		_deal_human_damage(attacker, defender, defender_board)
		var extra_fires := _get_extra_warlord_fires() if attacker_board == player_board else 0
		for _i in range(extra_fires):
			_deal_human_damage(attacker, defender, defender_board)
			_log("Warlord: %s fires again!" % attacker.data.display_name)
		if attacker.data.human_effect == HumanEffect.Effect.DUAL_WIELD \
				and attacker.backpack_weapon != null:
			var alive_targets := defender_board.units.filter(
				func(u): return is_instance_valid(u) and not u.is_dead and u.current_health > 0)
			if not alive_targets.is_empty():
				var second_target: UnitCard = alive_targets[randi() % alive_targets.size()]
				var main_weapon := attacker.equipped_weapon
				var main_damage := attacker.combat_gun_damage
				var main_shots := attacker.combat_shots
				attacker.equipped_weapon = attacker.backpack_weapon
				attacker.combat_gun_damage = attacker.backpack_weapon.get_total_damage()
				attacker.combat_shots = attacker.backpack_weapon.get_total_shots()
				_fire_weapon_at(attacker, second_target, defender_board)
				attacker.equipped_weapon = main_weapon
				attacker.combat_gun_damage = main_damage
				attacker.combat_shots = main_shots
				_log("%s fires backup weapon at %s!" % [attacker.data.display_name, second_target.data.display_name])
				if attacker.is_radiant:
					# Radiant Duelist: each weapon fires twice total
					var main_alive := defender_board.units.filter(
						func(u): return is_instance_valid(u) and not u.is_dead and u.current_health > 0)
					if not main_alive.is_empty():
						_deal_human_damage(attacker, main_alive[randi() % main_alive.size()], defender_board)
					var bp_alive := defender_board.units.filter(
						func(u): return is_instance_valid(u) and not u.is_dead and u.current_health > 0)
					if not bp_alive.is_empty():
						var bp_target: UnitCard = bp_alive[randi() % bp_alive.size()]
						attacker.equipped_weapon = attacker.backpack_weapon
						attacker.combat_gun_damage = attacker.backpack_weapon.get_total_damage()
						attacker.combat_shots = attacker.backpack_weapon.get_total_shots()
						_fire_weapon_at(attacker, bp_target, defender_board)
						attacker.equipped_weapon = main_weapon
						attacker.combat_gun_damage = main_damage
						attacker.combat_shots = main_shots
		def_hit = true
	elif (attacker.current_keywords & KeywordFlags.Keyword.POISONOUS) != 0:
		defender.current_health = 0
		def_hit = true
	else:
		var raw_dmg: int = attacker.current_attack
		if attacker_board == player_board and _doom_counters.has(defender) and _has_pale_shroud():
			raw_dmg += 1
		if defender.data.race == RaceType.Race.CONSTRUCT and defender_board == player_board \
				and construct_shop_data != null and defender.construct_charge > 0:
			raw_dmg = _absorb_construct_damage(defender, raw_dmg, attacker)
		# Silver bonus damage: target highest HP, deal extra damage
		if attacker.data.race == RaceType.Race.SATYR \
				and _is_silver_satyr(attacker.data.satyr_effect):
			var sd: SatyrShopData = satyr_shop_data if attacker_board == player_board else enemy_satyr_shop_data
			var silver_bonus: int = sd.silver_bonus_damage if sd != null else 5
			if _get_mono_color(attacker_board) == SatyrColor.Hue.SILVER:
				silver_bonus *= 2
			raw_dmg += silver_bonus
		defender.current_health -= raw_dmg
		def_hit = true
		# Blood Hunger (Crimson T4): on damage dealt, +3/+3 permanently
		if raw_dmg > 0 and attacker_board == player_board \
				and attacker.data.race == RaceType.Race.SATYR \
				and attacker.data.satyr_effect == SatyrEffect.Effect.CRIMSON_T4:
			attacker.current_attack += 3
			attacker.current_health += 3
			attacker.refresh_display()
			_log("%s: Blood Hunger — +3/+3!" % attacker.data.display_name)
		# Black on-hit: debuff random enemy ATK, spawn Black token
		if raw_dmg > 0 and attacker.data.race == RaceType.Race.SATYR \
				and _is_black_basic_satyr(attacker.data.satyr_effect):
			_apply_black_satyr_on_hit(attacker, defender_board, attacker_board)

	# Defender counter → Attacker
	var sniper_kill := def_hit \
		and attacker.data.race == RaceType.Race.HUMAN \
		and attacker.equipped_weapon != null \
		and attacker.equipped_weapon.weapon_type == WeaponData.WeaponType.SNIPER \
		and defender.current_health <= 0
	if sniper_kill:
		pass  # sniper killed the target; no counter
	elif (attacker.current_keywords & KeywordFlags.Keyword.DIVINE_SHIELD) != 0:
		attacker.current_keywords &= ~KeywordFlags.Keyword.DIVINE_SHIELD
		atk_shield_broken = true
	elif defender.data.race == RaceType.Race.HUMAN and defender.equipped_weapon != null \
			and defender.data.human_effect != HumanEffect.Effect.COUNTER_FIRE:
		_deal_human_damage(defender, attacker, attacker_board)
	elif (defender.current_keywords & KeywordFlags.Keyword.POISONOUS) != 0:
		attacker.current_health = 0
	else:
		attacker.current_health -= defender.current_attack

	# Brawler: after taking a hit, fire weapon at a random living enemy
	if def_hit and defender.current_health > 0 and is_instance_valid(defender):
		if defender.data.race == RaceType.Race.HUMAN and defender.equipped_weapon != null:
			if defender.data.human_effect == HumanEffect.Effect.COUNTER_FIRE:
				var alive_enemies := attacker_board.units.filter(
					func(u): return is_instance_valid(u) and not u.is_dead and u.current_health > 0)
				if not alive_enemies.is_empty():
					var fire_target: UnitCard = alive_enemies[randi() % alive_enemies.size()]
					var fire_count := 2 if defender.is_radiant else 1
					for _i in range(fire_count):
						_fire_weapon_at(defender, fire_target, attacker_board)
					_log("%s fires back at %s!" % [defender.data.display_name, fire_target.data.display_name])

	if def_shield_broken:
		_log("%s's Divine Shield absorbed the hit!" % defender.data.display_name)
	if atk_shield_broken:
		_log("%s's Divine Shield blocked the counter!" % attacker.data.display_name)

	if def_hit and is_instance_valid(defender) and not defender.is_dead \
			and defender.data.race == RaceType.Race.CONSTRUCT and defender_board == player_board \
			and construct_shop_data != null:
		_add_construct_charge(defender, construct_shop_data.recoil_charge)
		if not defender.construct_depowered:
			_log("%s gains %d Charge (Recoil)!" % [defender.data.display_name, construct_shop_data.recoil_charge])
		if defender.data.construct_effect == ConstructEffect.Effect.IRON_SENTINEL:
			var sentinel_gain := 6 if defender.is_radiant else 3
			_add_construct_charge(defender, sentinel_gain, true)
			_log("%s Iron Sentinel: +%d Charge!" % [defender.data.display_name, sentinel_gain])

	await _play_damage_anim(defender, def_shield_broken)
	await _play_damage_anim(attacker, atk_shield_broken)


func _deal_human_damage(attacker: UnitCard, target: UnitCard, target_board: Board) -> void:
	if attacker.equipped_weapon == null:
		return
	var weapon := attacker.equipped_weapon
	var gun := attacker.combat_gun_damage
	var bonus := attacker.combat_bonus_damage
	var base := attacker.current_attack

	match weapon.weapon_type:
		WeaponData.WeaponType.PISTOL, WeaponData.WeaponType.SNIPER:
			if (attacker.current_keywords & KeywordFlags.Keyword.POISONOUS) != 0:
				target.current_health = 0
			else:
				target.current_health -= base + gun + bonus

		WeaponData.WeaponType.SHOTGUN:
			if (attacker.current_keywords & KeywordFlags.Keyword.POISONOUS) != 0:
				target.current_health = 0
			else:
				target.current_health -= base + gun + bonus
			var splash: int = maxi(1, (base + gun) >> 1) + bonus
			var splash_neighbors := _get_board_neighbors(target_board, target)
			if not splash_neighbors.is_empty():
				for neighbor in splash_neighbors:
					if not neighbor.is_dead:
						neighbor.current_health -= splash
				_log("%s shotgun splash: %d to %d neighbor(s)!" % [attacker.data.display_name, splash, splash_neighbors.size()])

		WeaponData.WeaponType.MACHINE_GUN:
			var shot_dmg := gun + attacker.combat_shot_bonus
			if (attacker.current_keywords & KeywordFlags.Keyword.POISONOUS) != 0:
				target.current_health = 0
			else:
				var current_target := target
				var first_shot := true
				for _s in range(attacker.combat_shots):
					if current_target.is_dead or current_target.current_health <= 0:
						var alive := target_board.units.filter(
							func(u): return is_instance_valid(u) and not u.is_dead and u.current_health > 0)
						if alive.is_empty():
							break
						current_target = alive[randi() % alive.size()]
					var dmg := shot_dmg + bonus
					if first_shot:
						dmg += base
						first_shot = false
					current_target.current_health -= dmg
					current_target.refresh_display()


func _fire_weapon_at(attacker: UnitCard, target: UnitCard, target_board: Board) -> void:
	if not is_instance_valid(target) or target.current_health <= 0:
		return
	if attacker.equipped_weapon == null:
		return
	var weapon := attacker.equipped_weapon
	var gun := attacker.combat_gun_damage

	match weapon.weapon_type:
		WeaponData.WeaponType.PISTOL, WeaponData.WeaponType.SNIPER:
			target.current_health -= gun
		WeaponData.WeaponType.SHOTGUN:
			target.current_health -= gun
			var splash: int = maxi(1, gun >> 1)
			for neighbor in _get_board_neighbors(target_board, target):
				if not neighbor.is_dead:
					neighbor.current_health -= splash
		WeaponData.WeaponType.MACHINE_GUN:
			target.current_health -= (gun + attacker.combat_shot_bonus) * attacker.combat_shots

	target.refresh_display()


func _play_damage_anim(unit: UnitCard, shield_broken: bool) -> void:
	if shield_broken:
		await unit.apply_divine_shield_break()
	else:
		await unit.flash_hit(unit.current_health <= 0)


# ── Deaths ────────────────────────────────────────────────────────────────────

func _process_deaths() -> void:
	var all_units: Array = []
	all_units.append_array(player_board.units)
	all_units.append_array(enemy_board.units)

	var newly_dead: Array = all_units.filter(
		func(u): return is_instance_valid(u) and u.current_health <= 0 and not u.is_dead)
	if newly_dead.is_empty():
		return

	for dead: UnitCard in newly_dead:
		dead.is_dead = true

	for dead: UnitCard in newly_dead:
		_log("%s dies!" % dead.data.display_name)
		await dead.play_death_animation()

		var parent_board: Board = player_board if player_board.units.has(dead) else enemy_board
		var opp_board: Board = enemy_board if parent_board == player_board else player_board

		if dead.data.race == RaceType.Race.HUMAN:
			# Gunslinger Death Knell
			if dead.data.human_effect == HumanEffect.Effect.DEATH_KNELL_FIRE:
				var base_count := 2 if dead.is_radiant else 1
				var knell_count := base_count * _get_knell_multiplier(parent_board, newly_dead)
				_log("%s Death Knell fires weapon!" % dead.data.display_name)
				for _i in range(knell_count):
					var alive_enemies := opp_board.units.filter(func(u): return not u.is_dead)
					if alive_enemies.is_empty():
						break
					var fire_target: UnitCard = alive_enemies[randi() % alive_enemies.size()]
					_fire_weapon_at(dead, fire_target, opp_board)

			# Recruit: surviving friendly Recruits gain ATK
			for card in parent_board.units:
				if not is_instance_valid(card) or card.is_dead or card == dead:
					continue
				if card.data.race == RaceType.Race.HUMAN \
						and card.data.human_effect == HumanEffect.Effect.ON_FRIENDLY_DEATH_ATK:
					var gain := 4 if card.is_radiant else 2
					card.current_attack += gain
					_log("%s gains +%d ATK!" % [card.data.display_name, gain])
					card.refresh_display()

		if dead.data.race == RaceType.Race.GOBLIN:
			match dead.data.goblin_effect:
				GoblinEffect.Effect.PACK_LEADER_AURA:
					var bonus := 4 if dead.is_radiant else 2
					for card in parent_board.units:
						if not is_instance_valid(card) or card.is_dead or newly_dead.has(card):
							continue
						if card.data.race == RaceType.Race.GOBLIN or _is_peon(card):
							card.current_attack = maxi(1, card.current_attack - bonus)
							card.refresh_display()
					_log("%s aura fades: Goblins and Peons -%d ATK!" % [dead.data.display_name, bonus])
				GoblinEffect.Effect.DEATH_KNELL_CHAIN:
					var count := 2 if dead.is_radiant else 1
					for _i in range(count):
						var token := _spawn_goblin_peon(parent_board)
						if token != null:
							token.current_keywords |= KeywordFlags.Keyword.REBORN
							token.refresh_display()
					_log("%s Death Knell: summons %d Peon(s) with Reborn!" % [dead.data.display_name, count])
				GoblinEffect.Effect.DEATH_KNELL_ONCE:
					var count := 2 if dead.is_radiant else 1
					for _i in range(count):
						_spawn_goblin_peon(parent_board, -1, false)
					_log("%s Death Knell: summons %d Peon(s)!" % [dead.data.display_name, count])
				GoblinEffect.Effect.DEATH_BOMB:
					var mult := 2 if dead.is_radiant else 1
					var alive_enemies := opp_board.units.filter(func(u): return not u.is_dead)
					for enemy in alive_enemies:
						enemy.current_health -= 2 * mult
						enemy.refresh_display()
					for _i in range(mult):
						_spawn_goblin_peon(parent_board)
					_log("%s Death Bomb: %d dmg to all enemies + summons %d Peon(s)!" % [dead.data.display_name, 2 * mult, mult])
				GoblinEffect.Effect.DEATH_KNELL_PEON_BURST:
					var bmult := 3.0 if dead.is_radiant else 2.0
					for _i in range(4):
						_spawn_goblin_peon(parent_board, -1, false, bmult)
					_log("%s Death Knell: summons 4 Peons at %dx budget!" % [dead.data.display_name, int(bmult)])
				GoblinEffect.Effect.ATK_SKEW_AURA:
					var count := 2 if dead.is_radiant else 1
					for _i in range(count):
						_spawn_goblin_peon(parent_board)
					_log("%s Death Knell: summons %d Peon(s)!" % [dead.data.display_name, count])
				GoblinEffect.Effect.AVENGE_BUDGET:
					var count := 2 if dead.is_radiant else 1
					for _i in range(count):
						_spawn_goblin_peon(parent_board)
					_log("%s Death Knell: summons %d Peon(s)!" % [dead.data.display_name, count])
				GoblinEffect.Effect.DEATH_KNELL_BUDGET:
					var gain := 2 if dead.is_radiant else 1
					if goblin_shop_data != null:
						goblin_shop_data.stat_budget += gain
					_log("%s Death Knell: Peon budget +%d → %d!" % [dead.data.display_name, gain, goblin_shop_data.stat_budget if goblin_shop_data != null else 0])

			if dead.data.race == RaceType.Race.MAGE and parent_board == player_board:
				match dead.data.mage_effect:
					MageEffect.Effect.DEATH_KNELL_GOLD:
						var coins := dead.mage_effect_level * (2 if dead.is_radiant else 1)
						pending_gold_reward += coins
						_log("%s Death Knell: +%d gold!" % [dead.data.display_name, coins])
					MageEffect.Effect.DEATH_KNELL_HSP:
						var gain := 2 if dead.is_radiant else 1
						pending_hsp_bonus += gain
						hsp += gain
						_log("%s Death Knell: HSP +%d!" % [dead.data.display_name, gain])
					MageEffect.Effect.RUNIC_SCRIBE:
						var mage_candidates: Array = []
						for unit in parent_board.units:
							if is_instance_valid(unit) and not unit.is_dead and not newly_dead.has(unit) \
									and unit.data.race == RaceType.Race.MAGE \
									and unit.equipped_spell != null and unit.equipped_spell.has_any_trigger():
								mage_candidates.append(unit)
						if not mage_candidates.is_empty():
							var target_mage: UnitCard = mage_candidates[randi() % mage_candidates.size()]
							var inst: SpellInstance = target_mage.equipped_spell
							var active_triggers: Array = []
							for t in [SpellTrigger.Trigger.ON_ATTACK, SpellTrigger.Trigger.WHEN_ATTACKED,
									SpellTrigger.Trigger.DEATH_KNELL, SpellTrigger.Trigger.START_OF_COMBAT]:
								if inst.get_fire_count(t) > 0:
									active_triggers.append(t)
							if not active_triggers.is_empty():
								var chosen: int = active_triggers[randi() % active_triggers.size()]
								var levels := 2 if dead.is_radiant else 1
								for _i in range(levels):
									inst.upgrade_trigger(chosen)
								target_mage.refresh_display()
								_log("%s Death Knell: %s %s +%d level!" % [
									dead.data.display_name, target_mage.data.display_name,
									SpellTrigger.display_name(chosen), levels])

		# Aztec death knells
		if dead.data.race == RaceType.Race.AZTEC and parent_board == player_board:
			match dead.data.aztec_effect:
				AztecEffect.Effect.GILDED_MARTYR:
					if aztec_gold > 0:
						var dmg := aztec_gold
						var alive_enemies := opp_board.units.filter(func(u): return not u.is_dead)
						if not alive_enemies.is_empty():
							var target: UnitCard = alive_enemies[randi() % alive_enemies.size()]
							target.current_health -= dmg
							target.refresh_display()
						_log("%s Death Knell: %d dmg from %d gold!" % [dead.data.display_name, dmg, aztec_gold])
				AztecEffect.Effect.GOLD_EFFIGY:
					if aztec_gold > 0:
						var dmg := aztec_gold
						var alive_enemies := opp_board.units.filter(func(u): return not u.is_dead)
						if not alive_enemies.is_empty():
							var target: UnitCard = alive_enemies[randi() % alive_enemies.size()]
							target.current_health -= dmg
							target.refresh_display()
						_log("%s Death Knell: %d dmg from %d gold!" % [dead.data.display_name, dmg, aztec_gold])
				AztecEffect.Effect.SUN_HERALD:
					_spawn_aztec_gold_idol(parent_board)

		# Construct death knells
		if dead.data.race == RaceType.Race.CONSTRUCT and parent_board == player_board:
			if dead.data.construct_effect == ConstructEffect.Effect.MELTDOWN:
				var melt_gain := 6 if dead.is_radiant else 3
				for ally: UnitCard in parent_board.units:
					if not is_instance_valid(ally) or ally.is_dead or newly_dead.has(ally):
						continue
					if ally.data.race == RaceType.Race.CONSTRUCT:
						_add_construct_charge(ally, melt_gain, true)
					_grant_permanent_stats(ally, melt_gain, melt_gain)
				_log("%s Meltdown: Constructs +%d Charge, board +%d/+%d permanently!" % [dead.data.display_name, melt_gain, melt_gain, melt_gain])
			if dead.data.construct_effect == ConstructEffect.Effect.RELAY_NODE:
				var dead_idx := parent_board.units.find(dead)
				var relay_candidates: Array = []
				if dead_idx > 0:
					var left: UnitCard = parent_board.units[dead_idx - 1]
					if is_instance_valid(left) and not left.is_dead:
						relay_candidates.append(left)
				if dead_idx < parent_board.units.size() - 1:
					var right: UnitCard = parent_board.units[dead_idx + 1]
					if is_instance_valid(right) and not right.is_dead:
						relay_candidates.append(right)
				if not relay_candidates.is_empty():
					relay_surge_requested.emit(relay_candidates)
					_log("%s Relay Node: looking for adjacent Battlecry..." % dead.data.display_name)
			if dead.data.construct_effect == ConstructEffect.Effect.ARC_COIL:
				var dead_idx := parent_board.units.find(dead)
				var arc_candidates: Array = []
				if dead_idx > 0:
					var left: UnitCard = parent_board.units[dead_idx - 1]
					if is_instance_valid(left) and not left.is_dead \
							and left.data.race == RaceType.Race.CONSTRUCT:
						arc_candidates.append(left)
				if dead_idx < parent_board.units.size() - 1:
					var right: UnitCard = parent_board.units[dead_idx + 1]
					if is_instance_valid(right) and not right.is_dead \
							and right.data.race == RaceType.Race.CONSTRUCT:
						arc_candidates.append(right)
				if not arc_candidates.is_empty():
					var arc_target: UnitCard = arc_candidates[randi() % arc_candidates.size()]
					var peak := dead.construct_peak_charge
					_add_construct_charge(arc_target, peak, true)
					_log("%s Arc Coil: %s gains %d Charge!" % [dead.data.display_name, arc_target.data.display_name, peak])
				if dead.data.construct_effect == ConstructEffect.Effect.FISSION_CORE:
					var peak := dead.construct_peak_charge
					if peak > 0:
						var fission_gain := peak * 2 if dead.is_radiant else peak
						for ally: UnitCard in parent_board.units:
							if not is_instance_valid(ally) or ally.is_dead or newly_dead.has(ally):
								continue
							_grant_permanent_stats(ally, fission_gain, fission_gain)
						_log("%s Fission Core: board +%d/+%d permanently!" % [dead.data.display_name, fission_gain, fission_gain])

		# Warchief aura: any living friendly Warchief summons a replacement when a Goblin dies
		if parent_board == player_board:
			for card in parent_board.units:
				if not is_instance_valid(card) or card.is_dead or newly_dead.has(card):
					continue
				if card.data.goblin_effect == GoblinEffect.Effect.WARCHIEF_AURA:
					var wc_count := 2 if card.is_radiant else 1
					for _i in range(wc_count):
						_spawn_goblin_peon(parent_board)
					_log("Warchief: summons %d replacement Peon(s) for %s!" % [wc_count, dead.data.display_name])
					break

		# Bomb King: when a Peon dies, deal 2 dmg to a random enemy
		if _is_peon(dead) and parent_board == player_board:
			for card in parent_board.units:
				if not is_instance_valid(card) or card.is_dead or newly_dead.has(card):
					continue
				if card.data.goblin_effect == GoblinEffect.Effect.DEATH_PEON_DAMAGE:
					var dmg := 4 if card.is_radiant else 2
					var alive_enemies := opp_board.units.filter(func(u): return not u.is_dead)
					if not alive_enemies.is_empty():
						var fire_target: UnitCard = alive_enemies[randi() % alive_enemies.size()]
						fire_target.current_health -= dmg
						fire_target.refresh_display()
					_log("Bomb King: %d damage from Peon death!" % dmg)
					break

		# Reckoner Avenge 2: every 2 friendly deaths, permanently +1 Peon stat budget
		if parent_board == player_board:
			for card in parent_board.units:
				if not is_instance_valid(card) or card.is_dead or newly_dead.has(card):
					continue
				if card.data.goblin_effect == GoblinEffect.Effect.AVENGE_BUDGET:
					var threshold := 1 if card.is_radiant else 2
					var cnt := int(_avenge_counters.get(card, 0)) + 1
					if cnt >= threshold:
						_avenge_counters[card] = 0
						if goblin_shop_data != null:
							goblin_shop_data.stat_budget += 1
						_log("%s Avenge: Peon budget +1 → %d!" % [card.data.display_name, goblin_shop_data.stat_budget if goblin_shop_data else 0])
					else:
						_avenge_counters[card] = cnt

		# Echo Caster Avenge 2
		if parent_board == player_board:
			for card in parent_board.units:
				if not is_instance_valid(card) or card.is_dead or newly_dead.has(card):
					continue
				if card.data.mage_effect == MageEffect.Effect.ECHO_CASTER:
					var threshold := 1 if card.is_radiant else 2
					var cnt := int(_avenge_counters.get(card, 0)) + 1
					if cnt >= threshold:
						_avenge_counters[card] = 0
						if _last_spell_cast != null and _last_spell_fire_count > 0:
							var ec_fires := _last_spell_fire_count * (2 if card.is_radiant else 1)
							_cast_spell_effect(_last_spell_cast, null, ec_fires)
							_log("%s Avenge: re-cast %s x%d!" % [card.data.display_name, _last_spell_cast.display_name, ec_fires])
					else:
						_avenge_counters[card] = cnt

		# Board-wide Death Knell spells (player side only)
		if parent_board == player_board:
			_fire_death_knell_spells(parent_board, newly_dead)

		if dead.data.race == RaceType.Race.MYCONID and parent_board == player_board:
			_last_myconid_spores = dead.myconid_spores
			_last_myconid_path = dead.data.resource_path
			_last_myconid_is_parasite = (dead.data.myconid_effect == MyconidEffect.Effect.PARASITE)
			_on_myconid_death(dead, parent_board)
			for card in parent_board.units:
				if not is_instance_valid(card) or card.is_dead or newly_dead.has(card):
					continue
				if card.data.race == RaceType.Race.MYCONID \
						and card.data.myconid_effect == MyconidEffect.Effect.MYCELIUM_DEATH:
					var gain := 4 if card.is_radiant else 2
					_add_spores_to(card, gain)
					_log("%s: +%d spores from %s's death!" % [card.data.display_name, gain, dead.data.display_name])

		# ── Elf death effects ────────────────────────────────────────────────────
		if parent_board == player_board:
			# Dead unit's own elf effects
			if dead.data.race == RaceType.Race.ELF:
				# Elf Scout (DEATH_KNELL_ECHO): gain Echo on death, then enter pool
				if dead.data.elf_effect == ElfEffect.Effect.DEATH_KNELL_ECHO:
					dead.current_keywords |= KeywordFlags.Keyword.ECHO
					if dead.is_radiant:
						_next_echo_mult = 2.0

				# Dreamhunter Death Knell: give a random echoed unit Divine Shield (Radiant: up to 2)
				if dead.data.elf_effect == ElfEffect.Effect.DEATH_KNELL_DIVINE_ECHO \
						and not _echo_pool.is_empty():
					var dh_count := 2 if dead.is_radiant else 1
					var dh_indices := range(_echo_pool.size())
					dh_indices.shuffle()
					for dh_i in range(mini(dh_count, dh_indices.size())):
						_echo_pool[dh_indices[dh_i]]["keywords"] |= KeywordFlags.Keyword.DIVINE_SHIELD
					_log("Dreamhunter Death Knell: %d echoed unit(s) gain Divine Shield!" % mini(dh_count, _echo_pool.size()))

				# Pale Warden Death Knell: all echoed units +4/+4
				if dead.data.elf_effect == ElfEffect.Effect.DEATH_KNELL_BUFF_ECHOED:
					var pw_buff := 8 if dead.is_radiant else 4
					for entry in _echo_pool:
						entry["attack"] += pw_buff
						entry["health"] += pw_buff
					_log("Pale Warden Death Knell: echoed units +%d/+%d!" % [pw_buff, pw_buff])

				# Ancient Grove Death Knell: summon 1 (Radiant: 2) copies of random echo pool units
				if dead.data.elf_effect == ElfEffect.Effect.DEATH_KNELL_SUMMON_ECHO \
						and not _echo_pool.is_empty() and unit_card_scene != null:
					var ag_spawn_count := 2 if dead.is_radiant else 1
					for _ag_i in range(ag_spawn_count):
						if _echo_pool.is_empty():
							break
						var alive_count := parent_board.units.filter(func(u): return not u.is_dead).size()
						if alive_count >= MAX_BOARD_SIZE:
							var ag_entry_ov: Dictionary = _echo_pool[randi() % _echo_pool.size()]
							var echo_pct_ov := float(elf_shop_data.echo_stat_percent if elf_shop_data != null else 50)
							var em_ov := echo_pct_ov / 100.0 * _soc_echo_stat_mult
							_apply_sovereign_overflow(parent_board,
								maxi(1, roundi(float(ag_entry_ov["attack"]) * em_ov)),
								maxi(1, roundi(float(ag_entry_ov["health"]) * em_ov)), 0)
						else:
							var ag_entry: Dictionary = _echo_pool[randi() % _echo_pool.size()]
							var echo_pct := float(elf_shop_data.echo_stat_percent if elf_shop_data != null else 50)
							var em := echo_pct / 100.0 * _soc_echo_stat_mult
							var token: UnitCard = unit_card_scene.instantiate()
							parent_board.slots_container.add_child(token)
							parent_board.units.append(token)
							token.attack_direction = parent_board.attack_dir
							token.initialize(ag_entry["data"])
							token.current_attack = maxi(1, roundi(float(ag_entry["attack"]) * em))
							token.current_health = maxi(1, roundi(float(ag_entry["health"]) * em))
							token.current_keywords = ag_entry["keywords"] & ~KeywordFlags.Keyword.ECHO
							token.refresh_display()
							_log("Ancient Grove Death Knell: summoned %s from Echo pool!" % (ag_entry["data"] as UnitData).display_name)

			# Any unit with Echo enters the pool in death order
			if (dead.current_keywords & KeywordFlags.Keyword.ECHO) != 0:
				_add_to_echo_pool(dead)

			# Thornborn: +1/+1 per friendly death (triggers for all surviving Thornborns)
			for card in parent_board.units:
				if not is_instance_valid(card) or card.is_dead or newly_dead.has(card):
					continue
				if card.data.race == RaceType.Race.ELF \
						and card.data.elf_effect == ElfEffect.Effect.THORNBORN_GROWTH:
					var tb_gain := 2 if card.is_radiant else 1
					card.current_attack += tb_gain
					card.current_health += tb_gain
					card.refresh_display()
			if support_card != null and is_instance_valid(support_card) and not support_card.is_dead \
					and support_card.data.race == RaceType.Race.ELF \
					and support_card.data.elf_effect == ElfEffect.Effect.THORNBORN_GROWTH:
				var tb_gain := 2 if support_card.is_radiant else 1
				support_card.current_attack += tb_gain
				support_card.current_health += tb_gain
				support_card.refresh_display()

			# Ashveil Avenge 1: all surviving friendlies +1/+1
			for card in parent_board.units:
				if not is_instance_valid(card) or card.is_dead or newly_dead.has(card):
					continue
				if card.data.race == RaceType.Race.ELF \
						and card.data.elf_effect == ElfEffect.Effect.AVENGE_BUFF_BOARD:
					var av_buff := 2 if card.is_radiant else 1
					for ally in parent_board.units:
						if not is_instance_valid(ally) or ally.is_dead or newly_dead.has(ally):
							continue
						ally.current_attack += av_buff
						ally.current_health += av_buff
						ally.refresh_display()
					_log("Ashveil Avenge: all surviving friendlies +%d/+%d!" % [av_buff, av_buff])

		if (dead.current_keywords & KeywordFlags.Keyword.REBORN) != 0 and not dead.reborn_triggered:
			dead.reborn_triggered = true
			_spawn_reborn(dead, parent_board)

		# ── Covenant death effects ───────────────────────────────────────────
		# Martyr Kin: give own stats to bonded unit(s) (Radiant: up to 2)
		if dead.data.race == RaceType.Race.COVENANT \
				and dead.data.covenant_effect == CovenantEffect.Effect.MARTYR_KIN \
				and parent_board == player_board:
			var live_bonds := dead.bonded_units.filter(
				func(u): return is_instance_valid(u) and not u.is_dead)
			if not live_bonds.is_empty():
				var mk_bond_count := mini(2 if dead.is_radiant else 1, live_bonds.size())
				live_bonds.shuffle()
				for mk_j in range(mk_bond_count):
					var mk_target: UnitCard = live_bonds[mk_j]
					mk_target.current_attack += dead.current_attack
					mk_target.current_health += dead.current_health
					mk_target.refresh_display()
					_log("%s Death Knell: gave %d/%d to %s!" % [
						dead.data.display_name, dead.current_attack, dead.current_health,
						mk_target.data.display_name])

		# Grief Kin avenge 2: bond a random friendly unit
		if parent_board == player_board:
			for gk_card in parent_board.units:
				if not is_instance_valid(gk_card) or gk_card.is_dead or newly_dead.has(gk_card):
					continue
				if gk_card.data.race != RaceType.Race.COVENANT:
					continue
				if gk_card.data.covenant_effect != CovenantEffect.Effect.GRIEF_KIN:
					continue
				var gk_threshold := 1 if gk_card.is_radiant else 2
				var gk_cnt := int(_avenge_counters.get(gk_card, 0)) + 1
				if gk_cnt >= gk_threshold:
					_avenge_counters[gk_card] = 0
					var gk_candidates := parent_board.units.filter(func(u): \
						return is_instance_valid(u) and not u.is_dead \
						and not newly_dead.has(u) and u != gk_card)
					var gk_bond_count := mini(2 if gk_card.is_radiant else 1, gk_candidates.size())
					gk_candidates.shuffle()
					for gk_j in range(gk_bond_count):
						_apply_covenant_bond(gk_card, gk_candidates[gk_j])
						_log("%s Avenge: bonded %s!" % [gk_card.data.display_name, gk_candidates[gk_j].data.display_name])
				else:
					_avenge_counters[gk_card] = gk_cnt

		# ── Reaper death effects ────────────────────────────────────────────
		if dead.data.race == RaceType.Race.REAPER and parent_board == player_board:
			if dead.data.reaper_effect == ReaperEffect.Effect.PALE_REAPER:
				var alive_enemies := opp_board.units.filter(func(u): return not u.is_dead)
				var pale_doom := 20 if dead.is_radiant else 10
				for re_enemy in alive_enemies:
					_apply_doom(re_enemy, pale_doom)
				_log("%s Death Knell: %d doom to all enemies!" % [dead.data.display_name, pale_doom])

		# Rift Caller avenge 2: reduce a random doom by 2
		if parent_board == player_board:
			for rc_card in parent_board.units:
				if not is_instance_valid(rc_card) or rc_card.is_dead or newly_dead.has(rc_card):
					continue
				if rc_card.data.race != RaceType.Race.REAPER:
					continue
				if rc_card.data.reaper_effect != ReaperEffect.Effect.RIFT_CALLER:
					continue
				var rc_threshold := 1 if rc_card.is_radiant else 2
				var rc_cnt := int(_avenge_counters.get(rc_card, 0)) + 1
				if rc_cnt >= rc_threshold:
					_avenge_counters[rc_card] = 0
					var doomed := _doom_counters.keys().filter(
						func(u): return is_instance_valid(u) and not u.is_dead)
					if not doomed.is_empty():
						var rc_target: UnitCard = doomed[randi() % doomed.size()]
						var rc_reduce := 4 if rc_card.is_radiant else 2
						_doom_counters[rc_target] = maxi(0, _doom_counters[rc_target] - rc_reduce)
						if _doom_counters[rc_target] <= 0:
							_doom_counters.erase(rc_target)
							var rc_dmg := reaper_shop_data.doom_damage if reaper_shop_data != null else 100
							rc_target.current_health -= rc_dmg
							rc_target.refresh_display()
							_check_soul_harvester_doom_expire()
							_log("%s Avenge: doom expired on %s — %d damage!" % [rc_card.data.display_name, rc_target.data.display_name, rc_dmg])
						else:
							_log("%s Avenge: %s doom → %d!" % [rc_card.data.display_name, rc_target.data.display_name, _doom_counters[rc_target]])
						_update_reaper_aura()
				else:
					_avenge_counters[rc_card] = rc_cnt

		# Satyr faction death effects
		_on_satyr_death(dead, parent_board, newly_dead)

		# Berserk: all living units bonded to this dead unit go berserk
		var bonds_copy := dead.bonded_units.duplicate()
		for berserk_card in bonds_copy:
			if not is_instance_valid(berserk_card) or berserk_card.is_dead:
				dead.bonded_units.erase(berserk_card)
				continue
			berserk_card.bonded_units.erase(dead)
			dead.bonded_units.erase(berserk_card)
			await _trigger_berserk(berserk_card, dead)
			await _process_deaths()

		parent_board.remove_unit(dead)

	# Catch cascading deaths from death-rattle weapon fire
	await _process_deaths()


func _get_knell_multiplier(board: Board, newly_dead: Array) -> int:
	var extra := 0
	for unit in board.units:
		if not is_instance_valid(unit) or unit.is_dead:
			continue
		if newly_dead.has(unit):
			continue
		if unit.data.generic_effect == GenericEffect.Effect.KNELL_DOUBLER:
			extra += 2 if unit.is_radiant else 1
	if board == player_board and support_card != null and is_instance_valid(support_card) \
			and not support_card.is_dead \
			and support_card.data.generic_effect == GenericEffect.Effect.KNELL_DOUBLER:
		extra += 2 if support_card.is_radiant else 1
	return 1 + extra


func _spawn_reborn(dead: UnitCard, parent_board: Board) -> void:
	if unit_card_scene == null:
		push_error("CombatManager: unit_card_scene not assigned!")
		return

	if _is_peon(dead):
		var reborn_peon := _spawn_goblin_peon(parent_board, dead.get_index())
		if reborn_peon != null:
			reborn_peon.current_keywords = 0
			reborn_peon.refresh_display()
		_log("Reborn: %s rises as a fresh Peon!" % dead.data.display_name)
		return

	var reborn: UnitCard = unit_card_scene.instantiate()
	var dead_visual_idx: int = dead.get_index()
	var dead_logical_idx: int = parent_board.units.find(dead)

	parent_board.slots_container.add_child(reborn)
	parent_board.slots_container.move_child(reborn, dead_visual_idx)
	parent_board.units.insert(dead_logical_idx, reborn)

	reborn.attack_direction = parent_board.attack_dir
	reborn.initialize(dead.data)
	reborn.current_health = 1
	reborn.current_keywords = dead.current_keywords & ~KeywordFlags.Keyword.REBORN
	reborn.refresh_display()

	_log("%s is Reborn with 1 HP!" % dead.data.display_name)


# ── Spell resolution ─────────────────────────────────────────────────────────

func _fire_start_of_combat_spells() -> void:
	var boost := _get_trigger_boost()
	var hw_mult := _get_hexweaver_mult()
	var hexweaver_first := hw_mult > 1
	for instance: SpellInstance in active_spells:
		var base := instance.get_fire_count(SpellTrigger.Trigger.START_OF_COMBAT)
		if base > 0:
			var count := base + boost
			if hexweaver_first:
				count *= hw_mult
				hexweaver_first = false
			_cast_spell_effect(instance.spell_data, null, count)
			_last_spell_cast = instance.spell_data
			_last_spell_fire_count = count


# primary_trigger_unit: the unit that caused the trigger (enemy attacker for WHEN_ATTACKED)
func _fire_triggered_spells(trigger: int, primary_trigger_unit: UnitCard) -> void:
	var boost := _get_trigger_boost()
	var hw_mult := _get_hexweaver_mult()
	var hexweaver_first := hw_mult > 1
	for instance: SpellInstance in active_spells:
		var base := instance.get_fire_count(trigger)
		if base > 0:
			var count := base + boost
			if hexweaver_first:
				count *= hw_mult
				hexweaver_first = false
			_cast_spell_effect(instance.spell_data, primary_trigger_unit, count)
			_last_spell_cast = instance.spell_data
			_last_spell_fire_count = count


func _fire_death_knell_spells(parent_board: Board, newly_dead: Array) -> void:
	var has_knell := active_spells.any(
		func(i): return i.get_fire_count(SpellTrigger.Trigger.DEATH_KNELL) > 0)
	if not has_knell:
		return
	# All Death Knell spells together = 1 knell event; each Grave Conductor adds +1 extra firing
	var multiplier := _get_knell_multiplier(parent_board, newly_dead)
	var boost := _get_trigger_boost()
	var hw_mult := _get_hexweaver_mult()
	var hexweaver_first := hw_mult > 1
	for instance: SpellInstance in active_spells:
		var base := instance.get_fire_count(SpellTrigger.Trigger.DEATH_KNELL)
		if base > 0:
			var count := base + boost
			if hexweaver_first:
				count *= hw_mult
				hexweaver_first = false
			count *= multiplier
			_cast_spell_effect(instance.spell_data, null, count)
			_last_spell_cast = instance.spell_data
			_last_spell_fire_count = count


func _get_spell_feeder_mult() -> int:
	for unit in player_board.units:
		if is_instance_valid(unit) and not unit.is_dead \
				and unit.data.mage_effect == MageEffect.Effect.SPELL_FEEDER:
			return 2 if unit.is_radiant else 1
	if support_card != null and is_instance_valid(support_card) and not support_card.is_dead \
			and support_card.data.mage_effect == MageEffect.Effect.SPELL_FEEDER:
		return 2 if support_card.is_radiant else 1
	return 0


func _get_trigger_boost() -> int:
	for unit in player_board.units:
		if is_instance_valid(unit) and not unit.is_dead \
				and unit.data.mage_effect == MageEffect.Effect.TRIGGER_BOOST:
			return 2 if unit.is_radiant else 1
	if support_card != null and is_instance_valid(support_card) and not support_card.is_dead \
			and support_card.data.mage_effect == MageEffect.Effect.TRIGGER_BOOST:
		return 2 if support_card.is_radiant else 1
	return 0


func _get_hexweaver_mult() -> int:
	for unit in player_board.units:
		if is_instance_valid(unit) and not unit.is_dead \
				and unit.data.mage_effect == MageEffect.Effect.SPELL_DOUBLER:
			return 3 if unit.is_radiant else 2
	if support_card != null and is_instance_valid(support_card) and not support_card.is_dead \
			and support_card.data.mage_effect == MageEffect.Effect.SPELL_DOUBLER:
		return 3 if support_card.is_radiant else 2
	return 1


func _get_total_asp() -> int:
	var bonus := 0
	for unit in player_board.units:
		if is_instance_valid(unit) and not unit.is_dead \
				and unit.data.mage_effect == MageEffect.Effect.SPELL_POWER_AURA:
			bonus += 2 if unit.is_radiant else 1
	if support_card != null and is_instance_valid(support_card) and not support_card.is_dead \
			and support_card.data.mage_effect == MageEffect.Effect.SPELL_POWER_AURA:
		bonus += 2 if support_card.is_radiant else 1
	return asp + bonus


func _get_total_hsp() -> int:
	return hsp


func _get_extra_warlord_fires() -> int:
	for unit in player_board.units:
		if is_instance_valid(unit) and not unit.is_dead \
				and unit.data.race == RaceType.Race.HUMAN \
				and unit.data.human_effect == HumanEffect.Effect.DOUBLE_FIRE_AURA:
			return 2 if unit.is_radiant else 1
	if support_card != null and is_instance_valid(support_card) and not support_card.is_dead \
			and support_card.data.race == RaceType.Race.HUMAN \
			and support_card.data.human_effect == HumanEffect.Effect.DOUBLE_FIRE_AURA:
		return 2 if support_card.is_radiant else 1
	return 0


func _cast_spell_effect(spell: SpellData, primary_unit: UnitCard, times: int = 1) -> void:
	# Arcanist: board +1/+1 per times whenever any spell fires (Radiant: x2)
	var feeder_mult := _get_spell_feeder_mult()
	if feeder_mult > 0:
		for unit in player_board.units:
			if is_instance_valid(unit) and not unit.is_dead:
				unit.current_attack += times * feeder_mult
				unit.current_health += times * feeder_mult
				unit.refresh_display()
		_log("Arcanist: board +%d/+%d from spell!" % [times * feeder_mult, times * feeder_mult])

	# Familiar: self +1/+1 per times whenever any spell fires (Radiant: x2)
	for unit in player_board.units:
		if is_instance_valid(unit) and not unit.is_dead \
				and unit.data.mage_effect == MageEffect.Effect.FAMILIAR:
			var fam_mult := 2 if unit.is_radiant else 1
			unit.current_attack += times * fam_mult
			unit.current_health += times * fam_mult
			unit.refresh_display()
	if support_card != null and is_instance_valid(support_card) and not support_card.is_dead \
			and support_card.data.mage_effect == MageEffect.Effect.FAMILIAR:
		var fam_mult := 2 if support_card.is_radiant else 1
		support_card.current_attack += times * fam_mult
		support_card.current_health += times * fam_mult
		support_card.refresh_display()

	match spell.spell_type:
		SpellData.SpellType.BATTLE_TRANCE:
			var buff := _get_total_asp() * times
			for unit in player_board.units:
				if is_instance_valid(unit) and not unit.is_dead:
					unit.current_attack += buff
					unit.current_health += buff
					unit.refresh_display()
			_log("Battle Trance: all friendlies +%d/+%d!" % [buff, buff])

		SpellData.SpellType.ARCANE_SNARE:
			_snare_stacks += times
			_log("Arcane Snare: %d stack(s) applied (total: %d)!" % [times, _snare_stacks])

		SpellData.SpellType.ARCANE_INFUSION:
			asp += times
			hsp += times
			_log("Arcane Infusion: ASP now %d, HSP now %d (this combat)!" % [asp, hsp])

		SpellData.SpellType.MENDING_TOUCH:
			var alive_friendlies := player_board.units.filter(
				func(u): return is_instance_valid(u) and not u.is_dead)
			if not alive_friendlies.is_empty():
				var target: UnitCard = alive_friendlies[randi() % alive_friendlies.size()]
				var atk_buff := (1 + _get_total_asp()) * times
				var hp_buff := (1 + _get_total_hsp()) * times
				target.current_attack += atk_buff
				target.current_health += hp_buff
				target.refresh_display()
				_log("Mending Touch: %s +%d/+%d!" % [target.data.display_name, atk_buff, hp_buff])

		SpellData.SpellType.ARCANE_SURGE:
			var dmg := (_get_total_asp() + _get_total_hsp()) * times
			var alive_enemies := enemy_board.units.filter(
				func(u): return is_instance_valid(u) and not u.is_dead)
			if alive_enemies.is_empty():
				return
			alive_enemies.shuffle()
			var hit_count := mini(3, alive_enemies.size())
			for i in range(hit_count):
				alive_enemies[i].current_health -= dmg
				alive_enemies[i].refresh_display()
			_log("Arcane Surge: %d damage to %d enemies!" % [dmg, hit_count])

		SpellData.SpellType.NOVICE_BOLT:
			var dmg := _get_total_asp() * times
			var alive := enemy_board.units.filter(func(u): return is_instance_valid(u) and not u.is_dead)
			if alive.is_empty():
				return
			var target: UnitCard = alive[randi() % alive.size()]
			target.current_health -= dmg
			target.refresh_display()
			_log("Novice Bolt: %d damage to %s!" % [dmg, target.data.display_name])



# ── Goblin helpers ───────────────────────────────────────────────────────────

func _is_peon(card: UnitCard) -> bool:
	return card.data.display_name.contains("Peon")


func _apply_pack_leader_aura(board: Board) -> void:
	for source in board.units:
		if not is_instance_valid(source) or source.is_dead:
			continue
		if source.data.race != RaceType.Race.GOBLIN:
			continue
		if source.data.goblin_effect != GoblinEffect.Effect.PACK_LEADER_AURA:
			continue
		var bonus := 4 if source.is_radiant else 2
		for target in board.units:
			if not is_instance_valid(target) or target == source:
				continue
			if target.data.race == RaceType.Race.GOBLIN or _is_peon(target):
				target.current_attack += bonus
				target.refresh_display()
		_log("%s aura: all Goblins and Peons +%d ATK!" % [source.data.display_name, bonus])


func _apply_atk_skew_aura(board: Board) -> void:
	for source in board.units:
		if not is_instance_valid(source) or source.is_dead:
			continue
		if source.data.goblin_effect != GoblinEffect.Effect.ATK_SKEW_AURA:
			continue
		var skew := 1.5 if source.is_radiant else 1.25
		for target in board.units:
			if not is_instance_valid(target) or target == source or not _is_peon(target):
				continue
			var min_atk := ceili(target.current_health * skew)
			if target.current_attack < min_atk:
				target.current_attack = min_atk
				target.refresh_display()
		_log("%s: all Peons set to min %d%% ATK/HP ratio!" % [source.data.display_name, int(skew * 100)])


func _check_kill_budget(attacker: UnitCard) -> void:
	if not is_instance_valid(attacker) or attacker.is_dead:
		return
	if attacker.data.goblin_effect != GoblinEffect.Effect.KILL_BUDGET:
		return
	if goblin_shop_data == null:
		return
	var gain := 2 if attacker.is_radiant else 1
	goblin_shop_data.stat_budget += gain
	_log("%s kill: Peon budget +%d → %d!" % [attacker.data.display_name, gain, goblin_shop_data.stat_budget])


func _check_kill_gold(attacker: UnitCard) -> void:
	if not is_instance_valid(attacker) or attacker.is_dead:
		return
	# Tribute Hunter: on kill gain 1 gold (Radiant: 2)
	if attacker.data.race == RaceType.Race.AZTEC \
			and attacker.data.aztec_effect == AztecEffect.Effect.TRIBUTE_HUNTER:
		var gain := 2 if attacker.is_radiant else 1
		pending_gold_reward += gain
		_log("%s kill: +%dg!" % [attacker.data.display_name, gain])
	# Tithe Warden aura: any friendly kill gives +1 gold if Tithe Warden alive
	if player_board.units.has(attacker):
		for card in player_board.units:
			if is_instance_valid(card) and not card.is_dead \
					and card.data.race == RaceType.Race.AZTEC \
					and card.data.aztec_effect == AztecEffect.Effect.TITHE_WARDEN:
				pending_gold_reward += 1
				_log("Tithe Warden: +1g on kill!")
				break


func _apply_aztec_blessing(board: Board) -> void:
	if aztec_shop_data == null:
		return
	# Rate: base + Sun Idol aura bonuses
	var rate := aztec_shop_data.blessing_rate
	for card in board.units:
		if not is_instance_valid(card) or card.is_dead:
			continue
		if card.data.race != RaceType.Race.AZTEC:
			continue
		if card.data.aztec_effect == AztecEffect.Effect.SUN_IDOL:
			rate += 2 if card.is_radiant else 1
	# Effective gold: doubled by Golden Sovereign aura
	var effective_gold := aztec_gold
	for card in board.units:
		if not is_instance_valid(card) or card.is_dead:
			continue
		if card.data.race == RaceType.Race.AZTEC \
				and card.data.aztec_effect == AztecEffect.Effect.GOLDEN_SOVEREIGN:
			effective_gold *= 2
			break
	if rate <= 0 or effective_gold <= 0:
		return
	var bonus := rate * (effective_gold / 2)
	for card in board.units:
		if not is_instance_valid(card) or card.is_dead:
			continue
		if card.data.race != RaceType.Race.AZTEC:
			continue
		var card_bonus := bonus * (2 if card.data.aztec_effect == AztecEffect.Effect.GOLD_IDOL_TOKEN else 1)
		card.current_attack += card_bonus
		card.current_health += card_bonus
		card.refresh_display()
	_log("Aztec Blessing (rate %d × %dg): all Aztecs +%d/+%d!" % [rate, effective_gold, bonus, bonus])
	# The Starved: additional +1/+1 per player HP missing
	var hp_missing := maxi(0, 100 - aztec_player_hp)
	if hp_missing > 0:
		for card in board.units:
			if not is_instance_valid(card) or card.is_dead:
				continue
			if card.data.race == RaceType.Race.AZTEC \
					and card.data.aztec_effect == AztecEffect.Effect.THE_STARVED:
				card.current_attack += hp_missing
				card.current_health += hp_missing
				card.refresh_display()
				_log("The Starved: +%d/+%d from %d HP missing!" % [hp_missing, hp_missing, hp_missing])


func _aztec_end_of_turn() -> void:
	if aztec_bench_count <= 0:
		return
	for card in player_board.units:
		if not is_instance_valid(card) or card.is_dead:
			continue
		if card.data.race == RaceType.Race.AZTEC \
				and card.data.aztec_effect == AztecEffect.Effect.VAULT_KEEPER:
			pending_gold_reward += aztec_bench_count
			_log("Vault Keeper: +%dg from %d bench units!" % [aztec_bench_count, aztec_bench_count])
			break


func _spawn_aztec_gold_idol(board: Board) -> void:
	if board.units.filter(func(u): return not u.is_dead).size() >= MAX_BOARD_SIZE:
		return
	if unit_card_scene == null:
		return
	var idol_data: UnitData = load("res://resources/units/aztecs/gold_idol_token.tres")
	if idol_data == null:
		push_error("CombatManager: gold_idol_token.tres not found!")
		return
	var token: UnitCard = unit_card_scene.instantiate()
	board.slots_container.add_child(token)
	board.units.append(token)
	token.attack_direction = board.attack_dir
	token.is_draggable = board.is_draggable
	token.initialize(idol_data)
	token.current_attack = idol_data.base_attack
	token.current_health = idol_data.base_health
	# Apply 2x blessing immediately
	if aztec_shop_data != null and aztec_gold > 0:
		var rate := aztec_shop_data.blessing_rate
		var effective_gold := aztec_gold
		for card in board.units:
			if is_instance_valid(card) and not card.is_dead \
					and card.data.aztec_effect == AztecEffect.Effect.GOLDEN_SOVEREIGN:
				effective_gold *= 2
				break
		var idol_bonus := rate * effective_gold * 2
		token.current_attack += idol_bonus
		token.current_health += idol_bonus
	token.refresh_display()
	_log("Sun Herald Death Knell: Gold Idol summoned!")


func _fire_myconid_attack_effects(attacker: UnitCard) -> void:
	if attacker.data.race != RaceType.Race.MYCONID:
		return
	match attacker.data.myconid_effect:
		MyconidEffect.Effect.SPORELING_ATTACK:
			var gain := 2 if attacker.is_radiant else 1
			_add_spores_to(attacker, gain)
			_log("%s gains +%d spore(s) on attack!" % [attacker.data.display_name, gain])
		MyconidEffect.Effect.SPOREFRONT_ATTACK:
			var gain := 2 if attacker.is_radiant else 1
			for card in player_board.units:
				if is_instance_valid(card) and not card.is_dead \
						and card.data.race == RaceType.Race.MYCONID \
						and card != attacker:
					_add_spores_to(card, gain)
			_log("%s: all other Myconids +%d spore(s)!" % [attacker.data.display_name, gain])


func _fire_goblin_attack_effects(attacker: UnitCard) -> void:
	if attacker.data.race != RaceType.Race.GOBLIN:
		return
	match attacker.data.goblin_effect:
		GoblinEffect.Effect.SUMMON_ON_ATTACK:
			var max_uses := 2 if attacker.is_radiant else 1
			var used := int(_goblin_summon_uses.get(attacker, 0))
			if used < max_uses:
				var spawned := _spawn_goblin_peon(player_board)
				if spawned != null:
					_goblin_summon_uses[attacker] = used + 1
					_log("%s summons a Peon!" % attacker.data.display_name)
		GoblinEffect.Effect.BROOD_WITCH:
			var buff := 6 if attacker.is_radiant else 3
			var buffed := 0
			for unit in player_board.units:
				if is_instance_valid(unit) and not unit.is_dead and _is_peon(unit):
					unit.current_attack += buff
					unit.current_health += buff
					unit.refresh_display()
					buffed += 1
			if buffed > 0:
				_log("Brood Witch: %d Peon(s) +%d/+%d this fight!" % [buffed, buff, buff])


# ── Goblin Peon spawning ─────────────────────────────────────────────────────

func _spawn_goblin_peon(board: Board, insert_idx: int = -1, chain: bool = false, budget_mult: float = 1.0, extra_budget: int = 0) -> UnitCard:
	var alive_count := board.units.filter(func(u): return not u.is_dead).size()
	if alive_count >= MAX_BOARD_SIZE:
		var peon_data_tmp: UnitData = load(GOBLIN_PEON_CHAIN_PATH if chain else GOBLIN_PEON_PATH)
		if peon_data_tmp != null:
			_apply_sovereign_overflow(board, peon_data_tmp.base_attack, peon_data_tmp.base_health, 0)
		return null
	if unit_card_scene == null:
		return null
	var peon_data: UnitData = load(GOBLIN_PEON_CHAIN_PATH if chain else GOBLIN_PEON_PATH)
	if peon_data == null:
		push_error("CombatManager: goblin peon data not found!")
		return null

	var roll := {"atk": 1, "hp": 1, "keywords": 0}
	if goblin_shop_data != null:
		# Check for Taskmaster aura: doubles the effective budget
		var aura_mult := 1.0
		for card in board.units:
			if is_instance_valid(card) and not card.is_dead \
					and card.data.goblin_effect == GoblinEffect.Effect.DOUBLE_BUDGET_AURA:
				aura_mult = 2.0
				break
		var effective_budget := int(goblin_shop_data.stat_budget * aura_mult * budget_mult) + extra_budget
		roll = goblin_shop_data.roll_peon_with_budget(effective_budget)

	var token: UnitCard = unit_card_scene.instantiate()
	if insert_idx < 0:
		board.slots_container.add_child(token)
		board.units.append(token)
	else:
		board.slots_container.add_child(token)
		board.slots_container.move_child(token, insert_idx)
		board.units.insert(insert_idx, token)

	token.attack_direction = board.attack_dir
	token.is_draggable = board.is_draggable
	token.initialize(peon_data)
	token.current_attack = roll["atk"]
	token.current_health = roll["hp"]
	token.current_keywords = roll["keywords"]

	# Apply ATK skew if Rage Brand is alive on this board
	for card in board.units:
		if is_instance_valid(card) and not card.is_dead \
				and card.data.goblin_effect == GoblinEffect.Effect.ATK_SKEW_AURA:
			var skew := 1.5 if card.is_radiant else 1.25
			var min_atk := ceili(token.current_health * skew)
			if token.current_attack < min_atk:
				token.current_attack = min_atk
			break

	token.refresh_display()
	return token


# ── End ───────────────────────────────────────────────────────────────────────

func _end_combat() -> void:
	is_running = false
	var p_alive := player_board.has_living_units()
	var e_alive := enemy_board.has_living_units()
	var result: String
	if p_alive and not e_alive:
		result = "Victory!"
	elif e_alive and not p_alive:
		result = "Defeat"
	else:
		result = "Draw"
	_log("=== %s ===" % result)
	var damage := 0
	if e_alive:
		for unit in enemy_board.units:
			if is_instance_valid(unit) and not unit.is_dead:
				damage += unit.data.tier
		_log("Enemy survivors deal %d damage!" % damage)
	result_banner.text = result
	result_banner.visible = true
	continue_button.visible = true
	combat_ended.emit(damage)


func _log(text: String) -> void:
	if log_node and log_node.has_method("append_entry"):
		log_node.append_entry(text)
	print(text)


# ── Construct: Charge ─────────────────────────────────────────────────────────

func _apply_construct_charges(board: Board) -> void:
	if construct_shop_data == null:
		return
	# Snapshot persistent charge and reset peak before any SOC additions
	for card in board.units:
		if not is_instance_valid(card) or card.is_dead:
			continue
		if card.data.race != RaceType.Race.CONSTRUCT:
			continue
		card.construct_persistent_charge = card.construct_charge
		card.construct_peak_charge = card.construct_charge
	# Apply ATK bonus for existing persistent charge, then add cache on top
	for card in board.units:
		if not is_instance_valid(card) or card.is_dead:
			continue
		if card.data.race != RaceType.Race.CONSTRUCT:
			continue
		if card.construct_charge > 0:
			card.current_attack += card.construct_charge
			_construct_atk_applied[card] = card.construct_charge
	var cache := construct_shop_data.charge_cache
	if cache > 0:
		for card in board.units:
			if not is_instance_valid(card) or card.is_dead:
				continue
			if card.data.race != RaceType.Race.CONSTRUCT:
				continue
			_add_construct_charge(card, cache, true)
			_log("%s gains %d Charge (Cache)!" % [card.data.display_name, cache])
	# Winder: adjacent Constructs gain +2 Charge at Start of Combat
	var alive := board.units.filter(func(c): return is_instance_valid(c) and not c.is_dead)
	for i in range(alive.size()):
		var card: UnitCard = alive[i]
		if card.data.construct_effect == ConstructEffect.Effect.WINDER:
			var winder_charge := 4 if card.is_radiant else 2
			if i > 0 and (alive[i - 1] as UnitCard).data.race == RaceType.Race.CONSTRUCT:
				_add_construct_charge(alive[i - 1], winder_charge, true)
				_log("%s (Gear Up): %s gains +%d Charge!" % [card.data.display_name, (alive[i - 1] as UnitCard).data.display_name, winder_charge])
			if i < alive.size() - 1 and (alive[i + 1] as UnitCard).data.race == RaceType.Race.CONSTRUCT:
				_add_construct_charge(alive[i + 1], winder_charge, true)
				_log("%s (Gear Up): %s gains +%d Charge!" % [card.data.display_name, (alive[i + 1] as UnitCard).data.display_name, winder_charge])
	# Capacitor: gain 1 Charge per friendly Construct in play
	var construct_count := alive.filter(func(c): return (c as UnitCard).data.race == RaceType.Race.CONSTRUCT).size()
	for card2: UnitCard in alive:
		if card2.data.construct_effect == ConstructEffect.Effect.CAPACITOR:
			var cap_charge := construct_count * 2 if card2.is_radiant else construct_count
			_add_construct_charge(card2, cap_charge, true)
			_log("%s gains %d Charge (Capacitor)!" % [card2.data.display_name, cap_charge])
	# Grand Capacitor: gain 1 Charge per total Charge among all friendly Constructs (fires last)
	var total_construct_charge := 0
	for card3: UnitCard in alive:
		if (card3 as UnitCard).data.race == RaceType.Race.CONSTRUCT:
			total_construct_charge += card3.construct_charge
	for card3: UnitCard in alive:
		if card3.data.construct_effect == ConstructEffect.Effect.GRAND_CAPACITOR:
			var gc_charge := total_construct_charge * 2 if card3.is_radiant else total_construct_charge
			_add_construct_charge(card3, gc_charge, true)
			_log("%s gains %d Charge (Grand Capacitor)!" % [card3.data.display_name, gc_charge])


func _apply_resonance_charge() -> void:
	if construct_shop_data == null or construct_shop_data.resonance_charge <= 0:
		return
	for card in player_board.units:
		if not is_instance_valid(card) or card.is_dead:
			continue
		if card.data.race == RaceType.Race.CONSTRUCT:
			_add_construct_charge(card, construct_shop_data.resonance_charge)


# ── Construct: charge helpers ─────────────────────────────────────────────────

func _add_construct_charge(card: UnitCard, amount: int, force: bool = false) -> void:
	if not force and card.construct_depowered:
		return
	card.construct_charge += amount
	card.construct_peak_charge = maxi(card.construct_peak_charge, card.construct_charge)
	card.current_attack += amount
	var applied: int = int(_construct_atk_applied.get(card, 0))
	_construct_atk_applied[card] = applied + amount
	card.refresh_display()


func _spend_construct_charges(card: UnitCard, charges: int) -> int:
	var actual: int = mini(charges, card.construct_charge)
	if actual <= 0:
		return 0
	card.construct_charge -= actual
	card.current_attack = maxi(1, card.current_attack - actual)
	var applied: int = int(_construct_atk_applied.get(card, 0))
	_construct_atk_applied[card] = maxi(0, applied - actual)
	if card.construct_charge <= 0:
		card.construct_charge = 0
		if card.data.construct_effect == ConstructEffect.Effect.REIGNITER and not card.construct_reignited:
			card.construct_reignited = true
			_add_construct_charge(card, 3, true)
			_log("%s Reignites! Regains 3 Charge!" % card.data.display_name)
		else:
			# Recharge Protocol: first depower per unit per combat gives charge instead
			var protocol_saved := false
			if not card.construct_protocol_used and player_board.units.has(card):
				for ally: UnitCard in player_board.units:
					if is_instance_valid(ally) and not ally.is_dead and ally.data != null \
							and ally.data.construct_effect == ConstructEffect.Effect.RECHARGE_PROTOCOL:
						var rp_gain := 10 if ally.is_radiant else 5
						card.construct_protocol_used = true
						_add_construct_charge(card, rp_gain, true)
						_log("Recharge Protocol: %s avoids Depower, gains %d Charge!" % [card.data.display_name, rp_gain])
						protocol_saved = true
						break
			if not protocol_saved:
				card.construct_depowered = true
				_log("%s is DEPOWERED (0 Charge)!" % card.data.display_name)
				# Overload Core: depowered unit gets +10/+10 this combat
				if player_board.units.has(card):
					for ally: UnitCard in player_board.units:
						if is_instance_valid(ally) and not ally.is_dead and ally.data != null \
								and ally.data.construct_effect == ConstructEffect.Effect.OVERLOAD_CORE:
							var oc_gain := 20 if ally.is_radiant else 10
							_grant_combat_temp_buff(card, oc_gain, oc_gain)
							_log("Overload Core: %s +%d/+%d this combat!" % [card.data.display_name, oc_gain, oc_gain])
							break
	# Discharge Engine + Charge Siphon: per charge point spent
	if player_board.units.has(card):
		for ally: UnitCard in player_board.units:
			if not is_instance_valid(ally) or ally.is_dead or ally.data == null:
				continue
			if ally.data.construct_effect == ConstructEffect.Effect.DISCHARGE_ENGINE:
				var eng_mult := 2 if ally.is_radiant else 1
				for board_unit: UnitCard in player_board.units:
					if is_instance_valid(board_unit) and not board_unit.is_dead:
						board_unit.current_attack += actual * eng_mult
						board_unit.refresh_display()
				_log("Discharge Engine: board +%d ATK!" % (actual * eng_mult))
			if ally.data.construct_effect == ConstructEffect.Effect.CHARGE_SIPHON and ally != card:
				var siphon_gain := actual * 2 if ally.is_radiant else actual
				_grant_permanent_stats(ally, siphon_gain, siphon_gain)
				_log("Charge Siphon: %s +%d/+%d permanently!" % [ally.data.display_name, siphon_gain, siphon_gain])
	card.refresh_display()
	var counter_mult := 2 if card.data.construct_effect == ConstructEffect.Effect.VOLT_STRIKER else 1
	if card.is_radiant and card.data.construct_effect == ConstructEffect.Effect.VOLT_STRIKER:
		counter_mult = 4
	return actual * counter_mult


func _grant_permanent_stats(card: UnitCard, atk: int, hp: int) -> void:
	var cur: Vector2i = pending_permanent_stats.get(card, Vector2i(0, 0))
	pending_permanent_stats[card] = Vector2i(cur.x + atk, cur.y + hp)
	card.current_attack += atk
	card.current_health += hp
	card.refresh_display()


func _grant_combat_temp_buff(card: UnitCard, atk: int, hp: int) -> void:
	card.combat_temp_atk += atk
	card.combat_temp_hp += hp
	card.current_attack += atk
	card.current_health += hp
	card.refresh_display()


func _absorb_construct_damage(card: UnitCard, dmg: int, attacker: UnitCard) -> int:
	var charges: int = card.construct_charge
	if dmg <= charges:
		var counter: int = _spend_construct_charges(card, dmg)
		attacker.current_health -= counter
		_log("%s Charge shield absorbs %d dmg, returns %d!" % [card.data.display_name, dmg, counter])
		return 0
	else:
		var counter: int = _spend_construct_charges(card, charges)
		attacker.current_health -= counter
		_log("%s Charge shield absorbs %d dmg, returns %d, %d spills through!" % [card.data.display_name, charges, counter, dmg - charges])
		return dmg - charges


# ── Reaper: Doom ──────────────────────────────────────────────────────────────

func _apply_doom(target: UnitCard, amount: int) -> void:
	if _doom_counters.has(target):
		var current: int = _doom_counters[target]
		if amount < current:
			_doom_counters[target] = maxi(1, amount - 1)
		else:
			_doom_counters[target] = maxi(1, current - 1)
		_log("%s doom accelerated to %d!" % [target.data.display_name, _doom_counters[target]])
	else:
		_doom_counters[target] = amount
		_log("%s doomed for %d counters!" % [target.data.display_name, amount])
	_update_reaper_aura()
	_check_dread_lord()


func _apply_friendly_doom(target: UnitCard, amount: int) -> void:
	if _friendly_doom_counters.has(target):
		var current: int = _friendly_doom_counters[target]
		_friendly_doom_counters[target] = maxi(1, mini(amount, current) - 1)
		_log("%s friendly doom accelerated to %d!" % [target.data.display_name, _friendly_doom_counters[target]])
	else:
		_friendly_doom_counters[target] = amount
		_log("%s (friendly) doomed for %d counters!" % [target.data.display_name, amount])
	_update_reaper_aura()
	_check_dread_lord()


func _tick_doom_all() -> void:
	if _doom_counters.is_empty():
		return
	var tick := _get_death_sovereign_tick()
	var expired: Array = []
	for enemy in _doom_counters.keys():
		if not is_instance_valid(enemy) or enemy.is_dead:
			expired.append(enemy)
			continue
		_doom_counters[enemy] -= tick
		if _doom_counters[enemy] <= 0:
			expired.append(enemy)
	for enemy in expired:
		_doom_counters.erase(enemy)
		if is_instance_valid(enemy) and not enemy.is_dead:
			var dmg := reaper_shop_data.doom_damage if reaper_shop_data != null else 100
			enemy.current_health -= dmg
			enemy.refresh_display()
			_log("%s's Doom expired — %d damage!" % [enemy.data.display_name, dmg])
			_check_soul_harvester_doom_expire()
	if not expired.is_empty():
		_update_reaper_aura()


func _tick_friendly_doom_all() -> void:
	if _friendly_doom_counters.is_empty():
		return
	var tick := _get_death_sovereign_tick()
	var expired: Array = []
	for unit in _friendly_doom_counters.keys():
		if not is_instance_valid(unit) or unit.is_dead:
			expired.append(unit)
			continue
		_friendly_doom_counters[unit] -= tick
		if _friendly_doom_counters[unit] <= 0:
			expired.append(unit)
	for unit in expired:
		_friendly_doom_counters.erase(unit)
		if is_instance_valid(unit) and not unit.is_dead:
			var base_dmg := reaper_shop_data.doom_damage if reaper_shop_data != null else 100
			unit.current_health -= base_dmg / 2
			unit.refresh_display()
			_log("%s's Doom expired (friendly) — %d damage!" % [unit.data.display_name, base_dmg / 2])
	if not expired.is_empty():
		_update_reaper_aura()


func _update_reaper_aura() -> void:
	if reaper_shop_data == null or reaper_shop_data.reaper_aura_bonus <= 0:
		for card in _reaper_aura_applied.keys():
			if is_instance_valid(card) and not card.is_dead:
				var prev: int = int(_reaper_aura_applied.get(card, 0))
				card.current_attack = maxi(1, card.current_attack - prev)
				card.current_health = maxi(1, card.current_health - prev)
				card.refresh_display()
		_reaper_aura_applied.clear()
		return
	var total_doom: int = 0
	for v in _doom_counters.values():
		total_doom += int(v)
	for v in _friendly_doom_counters.values():
		total_doom += int(v)
	var bonus_per := reaper_shop_data.reaper_aura_bonus
	var new_bonus: int = total_doom * bonus_per
	for card in player_board.units:
		if not is_instance_valid(card) or card.is_dead:
			continue
		if card.data.race != RaceType.Race.REAPER:
			continue
		var prev: int = int(_reaper_aura_applied.get(card, 0))
		var delta: int = new_bonus - prev
		if delta == 0:
			continue
		card.current_attack = maxi(1, card.current_attack + delta)
		card.current_health = maxi(1, card.current_health + delta)
		_reaper_aura_applied[card] = new_bonus
		card.refresh_display()


func _apply_reaper_soc_effects() -> void:
	for card in player_board.units:
		if not is_instance_valid(card) or card.is_dead:
			continue
		if card.data.race != RaceType.Race.REAPER:
			continue
		match card.data.reaper_effect:
			ReaperEffect.Effect.GRAVE_STALKER:
				var alive_enemies := enemy_board.units.filter(func(u): return not u.is_dead)
				alive_enemies.shuffle()
				var gs_count := 4 if card.is_radiant else 2
				for i in range(mini(gs_count, alive_enemies.size())):
					_apply_doom(alive_enemies[i], 8)
				_log("%s SOC: 8 doom to %d random enemies!" % [card.data.display_name, gs_count])
			ReaperEffect.Effect.GRAVE_PACT:
				var all_units: Array = []
				all_units.append_array(player_board.units.filter(func(u): return not u.is_dead))
				all_units.append_array(enemy_board.units.filter(func(u): return not u.is_dead))
				for unit in all_units:
					if not is_instance_valid(unit):
						continue
					if player_board.units.has(unit):
						_apply_friendly_doom(unit, 10)
					else:
						_apply_doom(unit, 10)
				_log("%s SOC: 10 doom to all units!" % card.data.display_name)


# ── Enemy faction setup (mirrors start-of-combat player setup for enemy board) ──

func _apply_enemy_faction_setup() -> void:
	_init_myco_cap_bonus(enemy_board)

	# Construct: apply cache charge and existing persistent charge ATK bonus
	if enemy_construct_shop_data != null:
		var _prev_cd := construct_shop_data
		construct_shop_data = enemy_construct_shop_data
		_apply_construct_charges(enemy_board)
		construct_shop_data = _prev_cd
	else:
		_apply_construct_charges(enemy_board)

	# Aztec: bless all aztec units by enemy's simulated held gold
	if enemy_aztec_shop_data != null and enemy_aztec_gold > 0:
		var _prev_ad := aztec_shop_data
		var _prev_ag := aztec_gold
		aztec_shop_data = enemy_aztec_shop_data
		aztec_gold = enemy_aztec_gold
		_apply_aztec_blessing(enemy_board)
		aztec_shop_data = _prev_ad
		aztec_gold = _prev_ag

	# Myconid: apply spore buff with enemy spore_buff_level
	if enemy_myconid_shop_data != null:
		var _prev_md := myconid_shop_data
		myconid_shop_data = enemy_myconid_shop_data
		_init_spore_hoarder(enemy_board)
		_apply_all_spore_buffs(enemy_board)
		myconid_shop_data = _prev_md
	else:
		_init_spore_hoarder(enemy_board)
		_apply_all_spore_buffs(enemy_board)

	# Elf: apply per-unit SOC abilities (spiritbark buffs etc.)
	_apply_enemy_elf_soc()

	# Covenant: form bonds between enemy units
	_apply_enemy_covenant_soc()

	# Reaper: enemy reapers apply doom to player units
	_apply_enemy_reaper_soc()


func _apply_enemy_elf_soc() -> void:
	var alive := enemy_board.units.filter(func(c): return is_instance_valid(c) and not c.is_dead)
	for i in range(alive.size()):
		var card: UnitCard = alive[i]
		if card.data.race != RaceType.Race.ELF:
			continue
		match card.data.elf_effect:
			ElfEffect.Effect.ECHO_ADJACENT_BUFF:
				var buff := 4 if card.is_radiant else 2
				var neighbors: Array = []
				if i > 0: neighbors.append(alive[i - 1])
				if i < alive.size() - 1: neighbors.append(alive[i + 1])
				for neighbor in neighbors:
					(neighbor as UnitCard).current_keywords |= KeywordFlags.Keyword.ECHO
					(neighbor as UnitCard).current_attack += buff
					(neighbor as UnitCard).current_health += buff
					(neighbor as UnitCard).refresh_display()
				_log("%s (enemy): adjacent units +%d/+%d + Echo!" % [card.data.display_name, buff, buff])
			ElfEffect.Effect.SOC_DOUBLE_ECHO_STAT:
				_soc_echo_stat_mult *= 3.0 if card.is_radiant else 2.0


func _apply_enemy_covenant_soc() -> void:
	if enemy_covenant_shop_data == null:
		return
	var prev_cd := covenant_shop_data
	covenant_shop_data = enemy_covenant_shop_data
	var alive := enemy_board.units.filter(func(c): return is_instance_valid(c) and not c.is_dead)
	for i in range(alive.size()):
		var card: UnitCard = alive[i]
		if card.data.race != RaceType.Race.COVENANT:
			continue
		match card.data.covenant_effect:
			CovenantEffect.Effect.TETHER:
				if card.is_radiant:
					if i > 0:
						_apply_covenant_bond(card, alive[i - 1])
					if i < alive.size() - 1:
						_apply_covenant_bond(card, alive[i + 1])
				else:
					if i > 0:
						_apply_covenant_bond(card, alive[i - 1])
					elif i < alive.size() - 1:
						_apply_covenant_bond(card, alive[i + 1])
			CovenantEffect.Effect.SEEKER:
				var sorted_others_e := alive.filter(func(u): return u != card)
				sorted_others_e.sort_custom(func(a, b): return a.current_attack > b.current_attack)
				var bond_count_e := 2 if card.is_radiant else 1
				for j in range(mini(bond_count_e, sorted_others_e.size())):
					_apply_covenant_bond(card, sorted_others_e[j])
	# Bond Warden aura
	for card: UnitCard in alive:
		if card.data.race != RaceType.Race.COVENANT: continue
		if card.data.covenant_effect != CovenantEffect.Effect.BOND_WARDEN: continue
		var bonus := 6 if card.is_radiant else 3
		for unit: UnitCard in alive:
			if unit.bonded_units.size() > 0:
				unit.current_attack += bonus
				unit.current_health += bonus
				unit.refresh_display()
		_log("%s (enemy) Bond Warden: all bonded units +%d/+%d!" % [card.data.display_name, bonus, bonus])
	covenant_shop_data = prev_cd


func _apply_enemy_reaper_soc() -> void:
	var prev_rd := reaper_shop_data
	if enemy_reaper_shop_data != null:
		reaper_shop_data = enemy_reaper_shop_data
	for card in enemy_board.units:
		if not is_instance_valid(card) or card.is_dead: continue
		if card.data.race != RaceType.Race.REAPER: continue
		match card.data.reaper_effect:
			ReaperEffect.Effect.GRAVE_STALKER:
				var player_alive := player_board.units.filter(func(u): return not u.is_dead)
				player_alive.shuffle()
				for i in range(mini(2, player_alive.size())):
					_apply_doom(player_alive[i], 8)
				_log("%s (enemy) SOC: 8 doom to 2 random player units!" % card.data.display_name)
			ReaperEffect.Effect.GRAVE_PACT:
				for unit in player_board.units:
					if not is_instance_valid(unit) or unit.is_dead: continue
					_apply_doom(unit, 10)
				_log("%s (enemy) SOC: 10 doom to all player units!" % card.data.display_name)
	reaper_shop_data = prev_rd


func _fire_reaper_attack_effects(attacker: UnitCard, defender: UnitCard) -> void:
	if not is_instance_valid(attacker) or attacker.data.race != RaceType.Race.REAPER:
		return
	match attacker.data.reaper_effect:
		ReaperEffect.Effect.WRAITH:
			if is_instance_valid(defender) and not defender.is_dead:
				_apply_doom(defender, 12 if attacker.is_radiant else 6)
		ReaperEffect.Effect.VOID_WRAITH:
			for _i in range(4 if attacker.is_radiant else 2):
				_spawn_reaper_token(player_board)
		ReaperEffect.Effect.WAIL_SPECTER:
			if is_instance_valid(defender) and _doom_counters.has(defender):
				_doom_counters[defender] = maxi(0, _doom_counters[defender] - (6 if attacker.is_radiant else 3))
				if _doom_counters[defender] <= 0:
					_doom_counters.erase(defender)
					if not defender.is_dead:
						var dmg := reaper_shop_data.doom_damage if reaper_shop_data != null else 100
						defender.current_health -= dmg
						defender.refresh_display()
						_log("%s: doom forcefully expired on %s — %d damage!" % [attacker.data.display_name, defender.data.display_name, dmg])
						_check_soul_harvester_doom_expire()
				else:
					_log("%s: %s doom reduced to %d!" % [attacker.data.display_name, defender.data.display_name, _doom_counters[defender]])
				_update_reaper_aura()
		ReaperEffect.Effect.GRAVE_COLLECTOR:
			var targets: Array = []
			if is_instance_valid(defender) and not defender.is_dead:
				targets.append(defender)
				targets.append_array(_get_board_neighbors(enemy_board, defender))
			for t in targets:
				if is_instance_valid(t) and not t.is_dead:
					_apply_doom(t, 8)
		ReaperEffect.Effect.SOUL_HARVESTER:
			if is_instance_valid(defender) and not defender.is_dead:
				_apply_doom(defender, 10 if attacker.is_radiant else 5)


func _reaper_end_of_turn() -> void:
	for card in player_board.units:
		if not is_instance_valid(card) or card.is_dead:
			continue
		if card.data.race == RaceType.Race.REAPER \
				and card.data.reaper_effect == ReaperEffect.Effect.DOOM_HERALD:
			var herald_gain := 20 if card.is_radiant else 10
			if reaper_shop_data != null:
				reaper_shop_data.doom_damage += herald_gain
			_log("%s: Doom Damage +%d → %d!" % [card.data.display_name, herald_gain, reaper_shop_data.doom_damage if reaper_shop_data else 100])


func _check_dread_lord() -> void:
	for card in player_board.units:
		if not is_instance_valid(card) or card.is_dead:
			continue
		if card.data.race == RaceType.Race.REAPER \
				and card.data.reaper_effect == ReaperEffect.Effect.DREAD_LORD:
			for ally in player_board.units:
				if is_instance_valid(ally) and not ally.is_dead:
					ally.current_attack += 5
					ally.current_health += 5
					ally.refresh_display()
			_log("%s: doom applied — board +5/+5!" % card.data.display_name)
			return


func _check_soul_harvester_doom_expire() -> void:
	for card in player_board.units:
		if not is_instance_valid(card) or card.is_dead:
			continue
		if card.data.race == RaceType.Race.REAPER \
				and card.data.reaper_effect == ReaperEffect.Effect.SOUL_HARVESTER:
			var sh_gain := 10 if card.is_radiant else 5
			card.current_attack += sh_gain
			card.current_health += sh_gain
			card.refresh_display()
			_log("%s: doom expired — permanently +%d/+%d!" % [card.data.display_name, sh_gain, sh_gain])


func _get_death_sovereign_tick() -> int:
	for card in player_board.units:
		if is_instance_valid(card) and not card.is_dead \
				and card.data.race == RaceType.Race.REAPER \
				and card.data.reaper_effect == ReaperEffect.Effect.DEATH_SOVEREIGN:
			return 4 if card.is_radiant else 2
	return 1


func _has_death_sovereign() -> bool:
	for card in player_board.units:
		if is_instance_valid(card) and not card.is_dead \
				and card.data.race == RaceType.Race.REAPER \
				and card.data.reaper_effect == ReaperEffect.Effect.DEATH_SOVEREIGN:
			return true
	return false


func _has_pale_shroud() -> bool:
	for card in player_board.units:
		if is_instance_valid(card) and not card.is_dead \
				and card.data.race == RaceType.Race.REAPER \
				and card.data.reaper_effect == ReaperEffect.Effect.PALE_SHROUD:
			return true
	return false


const REAPER_TOKEN_PATH := "res://resources/units/reapers/shadow_token.tres"

func _spawn_reaper_token(board: Board) -> UnitCard:
	if unit_card_scene == null:
		return null
	var alive_count := board.units.filter(func(u): return not u.is_dead).size()
	if alive_count >= MAX_BOARD_SIZE:
		return null
	var token_data: UnitData = load(REAPER_TOKEN_PATH)
	if token_data == null:
		return null
	var token: UnitCard = unit_card_scene.instantiate()
	board.slots_container.add_child(token)
	board.units.append(token)
	token.attack_direction = board.attack_dir
	token.initialize(token_data)
	token.refresh_display()
	_log("Shadow summoned!")
	return token


# ── Myconid: Spores ───────────────────────────────────────────────────────────

func _apply_all_spore_buffs(board: Board) -> void:
	for card in board.units:
		if is_instance_valid(card) and not card.is_dead \
				and card.data.race == RaceType.Race.MYCONID:
			_update_spore_buff(card)


func _add_spores_to(card: UnitCard, amount: int) -> void:
	var actual := amount
	if card.data.myconid_effect == MyconidEffect.Effect.DECOMPOSER:
		actual += 2 if card.is_radiant else 1
	card.myconid_spores += actual
	_update_spore_buff(card)
	_check_sporeguard(card)


func _check_sporeguard(card: UnitCard) -> void:
	if card.data.myconid_effect != MyconidEffect.Effect.SPOREGUARD:
		return
	if card.myconid_spores >= 10 and (card.current_keywords & KeywordFlags.Keyword.DIVINE_SHIELD) == 0:
		card.current_keywords |= KeywordFlags.Keyword.DIVINE_SHIELD
		card.refresh_display()
		_log("%s: 10 spores — Divine Shield granted!" % card.data.display_name)


func _init_spore_hoarder(board: Board) -> void:
	var alive := board.units.filter(func(c): return is_instance_valid(c) and not c.is_dead)
	for i in range(alive.size()):
		var card: UnitCard = alive[i]
		if card.data.myconid_effect != MyconidEffect.Effect.SPORE_HOARDER_SOC:
			continue
		var stolen := 0
		for offset: int in [-1, 1]:
			var idx := i + offset
			if idx < 0 or idx >= alive.size():
				continue
			var adj: UnitCard = alive[idx]
			if adj.data.race != RaceType.Race.MYCONID:
				continue
			var take := adj.myconid_spores if card.is_radiant else adj.myconid_spores / 2
			if take <= 0:
				continue
			adj.myconid_spores -= take
			_update_spore_buff(adj)
			stolen += take
		if stolen > 0:
			_add_spores_to(card, stolen)
			_log("%s: stole %d spores from adjacent Myconids!" % [card.data.display_name, stolen])


func _init_myco_cap_bonus(board: Board) -> void:
	for card in board.units:
		if is_instance_valid(card) and not card.is_dead \
				and card.data.myconid_effect == MyconidEffect.Effect.MYCO_CAP_AURA:
			_myco_cap_soc_bonus = 2 if card.is_radiant else 1
			_log("%s: spores give +%d extra +1/+1 this fight!" % [card.data.display_name, _myco_cap_soc_bonus])
			return



func _update_spore_buff(card: UnitCard) -> void:
	var level: int = myconid_shop_data.spore_buff_level if myconid_shop_data != null else 1
	level += _myco_cap_soc_bonus
	var new_bonus: int = card.myconid_spores * level
	var prev: int = int(_spore_bonus_applied.get(card, 0))
	var delta: int = new_bonus - prev
	if delta == 0:
		return
	card.current_attack = maxi(1, card.current_attack + delta)
	card.current_health = maxi(1, card.current_health + delta)
	_spore_bonus_applied[card] = new_bonus
	card.refresh_display()


func _sporulate() -> void:
	if myconid_shop_data == null:
		return
	var alive := player_board.units.filter(func(c): return is_instance_valid(c) and not c.is_dead)
	# Starting Myconids generate spores
	for card: UnitCard in alive:
		if card.data.race == RaceType.Race.MYCONID \
				and card.data.myconid_effect != MyconidEffect.Effect.PARASITE:
			_add_spores_to(card, myconid_shop_data.sporulation_rate)
	# Sporekeeper: adjacent Myconids gain +1 spore
	for i in range(alive.size()):
		var card: UnitCard = alive[i]
		if card.data.myconid_effect != MyconidEffect.Effect.SPOREKEEPER:
			continue
		if i > 0:
			var adj: UnitCard = alive[i - 1]
			if adj.data.race == RaceType.Race.MYCONID:
				_add_spores_to(adj, 1)
		if i < alive.size() - 1:
			var adj: UnitCard = alive[i + 1]
			if adj.data.race == RaceType.Race.MYCONID:
				_add_spores_to(adj, 1)
	# Bloom: give each Myconid 1 spore per living Myconid on board
	var myconid_alive := alive.filter(func(c): return c.data.race == RaceType.Race.MYCONID)
	var myconid_count := myconid_alive.size()
	for card: UnitCard in alive:
		if card.data.myconid_effect != MyconidEffect.Effect.BLOOM_EOT:
			continue
		var grant := myconid_count * (2 if card.is_radiant else 1)
		for target: UnitCard in myconid_alive:
			_add_spores_to(target, grant)
		_log("%s (Bloom): all %d Myconids +%d spores!" % [card.data.display_name, myconid_count, grant])


func _on_myconid_death(dead: UnitCard, parent_board: Board) -> void:
	# Fungal Ascendant knell is spore-independent — check before early-out
	if dead.data.myconid_effect == MyconidEffect.Effect.FUNGAL_ASCENDANT_KNELL:
		var per_myconid := 2 if dead.is_radiant else 1
		var living_myconids := parent_board.units.filter(func(c): return is_instance_valid(c) and not c.is_dead \
				and c.data.race == RaceType.Race.MYCONID).size()
		var gain := living_myconids * per_myconid
		if gain > 0 and myconid_shop_data != null:
			myconid_shop_data.spore_buff_level += gain
			_apply_all_spore_buffs(parent_board)
			_log("%s Death Knell: spore buff +%d (now %d) from %d living Myconids!" % [
				dead.data.display_name, gain, myconid_shop_data.spore_buff_level, living_myconids])
		return

	var spores := dead.myconid_spores
	if spores <= 0:
		return
	var is_parasite := dead.data.myconid_effect == MyconidEffect.Effect.PARASITE
	if is_parasite:
		var recipient := _find_adjacent_myconid(dead, parent_board)
		if recipient != null:
			_add_spores_to(recipient, spores)
			_log("%s (Parasite): %d spores → %s" % [dead.data.display_name, spores, recipient.data.display_name])
		return

	# Myco Sage: death knell — all friendly Myconids +1/+1 per spore this unit had
	if dead.data.myconid_effect == MyconidEffect.Effect.MYCO_SAGE_KNELL:
		var bonus := spores * (2 if dead.is_radiant else 1)
		for target in parent_board.units:
			if is_instance_valid(target) and not target.is_dead \
					and target.data.race == RaceType.Race.MYCONID:
				target.current_attack += bonus
				target.current_health += bonus
				target.refresh_display()
		_log("%s Death Knell: all Myconids +%d/+%d this fight!" % [dead.data.display_name, bonus, bonus])
		return

	# Spore Vent: death knell — deal 1 dmg per spore to a random enemy, then skip normal distribution
	if dead.data.myconid_effect == MyconidEffect.Effect.SPORE_VENT_KNELL:
		var dmg := spores * (2 if dead.is_radiant else 1)
		var alive_enemies := enemy_board.units.filter(func(u): return not u.is_dead)
		if not alive_enemies.is_empty():
			var vent_target: UnitCard = alive_enemies[randi() % alive_enemies.size()]
			vent_target.current_health -= dmg
			vent_target.refresh_display()
			_log("%s Death Knell: %d spores → %d damage to %s!" % [dead.data.display_name, spores, dmg, vent_target.data.display_name])
		return

	# Default (Sporekeeper etc.): spawn Parasites + split spores to adjacent
	var num_parasites := spores / 10
	var para_spores := spores / 2
	var adj_spores := spores - para_spores

	var adj_recipient := _find_adjacent_myconid(dead, parent_board)
	if adj_recipient != null:
		_add_spores_to(adj_recipient, adj_spores)
		_log("%s dies: %d spores → %s" % [dead.data.display_name, adj_spores, adj_recipient.data.display_name])

	if num_parasites <= 0:
		return

	# Spawn Parasites, splitting para_spores equally; Cultivator doubles/triples the grant
	var spores_each := para_spores / num_parasites * _get_parasite_spore_mult(parent_board)
	for _i in range(num_parasites):
		var alive_count := parent_board.units.filter(func(c): return is_instance_valid(c) and not c.is_dead).size()
		if alive_count >= MAX_BOARD_SIZE:
			_apply_sovereign_overflow(parent_board, 0, 0, spores_each)
			continue
		_spawn_myconid_parasite(parent_board, spores_each)
	_log("%s: %d Parasite(s) spawn with %d spores each" % [dead.data.display_name, num_parasites, spores_each])


func _spawn_myconid_parasite(board: Board, spores: int) -> UnitCard:
	if unit_card_scene == null:
		return null
	var para_data: UnitData = load(MYCONID_PARASITE_PATH)
	if para_data == null:
		push_error("CombatManager: parasite unit data not found!")
		return null
	var token: UnitCard = unit_card_scene.instantiate()
	board.slots_container.add_child(token)
	board.units.append(token)
	token.attack_direction = board.attack_dir
	token.is_draggable = false
	token.initialize(para_data)
	token.myconid_spores = spores
	_update_spore_buff(token)
	token.refresh_display()
	return token


func _get_parasite_spore_mult(board: Board) -> int:
	for card in board.units:
		if is_instance_valid(card) and not card.is_dead \
				and card.data.myconid_effect == MyconidEffect.Effect.CULTIVATOR_AURA:
			return 3 if card.is_radiant else 2
	return 1


func _has_sovereign(board: Board) -> bool:
	for card in board.units:
		if is_instance_valid(card) and not card.is_dead \
				and card.data.myconid_effect == MyconidEffect.Effect.SPORE_SOVEREIGN_AURA:
			return true
	return false


func _apply_sovereign_overflow(board: Board, base_atk: int, base_hp: int, spores: int) -> void:
	var sovereign: UnitCard = null
	for card in board.units:
		if is_instance_valid(card) and not card.is_dead \
				and card.data.myconid_effect == MyconidEffect.Effect.SPORE_SOVEREIGN_AURA:
			sovereign = card
			break
	if sovereign == null:
		return
	var parasites := board.units.filter(func(c): return is_instance_valid(c) and not c.is_dead \
			and c.data.myconid_effect == MyconidEffect.Effect.PARASITE)
	var target_count := 2 if sovereign.is_radiant else 1
	var recipients: Array = []
	if not parasites.is_empty():
		var para_copy := parasites.duplicate()
		para_copy.shuffle()
		for _r in range(mini(target_count, para_copy.size())):
			recipients.append(para_copy[_r])
	if recipients.is_empty():
		recipients.append(sovereign)
	for recipient: UnitCard in recipients:
		if spores > 0:
			_add_spores_to(recipient, spores)
			_log("Spore Sovereign: overflow → %s gains %d spores!" % [recipient.data.display_name, spores])
		else:
			recipient.current_attack += base_atk
			recipient.current_health += base_hp
			recipient.refresh_display()
			_log("Spore Sovereign: overflow → %s gains +%d/+%d!" % [recipient.data.display_name, base_atk, base_hp])


func _find_adjacent_myconid(dead: UnitCard, board: Board) -> UnitCard:
	var all_units := board.units
	var dead_idx := all_units.find(dead)
	if dead_idx < 0:
		return null
	for offset in [-1, 1]:
		var idx: int = dead_idx + offset
		if idx < 0 or idx >= all_units.size():
			continue
		var candidate: UnitCard = all_units[idx]
		if is_instance_valid(candidate) and not candidate.is_dead \
				and candidate.data.race == RaceType.Race.MYCONID:
			return candidate
	return null


# ── Elf / Echo ────────────────────────────────────────────────────────────────

func _apply_elf_soc_effects() -> void:
	var alive := player_board.units.filter(func(c): return is_instance_valid(c) and not c.is_dead)
	for i in range(alive.size()):
		var card: UnitCard = alive[i]
		if card.data.race != RaceType.Race.ELF:
			continue
		match card.data.elf_effect:
			ElfEffect.Effect.ECHO_ADJACENT_BUFF:
				var buff := 4 if card.is_radiant else 2
				var neighbors: Array = []
				if i > 0:
					neighbors.append(alive[i - 1])
				if i < alive.size() - 1:
					neighbors.append(alive[i + 1])
				for neighbor in neighbors:
					(neighbor as UnitCard).current_keywords |= KeywordFlags.Keyword.ECHO
					(neighbor as UnitCard).current_attack += buff
					(neighbor as UnitCard).current_health += buff
					(neighbor as UnitCard).refresh_display()
				_log("Spiritbark: adjacent units gain Echo +%d/+%d!" % [buff, buff])
			ElfEffect.Effect.DOUBLE_NEXT_ECHO:
				_next_echo_mult = 3.0 if card.is_radiant else 2.0
				_log("Soul Tender: next Echo pool entry spawns at %dx stats!" % int(_next_echo_mult))
			ElfEffect.Effect.SOC_DOUBLE_ECHO_STAT:
				_soc_echo_stat_mult *= 3.0 if card.is_radiant else 2.0
				_log("The Dreamer: Echo stat percent %dx this combat!" % (3 if card.is_radiant else 2))

	# Also check support slot
	if support_card != null and is_instance_valid(support_card) and not support_card.is_dead \
			and support_card.data.race == RaceType.Race.ELF:
		match support_card.data.elf_effect:
			ElfEffect.Effect.DOUBLE_NEXT_ECHO:
				_next_echo_mult = 3.0 if support_card.is_radiant else 2.0
			ElfEffect.Effect.SOC_DOUBLE_ECHO_STAT:
				_soc_echo_stat_mult *= 3.0 if support_card.is_radiant else 2.0


func _add_to_echo_pool(dead: UnitCard) -> void:
	var max_e := elf_shop_data.max_echoes if elf_shop_data != null else 2
	if _echo_pool.size() >= max_e:
		return
	var stored_mult := _next_echo_mult
	_next_echo_mult = 1.0
	_echo_pool.append({
		"data": dead.data,
		"attack": dead.current_attack,
		"health": dead.current_health,
		"keywords": dead.current_keywords,
		"double_mult": stored_mult,
	})
	_log("%s enters Echo pool (%d/%d)%s" % [
		dead.data.display_name,
		_echo_pool.size(),
		max_e,
		(" [x%d]" % int(stored_mult)) if stored_mult > 1.0 else ""])


func _spawn_echo_wave() -> void:
	_echo_wave_used = true
	var echo_pct := float(elf_shop_data.echo_stat_percent if elf_shop_data != null else 50)
	var mult := echo_pct / 100.0 * _soc_echo_stat_mult
	var max_spawn := elf_shop_data.max_echoes if elf_shop_data != null else 2
	var to_spawn := _echo_pool.slice(0, max_spawn)
	_log("=== Echo Wave: %d unit(s) return at %d%% stats ===" % [
		to_spawn.size(), roundi(echo_pct * _soc_echo_stat_mult)])
	for entry: Dictionary in to_spawn:
		if unit_card_scene == null:
			break
		var token: UnitCard = unit_card_scene.instantiate()
		player_board.slots_container.add_child(token)
		player_board.units.append(token)
		token.attack_direction = player_board.attack_dir
		token.initialize(entry["data"])
		var entry_mult: float = mult * float(entry.get("double_mult", 1.0))
		token.current_attack = maxi(1, roundi(float(entry["attack"]) * entry_mult))
		token.current_health = maxi(1, roundi(float(entry["health"]) * entry_mult))
		token.current_keywords = entry["keywords"] & ~KeywordFlags.Keyword.ECHO
		token.refresh_display()
		_log("Echo: %s returns at %d/%d" % [
			(entry["data"] as UnitData).display_name, token.current_attack, token.current_health])
	await get_tree().create_timer(0.45).timeout


func _fire_elf_attack_effects(attacker: UnitCard) -> void:
	if attacker.data.race != RaceType.Race.ELF:
		return
	if attacker.data.elf_effect == ElfEffect.Effect.ON_ATTACK_BUFF_ECHOED:
		var buff := 4 if attacker.is_radiant else 2
		var echoed := player_board.units.filter(func(u):
			return is_instance_valid(u) and not u.is_dead \
					and (u.current_keywords & KeywordFlags.Keyword.ECHO) != 0)
		if echoed.is_empty():
			return
		for unit: UnitCard in echoed:
			unit.current_attack += buff
			unit.current_health += buff
			unit.refresh_display()
		_log("Fernweave: %d echoed unit(s) +%d/+%d!" % [echoed.size(), buff, buff])


func _check_elf_on_kill(attacker: UnitCard) -> void:
	if not is_instance_valid(attacker) or attacker.is_dead:
		return
	if attacker.data.race != RaceType.Race.ELF:
		return
	if attacker.data.elf_effect != ElfEffect.Effect.ON_KILL_STATS:
		return
	var gain := 6 if attacker.is_radiant else 3
	attacker.current_attack += gain
	attacker.current_health += gain
	attacker.refresh_display()
	_log("%s on kill: +%d/+%d!" % [attacker.data.display_name, gain, gain])


# ── Covenant / Blood Bond ─────────────────────────────────────────────────────

func _apply_covenant_soc_effects() -> void:
	var alive := player_board.units.filter(func(c): return is_instance_valid(c) and not c.is_dead)
	for i in range(alive.size()):
		var card: UnitCard = alive[i]
		if card.data.race != RaceType.Race.COVENANT:
			continue
		match card.data.covenant_effect:
			CovenantEffect.Effect.TETHER:
				if card.is_radiant:
					if i > 0:
						_apply_covenant_bond(card, alive[i - 1])
					if i < alive.size() - 1:
						_apply_covenant_bond(card, alive[i + 1])
				else:
					if i > 0:
						_apply_covenant_bond(card, alive[i - 1])
					elif i < alive.size() - 1:
						_apply_covenant_bond(card, alive[i + 1])
			CovenantEffect.Effect.SEEKER:
				var sorted_others := alive.filter(func(u): return u != card)
				sorted_others.sort_custom(func(a, b): return a.current_attack > b.current_attack)
				var bond_count := 2 if card.is_radiant else 1
				for j in range(mini(bond_count, sorted_others.size())):
					_apply_covenant_bond(card, sorted_others[j])
			CovenantEffect.Effect.SOUL_TETHER:
				if card.is_radiant:
					if i > 0:
						_apply_covenant_bond(card, alive[i - 1])
					if i < alive.size() - 1:
						_apply_covenant_bond(card, alive[i + 1])
				else:
					if i > 0:
						_apply_covenant_bond(card, alive[i - 1])
					elif i < alive.size() - 1:
						_apply_covenant_bond(card, alive[i + 1])
				var enemy_alive := enemy_board.units.filter(
					func(c): return is_instance_valid(c) and not c.is_dead)
				if card.is_radiant:
					enemy_alive.shuffle()
					for k in range(mini(2, enemy_alive.size())):
						_apply_covenant_bond(card, enemy_alive[k])
				elif not enemy_alive.is_empty():
					_apply_covenant_bond(card, enemy_alive[randi() % enemy_alive.size()])

	# Bond Warden aura: all bonded units +3/+3 at start of combat
	for card: UnitCard in alive:
		if card.data.race != RaceType.Race.COVENANT:
			continue
		if card.data.covenant_effect != CovenantEffect.Effect.BOND_WARDEN:
			continue
		var bonus := 6 if card.is_radiant else 3
		var bonded_found := false
		for unit: UnitCard in alive:
			if unit.bonded_units.size() > 0:
				unit.current_attack += bonus
				unit.current_health += bonus
				unit.refresh_display()
				bonded_found = true
		if bonded_found:
			_log("%s aura: all bonded units +%d/+%d!" % [card.data.display_name, bonus, bonus])


func _apply_covenant_bond(a: UnitCard, b: UnitCard) -> void:
	if not is_instance_valid(a) or not is_instance_valid(b) or a == b:
		return
	if a.bonded_units.has(b):
		return
	a.bonded_units.append(b)
	b.bonded_units.append(a)
	if covenant_shop_data != null:
		var pct := covenant_shop_data.bond_share_percent
		var a_atk := roundi(float(a.current_attack) * pct / 100.0)
		var a_hp  := roundi(float(a.current_health) * pct / 100.0)
		var b_atk := roundi(float(b.current_attack) * pct / 100.0)
		var b_hp  := roundi(float(b.current_health) * pct / 100.0)
		a.current_attack += b_atk
		a.current_health += b_hp
		b.current_attack += a_atk
		b.current_health += a_hp
		a.refresh_display()
		b.refresh_display()
		_log("%s bonds with %s (%d%% share): +%d/+%d | +%d/+%d" % [
			a.data.display_name, b.data.display_name, pct,
			b_atk, b_hp, a_atk, a_hp])
	else:
		_log("%s bonds with %s!" % [a.data.display_name, b.data.display_name])


func _fire_covenant_attack_effects(attacker: UnitCard, defender: UnitCard) -> void:
	# Pact Kin: permanently +2 HP on attack; +2 ATK too if bonded
	if is_instance_valid(attacker) \
			and attacker.data.race == RaceType.Race.COVENANT \
			and attacker.data.covenant_effect == CovenantEffect.Effect.PACT_KIN:
		var hp_gain := 4 if attacker.is_radiant else 2
		attacker.current_health += hp_gain
		var msg := "%s: +%d HP" % [attacker.data.display_name, hp_gain]
		if attacker.bonded_units.size() > 0:
			var atk_gain := 4 if attacker.is_radiant else 2
			attacker.current_attack += atk_gain
			msg += " +%d ATK (bonded)" % atk_gain
		attacker.refresh_display()
		_log(msg)

	# Rite Herald: when a friendly attacks, board +2/+2 (combat-only)
	for card in player_board.units:
		if not is_instance_valid(card) or card.is_dead:
			continue
		if card.data.race == RaceType.Race.COVENANT \
				and card.data.covenant_effect == CovenantEffect.Effect.RITE_HERALD:
			var buff := 4 if card.is_radiant else 2
			for ally in player_board.units:
				if is_instance_valid(ally) and not ally.is_dead:
					ally.current_attack += buff
					ally.current_health += buff
					ally.refresh_display()
			_log("%s: friendly attacked — board +%d/+%d!" % [card.data.display_name, buff, buff])


func _covenant_end_of_turn() -> void:
	if covenant_shop_data == null:
		return
	for card in player_board.units:
		if not is_instance_valid(card) or card.is_dead:
			continue
		if card.data.race == RaceType.Race.COVENANT \
				and card.data.covenant_effect == CovenantEffect.Effect.WEAVE_KIN:
			var gain := 10 if card.is_radiant else 5
			covenant_shop_data.bond_share_percent += gain
			_log("%s: Bond Share +%d%% → %d%%!" % [
				card.data.display_name, gain, covenant_shop_data.bond_share_percent])


func _trigger_berserk(card: UnitCard, dead_partner: UnitCard) -> void:
	if not is_instance_valid(card) or card.is_dead:
		return
	var card_board := player_board if player_board.units.has(card) else enemy_board
	var opp_board  := enemy_board  if card_board == player_board else player_board

	# Stat gain
	if covenant_shop_data != null and covenant_shop_data.berserk_multiplier_percent > 0:
		var mult_pct := covenant_shop_data.berserk_multiplier_percent
		if card.data.race == RaceType.Race.COVENANT \
				and card.data.covenant_effect == CovenantEffect.Effect.FURY_KIN:
			mult_pct *= 3 if card.is_radiant else 2
		var gain_atk := roundi(float(card.current_attack) * mult_pct / 100.0)
		var gain_hp  := roundi(float(card.current_health) * mult_pct / 100.0)
		card.current_attack += gain_atk
		card.current_health += gain_hp
		card.refresh_display()
		_log("%s berserk stat gain: +%d/+%d!" % [card.data.display_name, gain_atk, gain_hp])

	# Vow Guard: grant Divine Shield on berserk (Radiant: also share berserk bonus with adjacent)
	var vow_guard_card := _get_vow_guard(card_board)
	if vow_guard_card != null:
		card.current_keywords |= KeywordFlags.Keyword.DIVINE_SHIELD
		card.refresh_display()
		_log("%s gains Divine Shield (Vow Guard)!" % card.data.display_name)
		if vow_guard_card.is_radiant and covenant_shop_data != null \
				and covenant_shop_data.berserk_multiplier_percent > 0:
			var vg_alive := card_board.units.filter(func(u): return is_instance_valid(u) and not u.is_dead)
			var vg_card_idx := vg_alive.find(card)
			for vg_offset in [-1, 1]:
				var vg_adj_idx: int = vg_card_idx + vg_offset
				if vg_adj_idx >= 0 and vg_adj_idx < vg_alive.size():
					var vg_adj: UnitCard = vg_alive[vg_adj_idx]
					var vg_mult_pct := covenant_shop_data.berserk_multiplier_percent
					vg_adj.current_attack += roundi(float(vg_adj.current_attack) * vg_mult_pct / 100.0)
					vg_adj.current_health += roundi(float(vg_adj.current_health) * vg_mult_pct / 100.0)
					vg_adj.refresh_display()
					_log("Radiant Vow Guard: %s also gains berserk bonus!" % vg_adj.data.display_name)

	# Bond Shatter: board +5/+5 (combat-only) when bond breaks
	if card_board == player_board:
		for ally in player_board.units:
			if not is_instance_valid(ally) or ally.is_dead:
				continue
			if ally.data.race == RaceType.Race.COVENANT \
					and ally.data.covenant_effect == CovenantEffect.Effect.BOND_SHATTER:
				var shatter_buff := 10 if ally.is_radiant else 5
				for target in player_board.units:
					if is_instance_valid(target) and not target.is_dead:
						target.current_attack += shatter_buff
						target.current_health += shatter_buff
						target.refresh_display()
				_log("%s: bond broke — board +%d/+%d!" % [ally.data.display_name, shatter_buff, shatter_buff])

	_log("%s goes BERSERK!" % card.data.display_name)

	if not opp_board.has_living_units():
		return
	var berserk_target: UnitCard = null
	var killer: UnitCard = _unit_killers.get(dead_partner, null)
	if killer != null and is_instance_valid(killer) and not killer.is_dead \
			and opp_board.units.has(killer):
		berserk_target = killer
	if berserk_target == null:
		var alive_enemies := opp_board.units.filter(
			func(u): return is_instance_valid(u) and not u.is_dead)
		if not alive_enemies.is_empty():
			berserk_target = alive_enemies[randi() % alive_enemies.size()]
	if berserk_target == null:
		return

	berserk_target.show_targeted(true)
	await get_tree().create_timer(0.1).timeout
	await card.flash_attack_toward(berserk_target.global_position + berserk_target.size * 0.5)
	berserk_target.show_targeted(false)
	await _resolve_attack(card, berserk_target, card_board, opp_board)
	card.refresh_display()
	berserk_target.refresh_display()
	if berserk_target.current_health <= 0:
		_unit_killers[berserk_target] = card
		# Chain Hunter cascade: bond the new target before death is processed (Radiant: twice)
		if card.data.race == RaceType.Race.COVENANT \
				and card.data.covenant_effect == CovenantEffect.Effect.CHAIN_HUNTER:
			_apply_covenant_bond(card, berserk_target)
			if card.is_radiant:
				_apply_covenant_bond(card, berserk_target)


func _get_vow_guard(board: Board) -> UnitCard:
	for card in board.units:
		if is_instance_valid(card) and not card.is_dead \
				and card.data.race == RaceType.Race.COVENANT \
				and card.data.covenant_effect == CovenantEffect.Effect.VOW_GUARD:
			return card
	return null


func _rite_spawner_covenantling_attack(
		spawner: UnitCard, target: UnitCard,
		attacker_board: Board, defender_board: Board) -> void:
	if unit_card_scene == null:
		return
	var covenantling_data := load("res://resources/units/covenant/covenantling.tres") as UnitData
	if covenantling_data == null:
		push_error("CombatManager: covenantling.tres not found!")
		return
	var spawn_count := 2 if spawner.is_radiant else 1
	for _spawn_i in range(spawn_count):
		var alive_count := attacker_board.units.filter(func(u): return not u.is_dead).size()
		if alive_count >= MAX_BOARD_SIZE:
			break
		var token: UnitCard = unit_card_scene.instantiate()
		attacker_board.slots_container.add_child(token)
		var spawner_idx := attacker_board.units.find(spawner)
		attacker_board.units.insert(spawner_idx, token)
		attacker_board.slots_container.move_child(token, spawner.get_index())
		token.attack_direction = attacker_board.attack_dir
		token.initialize(covenantling_data)
		token.refresh_display()
		_apply_covenant_bond(spawner, token)
		_log("%s summons a Covenantling!" % spawner.data.display_name)
		if not is_instance_valid(target) or target.is_dead:
			continue
		target.show_targeted(true)
		await get_tree().create_timer(0.12).timeout
		await token.flash_attack_toward(target.global_position + target.size * 0.5)
		target.show_targeted(false)
		await _resolve_attack(token, target, attacker_board, defender_board)
		token.refresh_display()
		target.refresh_display()
		if target.current_health <= 0:
			_unit_killers[target] = token


# ── Satyr system ─────────────────────────────────────────────────────────────

func _is_silver_satyr(effect: int) -> bool:
	return effect in [
		SatyrEffect.Effect.SILVER,
		SatyrEffect.Effect.SILVER_T2,
		SatyrEffect.Effect.SILVER_T3,
		SatyrEffect.Effect.SILVER_T4,
	]


func _is_black_basic_satyr(effect: int) -> bool:
	return effect in [SatyrEffect.Effect.BLACK, SatyrEffect.Effect.BLACK_T2]


func _get_mono_color(board: Board) -> int:
	var found_color := 0
	for card in board.units:
		if not is_instance_valid(card) or card.is_dead:
			continue
		if card.data.race != RaceType.Race.SATYR:
			continue
		var c: int = card.data.satyr_color
		if c == SatyrColor.Hue.PRISMATIC or c == SatyrColor.Hue.NONE:
			return 0
		if found_color == 0:
			found_color = c
		elif found_color != c:
			return 0
	return found_color


func _count_distinct_satyr_colors(board: Board) -> int:
	var colors: Dictionary = {}
	for card in board.units:
		if not is_instance_valid(card) or card.is_dead:
			continue
		if card.data.race != RaceType.Race.SATYR:
			continue
		var c: int = card.data.satyr_color
		if c == SatyrColor.Hue.PRISMATIC:
			for i in range(1, 6):
				colors[i] = true
		elif c != SatyrColor.Hue.NONE:
			colors[c] = true
	return colors.size()


func _has_auric_mirror(board: Board) -> bool:
	for card in board.units:
		if is_instance_valid(card) and not card.is_dead \
				and card.data.race == RaceType.Race.SATYR \
				and card.data.satyr_effect == SatyrEffect.Effect.GOLD_T4:
			return true
	return false


func _get_highest_hp_target(targets: Array) -> UnitCard:
	var highest: UnitCard = targets[0]
	for t: UnitCard in targets:
		if t.current_health > highest.current_health:
			highest = t
	return highest


func _apply_satyr_soc_effects() -> void:
	_apply_satyr_gold_aura(player_board)
	_apply_satyr_gold_aura(enemy_board)
	if satyr_shop_data != null:
		_apply_satyr_prismatic_buff(player_board, satyr_shop_data)
	if enemy_satyr_shop_data != null:
		_apply_satyr_prismatic_buff(enemy_board, enemy_satyr_shop_data)


func _apply_satyr_gold_aura(board: Board) -> void:
	var sd: SatyrShopData = satyr_shop_data if board == player_board else enemy_satyr_shop_data
	if sd == null:
		return
	var has_auric := _has_auric_mirror(board)
	var has_gold_t3 := false
	for card in board.units:
		if is_instance_valid(card) and not card.is_dead \
				and card.data.race == RaceType.Race.SATYR \
				and card.data.satyr_effect == SatyrEffect.Effect.GOLD_T3:
			has_gold_t3 = true
			break
	var mono_gold := _get_mono_color(board) == SatyrColor.Hue.GOLD
	for gold_src in board.units:
		if not is_instance_valid(gold_src) or gold_src.is_dead:
			continue
		if gold_src.data.race != RaceType.Race.SATYR:
			continue
		var is_gold: bool = gold_src.data.satyr_color == SatyrColor.Hue.GOLD
		var is_silver_as_gold: bool = has_auric and gold_src.data.satyr_color == SatyrColor.Hue.SILVER
		if not is_gold and not is_silver_as_gold:
			continue
		var bonus: int = sd.gold_atk_bonus * (2 if mono_gold else 1)
		for ally in board.units:
			if not is_instance_valid(ally) or ally.is_dead or ally == gold_src:
				continue
			ally.current_attack += bonus
			_satyr_gold_aura_applied[ally] = int(_satyr_gold_aura_applied.get(ally, 0)) + bonus
			if has_gold_t3:
				ally.current_health += bonus / 2
			ally.refresh_display()
		_log("%s Gold Aura: allies +%d ATK!" % [gold_src.data.display_name, bonus])


func _apply_satyr_prismatic_buff(board: Board, sd: SatyrShopData) -> void:
	var color_count := _count_distinct_satyr_colors(board)
	if color_count == 0:
		return
	var pct: int = sd.prismatic_percent * color_count
	for card in board.units:
		if not is_instance_valid(card) or card.is_dead:
			continue
		card.current_attack += roundi(float(card.current_attack) * pct / 100.0)
		card.current_health += roundi(float(card.current_health) * pct / 100.0)
		card.refresh_display()
	_log("Prismatic Satyr: board +%d%% stats (%d colors)!" % [pct, color_count])


func _apply_black_satyr_on_hit(
		attacker: UnitCard, defender_board: Board, attacker_board: Board) -> void:
	var sd: SatyrShopData = satyr_shop_data if attacker_board == player_board else enemy_satyr_shop_data
	var pct: int = sd.black_debuff_percent if sd != null else 10
	var alive_enemies := defender_board.units.filter(
		func(u): return is_instance_valid(u) and not u.is_dead)
	if not alive_enemies.is_empty():
		var target: UnitCard = alive_enemies[randi() % alive_enemies.size()]
		var reduce := maxi(1, roundi(float(target.current_attack) * pct / 100.0))
		target.current_attack = maxi(0, target.current_attack - reduce)
		target.refresh_display()
		_log("%s: Black curse — %s ATK -%d!" % [attacker.data.display_name, target.data.display_name, reduce])
	_spawn_satyr_token(SatyrColor.Hue.BLACK, attacker_board)


func _spawn_satyr_token(color: int, board: Board) -> void:
	if unit_card_scene == null:
		return
	var alive_count := board.units.filter(func(u): return not u.is_dead).size()
	if alive_count >= MAX_BOARD_SIZE:
		return
	var path: String = SATYR_TOKEN_PATHS.get(color, "")
	if path.is_empty():
		return
	var token_data := load(path) as UnitData
	if token_data == null:
		return
	var token: UnitCard = unit_card_scene.instantiate()
	board.slots_container.add_child(token)
	board.units.append(token)
	token.attack_direction = board.attack_dir
	token.initialize(token_data)
	token.refresh_display()
	_log("Satyr token summoned: %s!" % token_data.display_name)


func _spawn_satyr_unit(data: UnitData, board: Board, dead_card: UnitCard = null) -> UnitCard:
	if unit_card_scene == null:
		return null
	var alive_count := board.units.filter(func(u): return not u.is_dead).size()
	if alive_count >= MAX_BOARD_SIZE:
		return null
	var unit: UnitCard = unit_card_scene.instantiate()
	board.slots_container.add_child(unit)
	if dead_card != null and board.units.has(dead_card):
		var visual_idx := dead_card.get_index()
		var logical_idx := board.units.find(dead_card)
		board.units.insert(logical_idx, unit)
		board.slots_container.move_child(unit, visual_idx)
	else:
		board.units.append(unit)
	unit.attack_direction = board.attack_dir
	unit.initialize(data)
	unit.refresh_display()
	return unit


func _satyr_burst_damage(amount: int, target_board: Board, source: UnitCard) -> void:
	var alive := target_board.units.filter(func(u): return is_instance_valid(u) and not u.is_dead)
	if alive.is_empty():
		return
	var targ: UnitCard = alive[randi() % alive.size()]
	targ.current_health -= amount
	targ.refresh_display()
	_log("%s: death burst — %s takes %d damage!" % [source.data.display_name, targ.data.display_name, amount])


func _fire_satyr_attack_effects(
		attacker: UnitCard, defender: UnitCard,
		attacker_board: Board, defender_board: Board) -> void:
	if attacker.data.race != RaceType.Race.SATYR:
		return
	var sd: SatyrShopData = satyr_shop_data if attacker_board == player_board else enemy_satyr_shop_data
	# Silver T3 (Lunar Surge): on attack, all satyrs +2/+2 per Silver Satyr alive
	if attacker.data.satyr_effect == SatyrEffect.Effect.SILVER_T3:
		var silver_count := 0
		for card in attacker_board.units:
			if is_instance_valid(card) and not card.is_dead \
					and card.data.race == RaceType.Race.SATYR \
					and card.data.satyr_color == SatyrColor.Hue.SILVER:
				silver_count += 1
		if silver_count > 0:
			var buff := 2 * silver_count
			for ally in attacker_board.units:
				if is_instance_valid(ally) and not ally.is_dead:
					ally.current_attack += buff
					ally.current_health += buff
					ally.refresh_display()
			_log("%s Lunar Surge: board +%d/+%d (%d Silver)!" % [
				attacker.data.display_name, buff, buff, silver_count])
	# Black T3 (Pestilence): on attack, debuff both adjacent enemies of the target
	if attacker.data.satyr_effect == SatyrEffect.Effect.BLACK_T3 \
			and is_instance_valid(defender) and not defender.is_dead:
		var pct: int = sd.black_debuff_percent if sd != null else 10
		for nb in _get_board_neighbors(defender_board, defender):
			if is_instance_valid(nb) and not nb.is_dead:
				var reduce := maxi(1, roundi(float(nb.current_attack) * pct / 100.0))
				nb.current_attack = maxi(0, nb.current_attack - reduce)
				nb.refresh_display()
				_log("%s Pestilence: %s ATK -%d!" % [attacker.data.display_name, nb.data.display_name, reduce])
	# Black T4 (Pack Sovereign): whenever a friendly satyr attacks, debuff the target
	if is_instance_valid(defender) and not defender.is_dead:
		for ally in attacker_board.units:
			if not is_instance_valid(ally) or ally.is_dead:
				continue
			if ally.data.race != RaceType.Race.SATYR:
				continue
			if ally.data.satyr_effect != SatyrEffect.Effect.BLACK_T4:
				continue
			var pct: int = sd.black_debuff_percent if sd != null else 10
			var reduce := maxi(1, roundi(float(defender.current_attack) * pct / 100.0))
			defender.current_attack = maxi(0, defender.current_attack - reduce)
			defender.refresh_display()
			_log("%s Pack Sovereign: %s ATK -%d!" % [ally.data.display_name, defender.data.display_name, reduce])
			break


func _check_satyr_kill_effects(attacker: UnitCard) -> void:
	# Silver T4: on any kill, board +3/+3 permanently
	for ally in player_board.units:
		if not is_instance_valid(ally) or ally.is_dead:
			continue
		if ally.data.race != RaceType.Race.SATYR:
			continue
		if ally.data.satyr_effect != SatyrEffect.Effect.SILVER_T4:
			continue
		for board_unit in player_board.units:
			if is_instance_valid(board_unit) and not board_unit.is_dead:
				board_unit.current_attack += 3
				board_unit.current_health += 3
				board_unit.refresh_display()
		_log("%s: kill — board +3/+3!" % ally.data.display_name)
		break


func _satyr_end_of_turn() -> void:
	if satyr_shop_data == null:
		return
	for card in player_board.units:
		if not is_instance_valid(card) or card.is_dead:
			continue
		if card.data.race != RaceType.Race.SATYR:
			continue
		if card.data.satyr_effect == SatyrEffect.Effect.BLACK_T2:
			satyr_shop_data.black_debuff_percent += 5
			_log("%s: Plague Sovereign — black debuff now %d%%!" % [
				card.data.display_name, satyr_shop_data.black_debuff_percent])


func _on_satyr_death(dead: UnitCard, parent_board: Board, newly_dead: Array) -> void:
	if dead.data.race != RaceType.Race.SATYR:
		return
	var sd: SatyrShopData = satyr_shop_data if parent_board == player_board else enemy_satyr_shop_data
	var is_player := parent_board == player_board
	var knell_mult := _get_knell_multiplier(parent_board, newly_dead)
	var opp_board := enemy_board if parent_board == player_board else player_board

	# Gold aura removal: when a Gold satyr dies, subtract its aura from allies
	if dead.data.satyr_color == SatyrColor.Hue.GOLD:
		var gold_bonus: int = sd.gold_atk_bonus if sd != null else 1
		for ally in parent_board.units:
			if not is_instance_valid(ally) or ally.is_dead:
				continue
			if not _satyr_gold_aura_applied.has(ally):
				continue
			var applied := int(_satyr_gold_aura_applied.get(ally, 0))
			var remove := mini(applied, gold_bonus)
			ally.current_attack = maxi(0, ally.current_attack - remove)
			_satyr_gold_aura_applied[ally] = applied - remove
			if _satyr_gold_aura_applied[ally] <= 0:
				_satyr_gold_aura_applied.erase(ally)
			ally.refresh_display()

	# Crimson effects: all crimson satyrs deal 1 death burst; tier extras stack
	if dead.data.satyr_color == SatyrColor.Hue.CRIMSON and not dead.data.is_satyr_token:
		var crimson_dmg: int = sd.crimson_damage if sd != null else 5
		if _get_mono_color(parent_board) == SatyrColor.Hue.CRIMSON:
			crimson_dmg *= 2
		for _i in range(knell_mult):
			_satyr_burst_damage(crimson_dmg, opp_board, dead)
		if dead.data.satyr_effect == SatyrEffect.Effect.CRIMSON_T3:
			for _i in range(2 * knell_mult):
				_satyr_burst_damage(crimson_dmg, opp_board, dead)
		if dead.data.satyr_effect == SatyrEffect.Effect.CRIMSON_T2 and is_player and sd != null:
			sd.crimson_damage += 1 * knell_mult
			_log("%s: crimson_damage now %d!" % [dead.data.display_name, sd.crimson_damage])

	# Gold effects
	if dead.data.satyr_color == SatyrColor.Hue.GOLD and not dead.data.is_satyr_token:
		if dead.data.satyr_effect == SatyrEffect.Effect.GOLD_T2 and is_player and sd != null:
			sd.prismatic_percent += 5 * knell_mult
			_log("%s: prismatic_percent now %d%%!" % [dead.data.display_name, sd.prismatic_percent])

	# Green effects
	if dead.data.satyr_color == SatyrColor.Hue.GREEN and not dead.data.is_satyr_token:
		var green_bonus: int = sd.green_stat_bonus if sd != null else 1
		if _get_mono_color(parent_board) == SatyrColor.Hue.GREEN:
			green_bonus *= 2
		match dead.data.satyr_effect:
			SatyrEffect.Effect.GREEN:
				var green_targets := parent_board.units.filter(func(u):
					return is_instance_valid(u) and not u.is_dead \
						and u.data.race == RaceType.Race.SATYR \
						and u.data.satyr_color == SatyrColor.Hue.GREEN \
						and u != dead)
				if not green_targets.is_empty():
					var targ: UnitCard = green_targets[randi() % green_targets.size()]
					targ.current_attack += green_bonus * knell_mult
					targ.current_health += green_bonus * knell_mult
					targ.refresh_display()
					_log("%s: deathrattle — %s +%d/+%d!" % [
						dead.data.display_name, targ.data.display_name,
						green_bonus * knell_mult, green_bonus * knell_mult])
			SatyrEffect.Effect.GREEN_T2:
				var green_data := load(GREEN_SATYR_PATH) as UnitData
				if green_data != null:
					for _i in range(2 * knell_mult):
						_spawn_satyr_unit(green_data, parent_board)
						_log("%s: Grove Caller — summoned Green Satyr!" % dead.data.display_name)
			SatyrEffect.Effect.GREEN_T3:
				if is_player and sd != null:
					sd.green_stat_bonus += 1 * knell_mult
					_log("%s: green_stat_bonus now %d!" % [dead.data.display_name, sd.green_stat_bonus])
			SatyrEffect.Effect.GREEN_T4:
				var path := dead.data.resource_path
				var spawns := int(_eternal_grove_spawns.get(path, 0))
				if spawns < 2:
					_eternal_grove_spawns[path] = spawns + 1
					_spawn_satyr_unit(dead.data, parent_board, dead)
					_log("%s: Eternal Grove — resummoned! (%d/2)" % [dead.data.display_name, spawns + 1])

	# Prismatic Reveler: summon a random color token when any satyr (non-token) dies
	if not dead.data.is_satyr_token:
		for ally in parent_board.units:
			if not is_instance_valid(ally) or ally.is_dead:
				continue
			if ally.data.race != RaceType.Race.SATYR:
				continue
			if ally.data.satyr_effect != SatyrEffect.Effect.PRISMATIC_T4:
				continue
			var random_color: int = (randi() % 5) + 1
			_spawn_satyr_token(random_color, parent_board)
			_log("%s: Prismatic Reveler — summoned color %d token!" % [ally.data.display_name, random_color])
			break
