extends Control

const UnitCardScene := preload("res://scenes/unit_card.tscn")

const ALL_UNITS := [
	preload("res://resources/units/footman.tres"),
	preload("res://resources/units/defender.tres"),
	preload("res://resources/units/viper.tres"),
	preload("res://resources/units/warrior.tres"),
	preload("res://resources/units/harvest_golem.tres"),
	preload("res://resources/units/humans/grunt.tres"),
	preload("res://resources/units/humans/gunslinger.tres"),
	preload("res://resources/units/humans/recruit.tres"),
	preload("res://resources/units/humans/sharpshooter.tres"),
	preload("res://resources/units/humans/arms_dealer.tres"),
	preload("res://resources/units/humans/brawler.tres"),
	preload("res://resources/units/humans/demolitionist.tres"),
	preload("res://resources/units/humans/gunner.tres"),
	preload("res://resources/units/humans/commander.tres"),
	preload("res://resources/units/humans/breacher.tres"),
	preload("res://resources/units/humans/ranger.tres"),
	preload("res://resources/units/humans/heavy.tres"),
	preload("res://resources/units/humans/quartermaster.tres"),
	preload("res://resources/units/humans/warlord.tres"),
	preload("res://resources/units/humans/duelist.tres"),
	preload("res://resources/units/mages/novice.tres"),
	preload("res://resources/units/mages/acolyte.tres"),
	preload("res://resources/units/mages/familiar.tres"),
	preload("res://resources/units/mages/runecaller.tres"),
	preload("res://resources/units/mages/coin_sage.tres"),
	preload("res://resources/units/mages/harrower.tres"),
	preload("res://resources/units/mages/spellwright.tres"),
	preload("res://resources/units/mages/warden.tres"),
	preload("res://resources/units/mages/arcane_conduit.tres"),
	preload("res://resources/units/mages/wellspring.tres"),
	preload("res://resources/units/mages/hexweaver.tres"),
	preload("res://resources/units/mages/echo_caster.tres"),
	preload("res://resources/units/mages/runic_scribe.tres"),
	preload("res://resources/units/mages/arcanist.tres"),
	preload("res://resources/units/mages/channeler.tres"),
	preload("res://resources/units/mages/warchanter.tres"),
	preload("res://resources/units/grave_conductor.tres"),
	preload("res://resources/units/surge_master.tres"),
	preload("res://resources/units/goblins/mob_runt.tres"),
	preload("res://resources/units/goblins/grub_grabber.tres"),
	preload("res://resources/units/goblins/sneak.tres"),
	preload("res://resources/units/goblins/pack_leader.tres"),
	preload("res://resources/units/goblins/scrap_bomber.tres"),
	preload("res://resources/units/goblins/brood_witch.tres"),
	preload("res://resources/units/goblins/litter_lord.tres"),
	preload("res://resources/units/goblins/warchief.tres"),
	preload("res://resources/units/goblins/rabble_riser.tres"),
	preload("res://resources/units/goblins/taskmaster.tres"),
	preload("res://resources/units/goblins/bomb_king.tres"),
	preload("res://resources/units/goblins/rage_brand.tres"),
	preload("res://resources/units/goblins/reckoner.tres"),
	preload("res://resources/units/goblins/chaos_caller.tres"),
	preload("res://resources/units/goblins/witch_doctor.tres"),
	preload("res://resources/units/elves/elf_scout.tres"),
	preload("res://resources/units/elves/duskblade.tres"),
	preload("res://resources/units/elves/thornguard.tres"),
	preload("res://resources/units/elves/spiritbark.tres"),
	preload("res://resources/units/elves/verdant_archer.tres"),
	preload("res://resources/units/elves/moonsong.tres"),
	preload("res://resources/units/elves/fernweave.tres"),
	preload("res://resources/units/elves/soul_tender.tres"),
	preload("res://resources/units/elves/thornborn.tres"),
	preload("res://resources/units/elves/dreamhunter.tres"),
	preload("res://resources/units/elves/pale_warden.tres"),
	preload("res://resources/units/elves/ashveil.tres"),
	preload("res://resources/units/elves/root_caller.tres"),
	preload("res://resources/units/elves/the_dreamer.tres"),
	preload("res://resources/units/elves/ancient_grove.tres"),
	preload("res://resources/units/covenant/covenant_initiate.tres"),
	preload("res://resources/units/aztecs/gilded_martyr.tres"),
	preload("res://resources/units/aztecs/blood_witness.tres"),
	preload("res://resources/units/aztecs/tribute_hunter.tres"),
	preload("res://resources/units/aztecs/anointed_vessel.tres"),
	preload("res://resources/units/aztecs/sun_idol.tres"),
	preload("res://resources/units/aztecs/blood_feast.tres"),
	preload("res://resources/units/aztecs/sacrifice_scout.tres"),
	preload("res://resources/units/aztecs/vault_keeper.tres"),
	preload("res://resources/units/aztecs/gold_effigy.tres"),
	preload("res://resources/units/aztecs/tithe_warden.tres"),
	preload("res://resources/units/aztecs/sun_seeker.tres"),
	preload("res://resources/units/aztecs/the_devourer.tres"),
	preload("res://resources/units/aztecs/blood_font.tres"),
	preload("res://resources/units/aztecs/golden_sovereign.tres"),
	preload("res://resources/units/aztecs/the_starved.tres"),
	preload("res://resources/units/aztecs/sun_herald.tres"),
	preload("res://resources/units/constructs/winder.tres"),
	preload("res://resources/units/constructs/capacitor.tres"),
	preload("res://resources/units/constructs/volt_striker.tres"),
	preload("res://resources/units/constructs/reigniter.tres"),
	preload("res://resources/units/constructs/coil_weaver.tres"),
	preload("res://resources/units/constructs/iron_sentinel.tres"),
	preload("res://resources/units/constructs/arc_coil.tres"),
	preload("res://resources/units/constructs/accumulator.tres"),
	preload("res://resources/units/constructs/discharge_engine.tres"),
	preload("res://resources/units/constructs/surge_conduit.tres"),
	preload("res://resources/units/constructs/charge_siphon.tres"),
	preload("res://resources/units/constructs/overload_core.tres"),
	preload("res://resources/units/constructs/meltdown.tres"),
	preload("res://resources/units/constructs/relay_node.tres"),
	preload("res://resources/units/constructs/grand_capacitor.tres"),
	preload("res://resources/units/constructs/recharge_protocol.tres"),
	preload("res://resources/units/constructs/fission_core.tres"),
	preload("res://resources/units/reapers/gravewarden.tres"),
	preload("res://resources/units/myconids/sporekeeper.tres"),
	preload("res://resources/units/satyrs/crimson_satyr.tres"),
	preload("res://resources/units/satyrs/gold_satyr.tres"),
	preload("res://resources/units/satyrs/silver_satyr.tres"),
	preload("res://resources/units/satyrs/green_satyr.tres"),
	preload("res://resources/units/satyrs/black_satyr.tres"),
	preload("res://resources/units/satyrs/crimson_revenant.tres"),
	preload("res://resources/units/satyrs/surge_herald.tres"),
	preload("res://resources/units/satyrs/moon_striker.tres"),
	preload("res://resources/units/satyrs/grove_caller.tres"),
	preload("res://resources/units/satyrs/plague_sovereign.tres"),
	preload("res://resources/units/satyrs/twin_pyre.tres"),
	preload("res://resources/units/satyrs/gilded_balance.tres"),
	preload("res://resources/units/satyrs/lunar_surge.tres"),
	preload("res://resources/units/satyrs/ancient_root.tres"),
	preload("res://resources/units/satyrs/pestilence.tres"),
	preload("res://resources/units/satyrs/dark_reveler.tres"),
	preload("res://resources/units/satyrs/auric_mirror.tres"),
	preload("res://resources/units/satyrs/eternal_grove.tres"),
	preload("res://resources/units/satyrs/blood_hunger.tres"),
	preload("res://resources/units/satyrs/pack_sovereign.tres"),
	preload("res://resources/units/satyrs/prismatic_reveler.tres"),
	preload("res://resources/units/satyrs/crimson_token.tres"),
	preload("res://resources/units/satyrs/gold_token.tres"),
	preload("res://resources/units/satyrs/silver_token.tres"),
	preload("res://resources/units/satyrs/green_token.tres"),
	preload("res://resources/units/satyrs/black_token.tres"),
]

const RUNECALLER_SPELL_POOL := [
	preload("res://resources/spells/embolden.tres"),
	preload("res://resources/spells/arcane_infusion.tres"),
	preload("res://resources/spells/arcane_snare.tres"),
	preload("res://resources/spells/mending_touch.tres"),
	preload("res://resources/spells/arcane_surge.tres"),
	preload("res://resources/spells/war_surge.tres"),
	preload("res://resources/spells/novice_bolt.tres"),
]

const WEAPON_TEMPLATES := {
	0: preload("res://resources/weapons/pistol.tres"),
	1: preload("res://resources/weapons/shotgun.tres"),
	2: preload("res://resources/weapons/sniper.tres"),
	3: preload("res://resources/weapons/machine_gun.tres"),
}

@onready var player_board: Board = $RootHBox/MainLayout/PlayerBoard
@onready var enemy_board: Board = $RootHBox/MainLayout/EnemyBoard
@onready var player_bench: Bench = $RootHBox/MainLayout/PlayerBench
@onready var combat_log: Control = $RootHBox/CombatLog
@onready var fight_button: Button = $RootHBox/MainLayout/CenterRow/FightButton
@onready var continue_button: Button = $RootHBox/MainLayout/CenterRow/ContinueButton
@onready var result_banner: Label = $RootHBox/MainLayout/CenterRow/ResultBanner
@onready var combat_manager: CombatManager = $CombatManager
@onready var discovery_screen: DiscoveryScreen = $DiscoveryScreen
@onready var sell_zone: Panel = $RootHBox/MainLayout/SellZone
@onready var sell_label: Label = $RootHBox/MainLayout/SellZone/SellLabel
@onready var toggle_log_button: Button = $RootHBox/MainLayout/TopBar/ToggleLogButton
@onready var gold_label: Label = $RootHBox/MainLayout/ResourceBar/GoldLabel
@onready var hp_label: Label = $RootHBox/MainLayout/ResourceBar/HPLabel
@onready var tier_label: Label = $RootHBox/MainLayout/ResourceBar/TierLabel
@onready var tier_upgrade_button: Button = $RootHBox/MainLayout/ResourceBar/TierUpgradeButton

const SPELL_SHOP_SCENE := preload("res://scripts/spell_shop.gd")

const ORDER_SAVE_PATH := "user://player_order.json"
const BENCH_SAVE_PATH := "user://bench_order.json"
const ROUND_SAVE_PATH := "user://round.json"
const SELL_COUNTER_SAVE_PATH := "user://sell_counter.json"
const RESOURCES_SAVE_PATH := "user://resources.json"
const FACTIONS_SAVE_PATH := "user://active_factions.json"

const ALL_PLAYABLE_FACTIONS: Array = [
	RaceType.Race.HUMAN, RaceType.Race.ELF, RaceType.Race.MAGE,
	RaceType.Race.GOBLIN, RaceType.Race.COVENANT, RaceType.Race.AZTEC,
	RaceType.Race.CONSTRUCT, RaceType.Race.REAPER, RaceType.Race.MYCONID,
	RaceType.Race.SATYR,
]

var _round: int = 0
var _sell_counter: int = 0
var _discovery_from_combat: bool = false
var _new_game_discovery: bool = false
var _board_template: Array = []
var _drag_card: UnitCard = null
var _drag_card_size: Vector2 = Vector2.ZERO
var _drag_origin_idx: int = -1
var _drag_origin_visual_idx: int = -1
var _drag_origin_container = null

# Gold & tier
var _gold: int = 0
var _gold_income: int = 2       # increases by 1 each out-of-combat phase; starts at 2 so first phase gives 3 gold
var _lifetime_gold: int = 0     # total gold ever earned (income + interest + tier costs) — drives enemy scaling
var _player_tier: int = 1

# Enemy shop data — scaled to _lifetime_gold, passed to combat_manager before each fight
var _enemy_goblin_shop_data: GoblinShopData = null
var _enemy_elf_shop_data: ElfShopData = null
var _enemy_covenant_shop_data: CovenantShopData = null
var _enemy_aztec_shop_data: AztecShopData = null
var _enemy_aztec_gold: int = 0
var _enemy_construct_shop_data: ConstructShopData = null
var _enemy_reaper_shop_data: ReaperShopData = null
var _enemy_myconid_shop_data: MyconidShopData = null
var _enemy_satyr_shop_data: SatyrShopData = null
var _player_hp: int = 100

# Support slot
var _support_slot_unlocked: bool = false
var _support_card: UnitCard = null
var _support_slot_panel: Panel = null
var _support_buy_button: Button = null
var _support_empty_label: Label = null
var _pending_support_card_dict: Dictionary = {}
var _drag_from_support: bool = false

# Goblin shop
var _goblin_shop_data: GoblinShopData = null
var _goblin_shop: GoblinShop = null
var _elf_shop_data: ElfShopData = null
var _elf_shop: ElfShop = null
var _covenant_shop_data: CovenantShopData = null
var _covenant_shop: CovenantShop = null

# Aztec shop
var _aztec_shop_data: AztecShopData = null
var _aztec_shop: AztecShop = null
var _aztec_tribute_used: bool = false
var _aztec_sacrifice_used: bool = false
var _aztec_free_tributes_available: int = 0
var _aztec_free_tributes_used: int = 0

# Construct shop
var _construct_shop_data: ConstructShopData = null
var _construct_shop: ConstructShop = null

# Reaper shop
var _reaper_shop_data: ReaperShopData = null
var _reaper_shop: ReaperShop = null

# Myconid shop
var _myconid_shop_data: MyconidShopData = null
var _myconid_shop: MyconidShop = null

# Satyr shop
var _satyr_shop_data: SatyrShopData = null
var _satyr_shop: SatyrShop = null

# Human shop
var _human_shop: HumanShop = null

# Active factions for this run (6 of 10, chosen randomly at run start)
var _active_factions: Array = []

# All Shops panel
var _all_shops_btn: Button = null
var _all_shops_panel: PanelContainer = null
var _all_shops_backdrop: Control = null

# Spells
var _asp: int = 1
var _hsp: int = 1
var _spell_hand: Array = []
var _spell_hand_nodes: Array = []
var _spell_shop: SpellShop
var _mage_shop: MageShop
var _wild_call_pending: bool = false
var _race_picker: Panel = null
var _spell_discovery_panel: Panel = null
var _last_spell_bought: SpellData = null
var _pending_weapon_discount: int = 0

# Unit targeting system
var _targeting_source: UnitCard = null
var _targeting_valid: Array = []
var _targeting_callback: Callable
var _targeting_line: Line2D = null


func _get_tier_upgrade_cost() -> int:
	var base: int
	match _player_tier:
		1: base = 10
		2: base = 20
		3: base = 30
		_: return 9999
	return roundi(base * GameData.tier_cost_mult)


func _process(_delta: float) -> void:
	if _targeting_source == null or not is_instance_valid(_targeting_source) \
			or _targeting_line == null:
		return
	var mouse := get_global_mouse_position()
	var src := _targeting_source.global_position + _targeting_source.size * 0.5
	_targeting_line.set_point_position(0, src)
	_targeting_line.set_point_position(1, mouse)


func _ready() -> void:
	print("=== combat_arena _ready ===")

	player_board.setup(true)
	enemy_board.setup(false)

	combat_manager.unit_card_scene = UnitCardScene
	combat_manager.setup(
		player_board, enemy_board,
		combat_log, result_banner,
		fight_button, continue_button)

	discovery_screen.unit_chosen.connect(_on_discovery_unit_chosen)
	combat_manager.combat_ended.connect(_on_combat_ended)
	combat_manager.relay_surge_requested.connect(_on_relay_surge_requested)

	_spell_shop = SpellShop.new()
	add_child(_spell_shop)
	_spell_shop.spell_bought.connect(_on_spell_bought)
	_spell_shop.refresh_requested.connect(_on_spell_shop_refresh_requested)

	_mage_shop = MageShop.new()
	add_child(_mage_shop)
	_mage_shop.trigger_bought.connect(_on_mage_trigger_bought)
	_mage_shop.mage_effect_upgraded.connect(_on_mage_effect_upgraded)

	_goblin_shop_data = GoblinShopData.new()
	_goblin_shop = GoblinShop.new()
	add_child(_goblin_shop)
	_goblin_shop.upgrade_bought.connect(_on_goblin_upgrade_bought)

	_elf_shop_data = ElfShopData.new()
	_elf_shop = ElfShop.new()
	add_child(_elf_shop)
	_elf_shop.upgrade_bought.connect(_on_elf_upgrade_bought)

	_covenant_shop_data = CovenantShopData.new()
	_covenant_shop = CovenantShop.new()
	add_child(_covenant_shop)
	_covenant_shop.upgrade_bought.connect(_on_covenant_upgrade_bought)

	_aztec_shop_data = AztecShopData.new()
	_aztec_shop = AztecShop.new()
	add_child(_aztec_shop)
	_aztec_shop.upgrade_bought.connect(_on_aztec_upgrade_bought)

	_construct_shop_data = ConstructShopData.new()
	_construct_shop = ConstructShop.new()
	add_child(_construct_shop)
	_construct_shop.upgrade_bought.connect(_on_construct_upgrade_bought)

	_reaper_shop_data = ReaperShopData.new()
	_reaper_shop = ReaperShop.new()
	add_child(_reaper_shop)
	_reaper_shop.upgrade_bought.connect(_on_reaper_upgrade_bought)

	_myconid_shop_data = MyconidShopData.new()
	_myconid_shop = MyconidShop.new()
	add_child(_myconid_shop)
	_myconid_shop.upgrade_bought.connect(_on_myconid_upgrade_bought)
	_myconid_shop.spore_distributed.connect(_on_myconid_spore_distributed)

	_satyr_shop_data = SatyrShopData.new()
	_satyr_shop = SatyrShop.new()
	add_child(_satyr_shop)
	_satyr_shop.upgrade_bought.connect(_on_satyr_upgrade_bought)

	_human_shop = HumanShop.new()
	_human_shop.weapon_templates = WEAPON_TEMPLATES
	add_child(_human_shop)
	_human_shop.weapon_bought.connect(_on_human_weapon_bought)
	_human_shop.weapon_upgraded.connect(_on_human_weapon_upgraded)
	_human_shop.weapon_sold.connect(_on_human_weapon_sold)
	_human_shop.weapon_swapped.connect(_on_human_weapon_swapped)

	var spell_shop_btn := Button.new()
	spell_shop_btn.text = "Spells"
	spell_shop_btn.pressed.connect(_on_spell_shop_pressed)
	$RootHBox/MainLayout/ResourceBar.add_child(spell_shop_btn)

	_all_shops_btn = Button.new()
	_all_shops_btn.text = "All Shops"
	_all_shops_btn.pressed.connect(_on_all_shops_pressed)
	$RootHBox/MainLayout/ResourceBar.add_child(_all_shops_btn)
	$RootHBox/MainLayout/ResourceBar.move_child(_all_shops_btn, 0)

	# Rename the Reset button to Quit to Menu
	var menu_btn: Button = $RootHBox/MainLayout/TopBar/ResetButton
	if menu_btn:
		menu_btn.text = "Quit to Menu"

	# Add Unit Manual button to the top bar
	var manual_btn := Button.new()
	manual_btn.text = "Unit Manual"
	$RootHBox/MainLayout/TopBar.add_child(manual_btn)
	$RootHBox/MainLayout/TopBar.move_child(manual_btn, 1)
	manual_btn.pressed.connect(func(): UnitManual.open(self, {
		"Human":    Callable(self, "_all_shops_open_humans"),
		"Goblin":   Callable(self, "_all_shops_open_goblins"),
		"Mage":     Callable(self, "_all_shops_open_mages"),
		"Elf":      Callable(self, "_all_shops_open_elves"),
		"Aztec":    Callable(self, "_all_shops_open_aztecs"),
		"Construct": Callable(self, "_all_shops_open_constructs"),
		"Reaper":   Callable(self, "_all_shops_open_reapers"),
		"Myconid":  Callable(self, "_all_shops_open_myconids"),
		"Satyr":    Callable(self, "_all_shops_open_satyrs"),
		"Covenant": Callable(self, "_all_shops_open_covenant"),
	}))

	# If a slot is active, write its saved data into the individual cache files
	# so the existing load functions pick it up transparently.
	if not GameData.gauntlet_mode and GameData.current_slot >= 0:
		var saved_slot = GameData.get_slot(GameData.current_slot)
		if saved_slot is Dictionary and not saved_slot.is_empty():
			_write_slot_to_files(saved_slot)
		else:
			_clear_cache_files()

	_load_round()
	_load_sell_counter()
	_load_resources()
	if not FileAccess.file_exists(RESOURCES_SAVE_PATH):
		_player_hp = GameData.starting_player_hp
	_initialize_active_factions()
	_build_all_shops_panel()
	_populate_player_board()
	_populate_bench_from_save()
	_populate_enemy_board()
	call_deferred("_setup_support_slot_panel")
	if GameData.gauntlet_mode:
		call_deferred("_enter_gauntlet_mode")

	result_banner.visible = false
	continue_button.visible = false
	_update_sell_label()
	_update_resource_bar()


# ── Population ────────────────────────────────────────────────────────────────

func _populate_player_board() -> void:
	if GameData.gauntlet_mode:
		return
	var saved := _load_player_order()
	if saved.is_empty():
		_new_game_discovery = true
		discovery_screen.activate(_player_tier)
	else:
		for entry in saved:
			var card: UnitCard = UnitCardScene.instantiate()
			player_board.add_unit(card)
			_apply_card_entry(card, entry)


func _populate_bench_from_save() -> void:
	if GameData.gauntlet_mode:
		return
	for entry in _load_bench():
		var card: UnitCard = UnitCardScene.instantiate()
		player_bench.add_unit(card)
		_apply_card_entry(card, entry)


func _populate_enemy_board() -> void:
	if GameData.gauntlet_mode:
		return
	enemy_board.clear_units()

	const ENEMY_FACTIONS: Array = [
		RaceType.Race.HUMAN, RaceType.Race.ELF, RaceType.Race.MAGE,
		RaceType.Race.GOBLIN, RaceType.Race.AZTEC, RaceType.Race.CONSTRUCT,
		RaceType.Race.REAPER, RaceType.Race.MYCONID, RaceType.Race.COVENANT,
		RaceType.Race.SATYR,
	]
	var available_enemy_factions := ENEMY_FACTIONS.filter(func(f): return _active_factions.has(f))
	if available_enemy_factions.is_empty():
		available_enemy_factions = ENEMY_FACTIONS
	var faction_theme: RaceType.Race = available_enemy_factions.pick_random()

	var eligible: Array = ALL_UNITS.filter(func(u): return u.tier <= _player_tier and _active_factions.has(u.race))
	if eligible.is_empty():
		eligible = ALL_UNITS.filter(func(u): return u.tier <= _player_tier)
	if eligible.is_empty():
		eligible = ALL_UNITS.duplicate()

	var faction_pool: Array = eligible.filter(func(u): return u.race == faction_theme)
	var filler_pool: Array  = eligible.filter(func(u): return u.race != faction_theme)
	if faction_pool.is_empty():
		faction_pool = eligible.duplicate()
	faction_pool.shuffle()
	filler_pool.shuffle()

	var count := clampi(player_board.units.size(), 1, 7)
	var income_scale := (1.0 + _lifetime_gold * 0.010) * 1.5

	var fi := 0
	var ri := 0
	for i in range(count):
		var use_faction := (randf() < 0.65 or ri >= filler_pool.size()) and fi < faction_pool.size()
		var unit_data: UnitData
		if use_faction:
			unit_data = faction_pool[fi % faction_pool.size()]
			fi += 1
		else:
			unit_data = filler_pool[ri % filler_pool.size()]
			ri += 1

		var card: UnitCard = UnitCardScene.instantiate()
		enemy_board.add_unit(card)
		card.initialize(unit_data)

		# Weapon level: match what a real player would have at this point in the run
		var wlvl := mini(8, _lifetime_gold / 12 + 1)
		if card.equipped_weapon != null:
			card.equipped_weapon.level = wlvl

		# Spell trigger level: scale fire counts to match a player who has been upgrading
		if card.equipped_spell != null:
			var slvl := maxi(1, _lifetime_gold / 20)
			for trig in card.equipped_spell.triggers.keys():
				card.equipped_spell.triggers[trig] = maxi(int(card.equipped_spell.triggers[trig]), slvl)

		# Mage effect level (Coin Sage yield, etc.)
		if card.data.race == RaceType.Race.MAGE:
			card.mage_effect_level = maxi(1, 1 + _lifetime_gold / 15)

		card.current_health = maxi(1, roundi(card.current_health * income_scale * GameData.enemy_hp_mult))
		if card.data.race == RaceType.Race.HUMAN and card.equipped_weapon != null:
			# Humans already got their weapon level above; skip ATK scaling so weapon stats do the work
			pass
		else:
			card.current_attack = maxi(1, roundi(card.current_attack * income_scale * GameData.enemy_atk_mult))

		_apply_enemy_faction_bonus(card, faction_theme)
		card.refresh_display()

	_build_enemy_shop_data()


func _apply_enemy_faction_bonus(card: UnitCard, faction: RaceType.Race) -> void:
	match faction:
		RaceType.Race.HUMAN:
			# Extra weapon level on top of the base wlvl already set; human ATK comes from weapons
			if card.equipped_weapon != null:
				card.equipped_weapon.level = mini(card.equipped_weapon.level + 1, 8)
			else:
				card.current_attack = maxi(1, roundi(card.current_attack * 1.2))
		RaceType.Race.ELF:
			card.current_health = maxi(1, roundi(card.current_health * 1.25))
		RaceType.Race.MAGE:
			# mage_effect_level set per-unit above; give bonus spell fire on top
			if card.equipped_spell != null:
				for trig in card.equipped_spell.triggers.keys():
					card.equipped_spell.triggers[trig] = int(card.equipped_spell.triggers[trig]) + 1
			card.current_attack = maxi(1, roundi(card.current_attack * 1.15))
		RaceType.Race.GOBLIN:
			card.current_attack = maxi(1, roundi(card.current_attack * 1.3))
		RaceType.Race.AZTEC:
			# Blessing via shop data at start-of-combat; give flat HP bonus here too
			card.current_health = maxi(1, roundi(card.current_health * 1.2))
		RaceType.Race.CONSTRUCT:
			# Charge cache applied by shop data at start-of-combat; seed some persistent charge
			card.construct_charge += 2 + _lifetime_gold / 20
		RaceType.Race.REAPER:
			card.current_health = maxi(1, roundi(card.current_health * 1.3))
		RaceType.Race.MYCONID:
			# Spores accumulate over rounds like a real player's myconids would
			card.myconid_spores += 2 + _lifetime_gold / 15
		RaceType.Race.COVENANT:
			card.current_health = maxi(1, roundi(card.current_health * 1.15))
			card.current_attack = maxi(1, roundi(card.current_attack * 1.15))
		RaceType.Race.SATYR:
			# Satyrs rely on their color abilities (applied via enemy_satyr_shop_data in combat);
			# give a moderate stat bonus so they feel threatening without their full upgrade tree
			card.current_health = maxi(1, roundi(card.current_health * 1.15))
			card.current_attack = maxi(1, roundi(card.current_attack * 1.15))


# Builds enemy shop data scaled to the current _lifetime_gold so enemy faction mechanics
# (charge cache, aztec blessing, spore buff level, goblin peon budget, covenant bonds, etc.)
# match what a player at this stage of the run would have invested.
func _build_enemy_shop_data() -> void:
	var upg := maxi(0, _lifetime_gold / 20)

	_enemy_goblin_shop_data = GoblinShopData.new()
	_enemy_goblin_shop_data.stat_budget    = 7 + upg
	_enemy_goblin_shop_data.reborn_chance  = mini(50, upg * 10)
	_enemy_goblin_shop_data.divine_shield_chance = mini(30, upg * 8)
	_enemy_goblin_shop_data.taunt_chance   = mini(40, upg * 8)
	_enemy_goblin_shop_data.windfury_chance = mini(20, upg * 5)

	_enemy_elf_shop_data = ElfShopData.new()
	_enemy_elf_shop_data.echo_stat_percent = mini(120, 50 + upg * 10)
	_enemy_elf_shop_data.max_echoes        = mini(7, 2 + upg / 2)

	_enemy_covenant_shop_data = CovenantShopData.new()
	_enemy_covenant_shop_data.bond_share_percent       = mini(90, 50 + upg * 10)
	_enemy_covenant_shop_data.berserk_multiplier_percent = mini(50, upg * 10)

	_enemy_aztec_shop_data = AztecShopData.new()
	_enemy_aztec_shop_data.blessing_rate = maxi(1, 1 + upg / 2)
	_enemy_aztec_gold = _gold_income * 2  # simulate gold a player would hold at this income level

	_enemy_construct_shop_data = ConstructShopData.new()
	_enemy_construct_shop_data.charge_cache    = (upg / 2) * 3
	_enemy_construct_shop_data.recoil_charge   = 1 + upg / 4
	_enemy_construct_shop_data.resonance_charge = upg / 4

	_enemy_reaper_shop_data = ReaperShopData.new()
	_enemy_reaper_shop_data.doom_damage      = 100 + upg * 25
	_enemy_reaper_shop_data.reaper_aura_bonus = upg / 2

	_enemy_myconid_shop_data = MyconidShopData.new()
	_enemy_myconid_shop_data.sporulation_rate = maxi(1, 1 + upg / 3)
	_enemy_myconid_shop_data.spore_buff_level = maxi(1, 1 + upg / 2)

	_enemy_satyr_shop_data = SatyrShopData.new()
	_enemy_satyr_shop_data.crimson_damage      = 5 + upg * 5
	_enemy_satyr_shop_data.gold_atk_bonus      = 1 + upg / 2
	_enemy_satyr_shop_data.silver_bonus_damage = 5 + upg * 5
	_enemy_satyr_shop_data.green_stat_bonus    = 1 + upg / 2
	_enemy_satyr_shop_data.black_debuff_percent = mini(60, 10 + upg * 10)
	_enemy_satyr_shop_data.prismatic_percent   = mini(60, 20 + upg * 5)


# ── Round flow ────────────────────────────────────────────────────────────────

func _on_continue_pressed() -> void:
	continue_button.visible = false
	_discovery_from_combat = true
	var interest := _gold / 10
	_gold_income += 1
	_gold += _gold_income
	if interest > 0:
		_gold += interest
		print("Interest: +%d gold (from %d saved)" % [interest, _gold - _gold_income - interest])
	_lifetime_gold += _gold_income + interest
	_spell_shop.new_round()
	_save_resources()
	_update_resource_bar()
	discovery_screen.activate(_player_tier)


func _on_reset_pressed() -> void:
	_return_to_menu()


func _on_toggle_log_pressed() -> void:
	combat_log.visible = not combat_log.visible
	toggle_log_button.text = "Show Log" if not combat_log.visible else "Hide Log"


func _on_tier_upgrade_pressed() -> void:
	if _player_tier >= 4:
		return
	var cost := _get_tier_upgrade_cost()
	if _gold < cost:
		return
	_gold -= cost
	_lifetime_gold += cost
	_player_tier += 1
	_save_resources()
	_update_resource_bar()


func _on_discovery_unit_chosen(unit_data: UnitData) -> void:
	if _new_game_discovery:
		var new_game_card: UnitCard = UnitCardScene.instantiate()
		player_board.add_unit(new_game_card)
		new_game_card.initialize(unit_data)
		_connect_player_card(new_game_card)
		_save_player_order()
		_new_game_discovery = false
		return

	var card: UnitCard = UnitCardScene.instantiate()
	if not player_bench.add_unit(card):
		card.queue_free()
	else:
		card.initialize(unit_data)
		_connect_player_card(card)

	_save_bench()

	if _discovery_from_combat:
		_round += 1
		_save_round()
		_rebuild_board_from_template()
		_reset_bench_units()
		_populate_enemy_board()
		player_board.is_locked = false
		fight_button.visible = true
		result_banner.visible = false
		_discovery_from_combat = false

	_check_for_triples()


func _rebuild_board_from_template() -> void:
	player_board.clear_units()
	for entry: Dictionary in _board_template:
		var card: UnitCard = UnitCardScene.instantiate()
		player_board.add_unit(card)
		card.initialize(entry["data"])
		card.current_attack = entry["atk"]
		card.current_health = entry["hp"]
		card.current_keywords = entry["kw"]
		card.is_radiant = entry["radiant"]
		card.equipped_weapon = entry["equipped_weapon"]
		card.backpack_weapon = entry["backpack_weapon"]
		card.equipped_spell = entry["equipped_spell"]
		card.construct_charge = int(entry.get("construct_charge", 0))
		card.myconid_spores = int(entry.get("myconid_spores", 0))
		if card.data != null and card.data.myconid_effect == MyconidEffect.Effect.SPOREGUARD \
				and card.myconid_spores >= 10:
			card.current_keywords |= KeywordFlags.Keyword.DIVINE_SHIELD
		_connect_player_card(card)
		card.refresh_display()
	_save_player_order()


func _reset_bench_units() -> void:
	for card: UnitCard in player_bench.units:
		if not is_instance_valid(card):
			continue
		if not card.is_radiant:
			card.current_health = card.data.base_health
			card.current_attack = card.data.base_attack
			card.current_keywords = card.data.keywords
		card.is_dead = false
		card.reborn_triggered = false
		card.scale = Vector2.ONE
		card.modulate.a = 1.0
		card.pivot_offset = Vector2.ZERO
		card.refresh_display()


# ── Triple mechanic ───────────────────────────────────────────────────────────

func _check_for_triples() -> void:
	var all_cards: Array = player_board.units.duplicate() + player_bench.units.duplicate()
	if _support_card != null and is_instance_valid(_support_card):
		all_cards.append(_support_card)

	var groups: Dictionary = {}
	for card: UnitCard in all_cards:
		if not is_instance_valid(card) or card.data == null:
			continue
		if card.is_radiant:
			continue
		var path := card.data.resource_path
		if not groups.has(path):
			groups[path] = []
		groups[path].append(card)

	for path in groups:
		if groups[path].size() >= 3:
			_apply_triple(groups[path].slice(0, 3))
			return


func _apply_triple(trio: Array) -> void:
	var unit_data: UnitData = trio[0].data
	var combined_attack: int = 0
	var combined_health: int = 0
	for card: UnitCard in trio:
		combined_attack += card.current_attack
		combined_health += card.current_health

	# Collect all weapons from the trio, pick top 2 by level
	var all_weapons: Array = []
	for card: UnitCard in trio:
		if card.equipped_weapon != null:
			all_weapons.append(card.equipped_weapon.duplicate())
		if card.backpack_weapon != null:
			all_weapons.append(card.backpack_weapon.duplicate())
	all_weapons.sort_custom(func(a, b): return a.level > b.level)

	var new_equipped: WeaponData = all_weapons[0] if all_weapons.size() >= 1 else null
	var new_backpack: WeaponData = all_weapons[1] if all_weapons.size() >= 2 else null

	# Preserve spell from first Mage in trio that has one
	var new_spell: SpellInstance = null
	for card: UnitCard in trio:
		if card.equipped_spell != null:
			new_spell = card.equipped_spell
			break

	# Gold from discarded weapons (rank 3+)
	for i in range(2, all_weapons.size()):
		_gold += all_weapons[i].get_sell_value()
	_save_resources()
	_update_resource_bar()

	# Tripled unit always lands on bench regardless of where source cards were
	var target_container = player_bench
	var target_idx: int = player_bench.units.size()

	var merge_center := Vector2.ZERO
	for card: UnitCard in trio:
		merge_center += card.global_position + card.size * 0.5
	merge_center /= 3.0

	var arena := get_tree().current_scene
	for card: UnitCard in trio:
		var gpos := card.global_position
		var sz := card.size
		if player_board.units.has(card):
			player_board.units.erase(card)
			player_board.slots_container.remove_child(card)
		elif player_bench.units.has(card):
			player_bench.units.erase(card)
			player_bench.slots_container.remove_child(card)
		elif card == _support_card:
			_support_card = null
			if _support_empty_label != null:
				_support_empty_label.visible = _support_slot_unlocked
		if card.get_parent() != arena:
			arena.add_child(card)
		card.size = sz
		card.global_position = gpos
		card.z_index = 15

	for card: UnitCard in trio:
		card.pivot_offset = card.size * 0.5
		var dest := merge_center - card.size * 0.5
		var tween := card.create_tween()
		tween.set_parallel(true)
		tween.tween_property(card, "global_position", dest, 0.38) \
			.set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_IN)
		tween.tween_property(card, "scale", Vector2(0.25, 0.25), 0.38) \
			.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
		tween.tween_property(card, "modulate:a", 0.0, 0.28) \
			.set_delay(0.1)

	await get_tree().create_timer(0.42).timeout

	for card: UnitCard in trio:
		if is_instance_valid(card):
			arena.remove_child(card)
			card.queue_free()

	target_idx = mini(target_idx, target_container.units.size())

	var tripled: UnitCard = UnitCardScene.instantiate()
	target_container.slots_container.add_child(tripled)
	target_container.slots_container.move_child(tripled, target_idx)
	target_container.units.insert(target_idx, tripled)
	tripled.attack_direction = player_board.attack_dir if target_container == player_board else Vector2.ZERO
	tripled.initialize(unit_data)
	tripled.current_attack = combined_attack
	tripled.current_health = combined_health
	tripled.is_radiant = true
	tripled.equipped_weapon = new_equipped
	tripled.backpack_weapon = new_backpack
	tripled.equipped_spell = new_spell
	tripled.refresh_display()

	await tripled.flash_triple_spawn()

	_save_player_order()
	_save_bench()
	_save_resources()

	_discovery_from_combat = false
	discovery_screen.activate(_player_tier)


# ── Surge ────────────────────────────────────────────────────────────────────

func _fire_surge(card: UnitCard) -> void:
	var count := _get_surge_count()
	# Targeting surges manage their own repeat via _targeting_repeat
	if card.data.race == RaceType.Race.HUMAN \
			and card.data.human_effect == HumanEffect.Effect.GUN_UPGRADE_SURGE:
		_resolve_gun_upgrade_surge(card, count)
		return
	for _i in range(count):
		if card.data.race == RaceType.Race.MAGE:
			match card.data.mage_effect:
				MageEffect.Effect.RUNECALLER:
					_resolve_runecaller_surge(card)
				MageEffect.Effect.SPELL_POWER_SURGE:
					_resolve_spell_power_surge()
				MageEffect.Effect.SURGE_TRIGGER_UP:
					_resolve_surge_trigger_up(card)
		elif card.data.race == RaceType.Race.HUMAN:
			match card.data.human_effect:
				HumanEffect.Effect.COST_REDUCTION_SURGE:
					_resolve_cost_reduction_surge(card)
				HumanEffect.Effect.WEAPON_LEVEL_SURGE:
					_resolve_weapon_level_surge(card)
		elif card.data.race == RaceType.Race.GOBLIN:
			match card.data.goblin_effect:
				GoblinEffect.Effect.STAT_BUDGET_SURGE:
					var gain := 4 if card.is_radiant else 2
					_goblin_shop_data.stat_budget += gain
					_save_resources()
					card.flash_surge_source()
					print("Rabble Riser Surge: Peon stat budget +%d → %d!" % [gain, _goblin_shop_data.stat_budget])
		elif card.data.race == RaceType.Race.ELF:
			match card.data.elf_effect:
				ElfEffect.Effect.SURGE_ECHO_STAT:
					var gain := 10 if card.is_radiant else 5
					_elf_shop_data.echo_stat_percent += gain
					_save_resources()
					card.flash_surge_source()
					print("Moonsong Surge: Echo stat +%d%% → %d%%!" % [gain, _elf_shop_data.echo_stat_percent])
				ElfEffect.Effect.SURGE_ECHO_UNIT:
					_resolve_root_caller_surge(card)
		elif card.data.race == RaceType.Race.COVENANT:
			match card.data.covenant_effect:
				CovenantEffect.Effect.OATH_BINDER:
					_resolve_oath_binder_surge(card)
					return
				CovenantEffect.Effect.RITE_SAGE:
					var sage_gain := 10 if card.is_radiant else 5
					_covenant_shop_data.berserk_multiplier_percent += sage_gain
					_save_resources()
					card.flash_surge_source()
					print("Rite Sage: Berserk +%d%% → %d%%!" % [sage_gain, _covenant_shop_data.berserk_multiplier_percent])
		elif card.data.race == RaceType.Race.AZTEC:
			match card.data.aztec_effect:
				AztecEffect.Effect.SACRIFICE_SCOUT:
					_start_sacrifice_targeting(true)
					card.flash_surge_source()
				AztecEffect.Effect.SUN_SEEKER:
					var has_other := false
					for c in player_board.units:
						if is_instance_valid(c) and c != card and c.data != null \
								and c.data.race == RaceType.Race.AZTEC:
							has_other = true
							break
					if not has_other:
						for c in player_bench.units:
							if is_instance_valid(c) and c.data != null \
									and c.data.race == RaceType.Race.AZTEC:
								has_other = true
								break
					if has_other:
						discovery_screen.activate_filtered(_player_tier, RaceType.Race.AZTEC)
					card.flash_surge_source()
		elif card.data.race == RaceType.Race.MYCONID:
			match card.data.myconid_effect:
				MyconidEffect.Effect.HYPHAE_SURGE:
					for unit: UnitCard in player_board.units:
						if is_instance_valid(unit) and unit.data != null \
								and unit.data.race == RaceType.Race.MYCONID \
								and unit.data.myconid_effect != MyconidEffect.Effect.PARASITE:
							_give_spore_to(unit, 1)
					_save_player_order()
					card.flash_surge_source()
					print("Hyphae Surge: all Myconids +1 spore!")
		elif card.data.race == RaceType.Race.REAPER:
			match card.data.reaper_effect:
				ReaperEffect.Effect.DREAD_SEER:
					for unit: UnitCard in player_board.units:
						if is_instance_valid(unit) and unit.data != null:
							unit.current_health += 5
							unit.refresh_display()
					_save_player_order()
					card.flash_surge_source()
					print("Dread Seer Surge: board +5 max HP!")
				ReaperEffect.Effect.SHADE_STALKER:
					card.current_keywords |= KeywordFlags.Keyword.WINDFURY
					card.refresh_display()
					_save_player_order()
					card.flash_surge_source()
					print("Shade Stalker Surge: gained Windfury!")
		elif card.data.race == RaceType.Race.CONSTRUCT:
			match card.data.construct_effect:
				ConstructEffect.Effect.COIL_WEAVER:
					var gain := 2 if card.is_radiant else 1
					_construct_shop_data.charge_cache += gain
					_save_resources()
					card.flash_surge_source()
					print("Coil Weaver Battlecry: all Constructs +%d SOC Charge (cache now %d)!" % [gain, _construct_shop_data.charge_cache])
				ConstructEffect.Effect.SURGE_CONDUIT:
					var sc_gain := 6 if card.is_radiant else 3
					for unit: UnitCard in player_board.units:
						if is_instance_valid(unit) and unit.data != null \
								and unit.data.race == RaceType.Race.CONSTRUCT:
							unit.construct_persistent_charge += sc_gain
							if combat_manager.is_running:
								combat_manager._add_construct_charge(unit, sc_gain, true)
							else:
								unit.construct_charge += sc_gain
							unit.refresh_display()
					_save_player_order()
					card.flash_surge_source()
					print("Surge Conduit Battlecry: all Constructs +%d persistent Charge!" % sc_gain)


func _on_relay_surge_requested(candidates: Array) -> void:
	var surge_candidates := candidates.filter(func(c): return _has_surge(c as UnitCard))
	if surge_candidates.is_empty():
		return
	var target: UnitCard = surge_candidates[randi() % surge_candidates.size()]
	print("Relay Node: triggering %s's Battlecry!" % target.data.display_name)
	_fire_surge(target)


func _has_surge(card: UnitCard) -> bool:
	if card == null or card.data == null:
		return false
	match card.data.race:
		RaceType.Race.MAGE:
			return card.data.mage_effect in [
				MageEffect.Effect.RUNECALLER, MageEffect.Effect.SPELL_POWER_SURGE,
				MageEffect.Effect.SURGE_TRIGGER_UP]
		RaceType.Race.HUMAN:
			return card.data.human_effect in [
				HumanEffect.Effect.GUN_UPGRADE_SURGE, HumanEffect.Effect.COST_REDUCTION_SURGE,
				HumanEffect.Effect.WEAPON_LEVEL_SURGE]
		RaceType.Race.GOBLIN:
			return card.data.goblin_effect == GoblinEffect.Effect.STAT_BUDGET_SURGE
		RaceType.Race.ELF:
			return card.data.elf_effect in [ElfEffect.Effect.SURGE_ECHO_STAT, ElfEffect.Effect.SURGE_ECHO_UNIT]
		RaceType.Race.COVENANT:
			return card.data.covenant_effect in [CovenantEffect.Effect.OATH_BINDER, CovenantEffect.Effect.RITE_SAGE]
		RaceType.Race.AZTEC:
			return card.data.aztec_effect in [AztecEffect.Effect.SACRIFICE_SCOUT, AztecEffect.Effect.SUN_SEEKER]
		RaceType.Race.MYCONID:
			return card.data.myconid_effect == MyconidEffect.Effect.HYPHAE_SURGE
		RaceType.Race.REAPER:
			return card.data.reaper_effect in [ReaperEffect.Effect.DREAD_SEER, ReaperEffect.Effect.SHADE_STALKER]
		RaceType.Race.CONSTRUCT:
			return card.data.construct_effect in [
				ConstructEffect.Effect.COIL_WEAVER, ConstructEffect.Effect.SURGE_CONDUIT]
	return false


func _get_surge_count() -> int:
	for card in player_board.units:
		if not is_instance_valid(card) or card.data == null:
			continue
		if card.data.generic_effect == GenericEffect.Effect.SURGE_MASTER:
			return 3 if card.is_radiant else 2
	if _support_card != null and is_instance_valid(_support_card) \
			and _support_card.data != null \
			and _support_card.data.generic_effect == GenericEffect.Effect.SURGE_MASTER:
		return 3 if _support_card.is_radiant else 2
	return 1


func _start_targeting(source: UnitCard, valid: Array, callback: Callable) -> void:
	_targeting_source = source
	_targeting_valid = valid
	_targeting_callback = callback
	for card in valid:
		if is_instance_valid(card):
			card.show_targeted(true)
	if source == null:
		return
	if _targeting_line == null:
		_targeting_line = Line2D.new()
		_targeting_line.width = 2.0
		_targeting_line.default_color = Color(0.4, 0.85, 1.0, 0.85)
		_targeting_line.z_index = 50
		add_child(_targeting_line)
	var src := source.global_position + source.size * 0.5
	_targeting_line.clear_points()
	_targeting_line.add_point(src)
	_targeting_line.add_point(src)
	_targeting_line.visible = true


func _cancel_targeting() -> void:
	for card in _targeting_valid:
		if is_instance_valid(card):
			card.show_targeted(false)
	_targeting_source = null
	_targeting_valid = []
	_targeting_callback = Callable()
	if _targeting_line != null:
		_targeting_line.visible = false


func _on_targeting_pick(target: UnitCard) -> void:
	var cb := _targeting_callback
	_cancel_targeting()
	cb.call(target)


func _get_card_at_pos(pos: Vector2) -> UnitCard:
	var card := player_board.get_unit_at_screen_pos(pos)
	if card != null:
		return card
	return player_bench.get_unit_at_screen_pos(pos)


func _resolve_runecaller_surge(card: UnitCard) -> void:
	card.flash_surge_buff()
	if card.equipped_spell == null:
		_open_spell_discovery(card)
	else:
		_apply_instant_spell_effect(card.equipped_spell.spell_data)


func _resolve_spell_power_surge() -> void:
	_asp += 1
	_hsp += 1
	_save_resources()
	_update_resource_bar()
	for unit in player_board.units:
		if is_instance_valid(unit) and not unit.is_dead \
				and unit.data.race == RaceType.Race.MAGE:
			unit.flash_surge_buff()
	print("Arcane Conduit Surge: ASP now %d, HSP now %d!" % [_asp, _hsp])


func _resolve_surge_trigger_up(source: UnitCard) -> void:
	# Collect allied mages with a spell that has at least one trigger
	var candidates: Array = []
	for unit in player_board.units:
		if is_instance_valid(unit) and not unit.is_dead \
				and unit.data.race == RaceType.Race.MAGE \
				and unit.equipped_spell != null \
				and unit.equipped_spell.has_any_trigger():
			candidates.append(unit)
	if _support_card != null and is_instance_valid(_support_card) and not _support_card.is_dead \
			and _support_card.data.race == RaceType.Race.MAGE \
			and _support_card.equipped_spell != null \
			and _support_card.equipped_spell.has_any_trigger():
		candidates.append(_support_card)
	if candidates.is_empty():
		return
	var target: UnitCard = candidates[randi() % candidates.size()]
	var inst: SpellInstance = target.equipped_spell
	# Collect triggers that have at least 1 level
	var active_triggers: Array = []
	for t in [SpellTrigger.Trigger.ON_ATTACK, SpellTrigger.Trigger.WHEN_ATTACKED,
			SpellTrigger.Trigger.DEATH_KNELL, SpellTrigger.Trigger.START_OF_COMBAT]:
		if inst.get_fire_count(t) > 0:
			active_triggers.append(t)
	if active_triggers.is_empty():
		return
	var chosen: int = active_triggers[randi() % active_triggers.size()]
	var levels := 2 if source.is_radiant else 1
	for _i in range(levels):
		inst.upgrade_trigger(chosen)
	target.refresh_display()
	source.flash_surge_source()
	target.flash_surge_buff()
	print("Spellwright Surge: %s %s +%d level!" % [
		target.data.display_name, SpellTrigger.display_name(chosen), levels])




func _resolve_gun_upgrade_surge(source: UnitCard, count: int = 1) -> void:
	var candidates: Array = player_board.units.filter(func(u):
		return is_instance_valid(u) and not u.is_dead \
				and u.data.race == RaceType.Race.HUMAN \
				and u.equipped_weapon != null)
	if _support_card != null and is_instance_valid(_support_card) and not _support_card.is_dead \
			and _support_card.data.race == RaceType.Race.HUMAN \
			and _support_card.equipped_weapon != null:
		candidates.append(_support_card)
	if candidates.is_empty():
		return
	var levels := (2 if source.is_radiant else 1) * count
	_start_targeting(source, candidates, func(target: UnitCard) -> void:
		target.equipped_weapon.level += levels
		target.refresh_display()
		source.flash_surge_source()
		target.flash_surge_buff()
		print("Quartermaster: %s weapon +%d level!" % [target.data.display_name, levels])
	)


func _resolve_oath_binder_surge(source: UnitCard) -> void:
	var candidates := player_board.units.filter(
		func(u): return is_instance_valid(u) and u.data != null and not u.is_dead and u != source)
	if candidates.is_empty():
		return
	_start_targeting(source, candidates, func(target: UnitCard) -> void:
		combat_manager._apply_covenant_bond(source, target)
		source.flash_surge_source()
		target.flash_surge_buff()
		print("Oath Binder: bonded with %s!" % target.data.display_name))


func _resolve_root_caller_surge(source: UnitCard) -> void:
	var buff := 10 if source.is_radiant else 5
	var candidates := player_board.units.filter(
		func(u): return is_instance_valid(u) and u.data != null and not u.is_dead)
	if candidates.is_empty():
		return
	_start_targeting(source, candidates, func(target: UnitCard) -> void:
		target.current_keywords |= KeywordFlags.Keyword.ECHO
		target.current_attack += buff
		target.current_health += buff
		target.refresh_display()
		target.flash_surge_buff()
		source.flash_surge_source()
		_save_player_order()
		print("Root Caller Surge: %s gains Echo +%d/+%d!" % [target.data.display_name, buff, buff]))


func _resolve_weapon_level_surge(source: UnitCard) -> void:
	if source.equipped_weapon == null:
		return
	var levels := 3 if source.is_radiant else 2
	source.equipped_weapon.level += levels
	source.refresh_display()
	source.flash_surge_source()
	print("%s Surge: weapon +%d levels → L%d!" % [source.data.display_name, levels, source.equipped_weapon.level])


func _resolve_cost_reduction_surge(source: UnitCard) -> void:
	var amount := 4 if source.is_radiant else 2
	_pending_weapon_discount += amount
	source.flash_surge_source()
	print("Grunt Surge: next weapon purchase %dg cheaper!" % amount)


func _open_spell_discovery(card: UnitCard) -> void:
	if _spell_discovery_panel != null:
		_spell_discovery_panel.queue_free()

	var pool: Array = RUNECALLER_SPELL_POOL.duplicate()
	pool.shuffle()
	var choices: Array = pool.slice(0, 3)

	_spell_discovery_panel = Panel.new()
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.08, 0.06, 0.16, 0.96)
	style.set_corner_radius_all(8)
	style.set_border_width_all(1)
	style.border_color = Color(0.55, 0.40, 0.80, 1.0)
	_spell_discovery_panel.add_theme_stylebox_override("panel", style)
	_spell_discovery_panel.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(_spell_discovery_panel)
	_spell_discovery_panel.set_anchors_preset(Control.PRESET_CENTER)
	_spell_discovery_panel.position = Vector2(200, 100)

	var vbox := VBoxContainer.new()
	vbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	vbox.add_theme_constant_override("separation", 8)
	_spell_discovery_panel.add_child(vbox)

	var lbl := Label.new()
	lbl.text = "Runecaller — Discover a spell:"
	lbl.add_theme_font_size_override("font_size", 13)
	vbox.add_child(lbl)

	for spell: SpellData in choices:
		var btn := Button.new()
		btn.text = "%s\n%s" % [spell.display_name, spell.description]
		btn.custom_minimum_size = Vector2(320, 0)
		btn.pressed.connect(_on_spell_discovery_chosen.bind(card, spell))
		vbox.add_child(btn)


func _on_spell_discovery_chosen(card: UnitCard, spell: SpellData) -> void:
	if _spell_discovery_panel != null:
		_spell_discovery_panel.queue_free()
		_spell_discovery_panel = null
	card.equipped_spell = SpellInstance.new(spell)
	card.refresh_display()
	_last_spell_bought = spell
	_apply_instant_spell_effect(spell)
	print("Runecaller discovered and cast: %s" % spell.display_name)


# ── Spell shop ───────────────────────────────────────────────────────────────

func _on_spell_shop_pressed() -> void:
	_spell_shop.open(_gold, _player_tier)


func _connect_player_card(card: UnitCard) -> void:
	if not card.shop_pressed.is_connected(_on_card_shop_pressed):
		card.shop_pressed.connect(_on_card_shop_pressed)


func _on_card_shop_pressed(card: UnitCard) -> void:
	if player_board.is_locked:
		return
	if card.data.race == RaceType.Race.HUMAN:
		_open_weapon_menu(card)
	elif card.data.race == RaceType.Race.MAGE:
		_open_mage_shop(card)
	elif card.data.race == RaceType.Race.ELF:
		_open_elf_shop()
	elif card.data.race == RaceType.Race.GOBLIN:
		_open_goblin_shop()
	elif card.data.race == RaceType.Race.COVENANT:
		_open_covenant_shop()
	elif card.data.race == RaceType.Race.AZTEC:
		_open_aztec_shop()
	elif card.data.race == RaceType.Race.CONSTRUCT:
		_open_construct_shop()
	elif card.data.race == RaceType.Race.REAPER:
		_open_reaper_shop()
	elif card.data.race == RaceType.Race.MYCONID:
		_open_myconid_shop()
	elif card.data.race == RaceType.Race.SATYR:
		_open_satyr_shop()


func _open_mage_shop(card: UnitCard) -> void:
	var mage_cards: Array = player_board.units.filter(
		func(c: UnitCard): return c.data.race == RaceType.Race.MAGE)
	_mage_shop.open(mage_cards, card, _gold)


func _close_mage_shop() -> void:
	_mage_shop.close()


func _open_goblin_shop() -> void:
	_goblin_shop.open(_goblin_shop_data, _gold)


func _open_elf_shop() -> void:
	_elf_shop.open(_elf_shop_data, _gold)


func _open_covenant_shop() -> void:
	_covenant_shop.open(_covenant_shop_data, _gold)


func _open_aztec_shop() -> void:
	_aztec_shop.open(_aztec_shop_data, _gold, _player_tier, _player_hp, _aztec_tribute_used, _aztec_sacrifice_used)


func _open_construct_shop() -> void:
	_construct_shop.open(_construct_shop_data, _gold)


func _open_reaper_shop() -> void:
	_reaper_shop.open(_reaper_shop_data, _gold)


func _get_myconid_board_units() -> Array:
	var units: Array = []
	for card: UnitCard in player_board.units:
		if is_instance_valid(card) and card.data != null \
				and card.data.race == RaceType.Race.MYCONID \
				and card.data.myconid_effect != MyconidEffect.Effect.PARASITE:
			units.append(card)
	for card: UnitCard in player_bench.units:
		if is_instance_valid(card) and card.data != null \
				and card.data.race == RaceType.Race.MYCONID \
				and card.data.myconid_effect != MyconidEffect.Effect.PARASITE:
			units.append(card)
	return units


func _open_myconid_shop() -> void:
	_myconid_shop.open(_myconid_shop_data, _gold, _get_myconid_board_units())


func _open_satyr_shop() -> void:
	_satyr_shop.open(_satyr_shop_data, _gold)


# ── All Shops panel ───────────────────────────────────────────────────────────

func _build_all_shops_panel() -> void:
	_all_shops_panel = PanelContainer.new()
	var ps := StyleBoxFlat.new()
	ps.bg_color = Color(0.11, 0.11, 0.14, 0.97)
	ps.set_corner_radius_all(8)
	ps.set_border_width_all(1)
	ps.border_color = Color(0.50, 0.50, 0.60, 1.0)
	_all_shops_panel.add_theme_stylebox_override("panel", ps)
	_all_shops_panel.z_index = 95
	_all_shops_panel.visible = false
	add_child(_all_shops_panel)

	var margin := MarginContainer.new()
	for side in ["margin_left", "margin_right", "margin_top", "margin_bottom"]:
		margin.add_theme_constant_override(side, 8)
	_all_shops_panel.add_child(margin)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 3)
	margin.add_child(vbox)

	var header := Label.new()
	header.text = "Open Shop"
	header.add_theme_font_size_override("font_size", 13)
	header.add_theme_color_override("font_color", Color(0.80, 0.80, 0.90))
	header.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(header)
	vbox.add_child(HSeparator.new())

	# -1 faction = always available; otherwise only shown when faction is active this run
	var entries: Array = [
		["Spells", Color(0.90, 0.75, 0.30), "_all_shops_open_spells", -1],
		["Armory  (Humans)", Color(0.85, 0.60, 0.40), "_all_shops_open_humans", RaceType.Race.HUMAN],
		["Mage Shop", Color(0.60, 0.70, 1.00), "_all_shops_open_mages", RaceType.Race.MAGE],
		["Workshop  (Goblins)", Color(0.55, 0.85, 0.40), "_all_shops_open_goblins", RaceType.Race.GOBLIN],
		["Elf Shop", Color(0.60, 0.95, 0.70), "_all_shops_open_elves", RaceType.Race.ELF],
		["Covenant Shop", Color(0.90, 0.50, 0.50), "_all_shops_open_covenant", RaceType.Race.COVENANT],
		["The Temple  (Aztecs)", Color(1.00, 0.80, 0.15), "_all_shops_open_aztecs", RaceType.Race.AZTEC],
		["The Coilworks  (Constructs)", Color(0.65, 0.85, 1.00), "_all_shops_open_constructs", RaceType.Race.CONSTRUCT],
		["The Rift  (Reapers)", Color(0.80, 0.50, 1.00), "_all_shops_open_reapers", RaceType.Race.REAPER],
		["The Grove  (Myconids)", Color(0.45, 0.90, 0.50), "_all_shops_open_myconids", RaceType.Race.MYCONID],
		["The Sacred Grove  (Satyrs)", Color(1.00, 0.78, 0.32), "_all_shops_open_satyrs", RaceType.Race.SATYR],
	]

	for entry in entries:
		var btn := Button.new()
		btn.text = entry[0]
		btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
		btn.custom_minimum_size = Vector2(230, 42)
		btn.add_theme_color_override("font_color", entry[1])
		var method: String = entry[2]
		btn.pressed.connect(Callable(self, method))
		btn.set_meta("faction", entry[3])
		var fid: int = entry[3]
		btn.visible = fid == -1 or _active_factions.has(fid)
		vbox.add_child(btn)

	_all_shops_panel.custom_minimum_size = Vector2(246, 0)


func _close_all_shops_panel() -> void:
	_all_shops_panel.visible = false
	if _all_shops_backdrop != null:
		_all_shops_backdrop.queue_free()
		_all_shops_backdrop = null


func _on_all_shops_pressed() -> void:
	if _all_shops_panel == null:
		return
	if _all_shops_panel.visible:
		_close_all_shops_panel()
		return
	_refresh_all_shops_panel()
	var btn_rect := Rect2(_all_shops_btn.global_position, _all_shops_btn.size)
	_all_shops_panel.global_position = btn_rect.position + Vector2(0, btn_rect.size.y + 4)
	_all_shops_backdrop = Control.new()
	_all_shops_backdrop.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_all_shops_backdrop.z_index = 94
	_all_shops_backdrop.mouse_filter = Control.MOUSE_FILTER_STOP
	_all_shops_backdrop.gui_input.connect(func(ev: InputEvent):
		if ev is InputEventMouseButton and ev.button_index == MOUSE_BUTTON_LEFT and ev.pressed:
			_close_all_shops_panel())
	add_child(_all_shops_backdrop)
	_all_shops_panel.move_to_front()
	_all_shops_panel.visible = true


func _refresh_all_shops_panel() -> void:
	if _all_shops_panel == null:
		return
	var vbox: VBoxContainer = _all_shops_panel.get_child(0).get_child(0)
	var all_races := player_board.units.map(func(c: UnitCard): return c.data.race if is_instance_valid(c) and c.data != null else -1)
	for child in vbox.get_children():
		if not (child is Button) or not child.has_meta("faction"):
			continue
		var fid: int = child.get_meta("faction")
		if fid == RaceType.Race.MAGE:
			child.disabled = not all_races.has(RaceType.Race.MAGE)
		else:
			child.disabled = false


func _all_shops_open_spells() -> void:
	_close_all_shops_panel()
	_on_spell_shop_pressed()


func _all_shops_open_humans() -> void:
	_close_all_shops_panel()
	var cards := player_board.units.filter(func(c: UnitCard): return is_instance_valid(c) and c.data != null and c.data.race == RaceType.Race.HUMAN)
	_open_weapon_menu(cards[0] if not cards.is_empty() else null)


func _all_shops_open_mages() -> void:
	_close_all_shops_panel()
	var cards := player_board.units.filter(func(c: UnitCard): return is_instance_valid(c) and c.data != null and c.data.race == RaceType.Race.MAGE)
	if not cards.is_empty():
		_open_mage_shop(cards[0])


func _all_shops_open_goblins() -> void:
	_close_all_shops_panel()
	_open_goblin_shop()


func _all_shops_open_elves() -> void:
	_close_all_shops_panel()
	_open_elf_shop()


func _all_shops_open_covenant() -> void:
	_close_all_shops_panel()
	_open_covenant_shop()


func _all_shops_open_aztecs() -> void:
	_close_all_shops_panel()
	_open_aztec_shop()


func _all_shops_open_constructs() -> void:
	_close_all_shops_panel()
	_open_construct_shop()


func _all_shops_open_reapers() -> void:
	_close_all_shops_panel()
	_open_reaper_shop()


func _all_shops_open_myconids() -> void:
	_close_all_shops_panel()
	_open_myconid_shop()


func _all_shops_open_satyrs() -> void:
	_close_all_shops_panel()
	_open_satyr_shop()


func _on_goblin_upgrade_bought(key: String) -> void:
	var cost: int = GoblinShop.UPGRADE_COSTS.get(key, 0) + GameData.shop_cost_bonus
	if _gold < cost:
		return
	_gold -= cost
	match key:
		"budget":
			_goblin_shop_data.stat_budget += 1
		"reborn":
			_goblin_shop_data.reborn_chance = mini(_goblin_shop_data.reborn_chance + 10, 50)
		"divine_shield":
			_goblin_shop_data.divine_shield_chance = mini(_goblin_shop_data.divine_shield_chance + 10, 50)
		"poisonous":
			_goblin_shop_data.poisonous_chance = mini(_goblin_shop_data.poisonous_chance + 10, 50)
		"taunt":
			_goblin_shop_data.taunt_chance = mini(_goblin_shop_data.taunt_chance + 10, 50)
		"windfury":
			_goblin_shop_data.windfury_chance = mini(_goblin_shop_data.windfury_chance + 10, 50)
	_save_resources()
	_update_resource_bar()
	_goblin_shop.refresh_gold(_gold)


func _on_elf_upgrade_bought(key: String) -> void:
	match key:
		"echo_stat":
			var cost: int = _elf_shop_data.echo_stat_cost()
			if _gold < cost:
				return
			_gold -= cost
			_elf_shop_data.echo_stat_percent += 10
			_elf_shop_data.echo_stat_purchases += 1
		"max_echoes":
			if _elf_shop_data.max_echoes >= 7:
				return
			var cost: int = _elf_shop_data.max_echoes_cost()
			if _gold < cost:
				return
			_gold -= cost
			_elf_shop_data.max_echoes += 1
			_elf_shop_data.max_echoes_purchases += 1
	_save_resources()
	_update_resource_bar()
	_elf_shop.refresh_gold(_gold)


func _on_covenant_upgrade_bought(key: String) -> void:
	match key:
		"bond_share":
			var cost: int = _covenant_shop_data.bond_share_cost()
			if _gold < cost:
				return
			_gold -= cost
			_covenant_shop_data.bond_share_percent += 10
			_covenant_shop_data.bond_share_purchases += 1
		"berserk":
			var cost: int = _covenant_shop_data.berserk_cost()
			if _gold < cost:
				return
			_gold -= cost
			_covenant_shop_data.berserk_multiplier_percent += 10
			_covenant_shop_data.berserk_purchases += 1
	_save_resources()
	_update_resource_bar()
	_covenant_shop.refresh_gold(_gold)


func _on_aztec_upgrade_bought(key: String) -> void:
	match key:
		"blessing":
			var cost := _aztec_shop_data.blessing_cost()
			if _gold < cost:
				return
			_gold -= cost
			_aztec_shop_data.blessing_rate += 1
			_aztec_shop_data.blessing_purchases += 1
		"tribute_rate":
			var cost := _aztec_shop_data.tribute_cost()
			if _gold < cost:
				return
			_gold -= cost
			_aztec_shop_data.tribute_rate += 1
			_aztec_shop_data.tribute_purchases += 1
		"sacrifice_rate":
			var cost := _aztec_shop_data.sacrifice_cost()
			if _gold < cost:
				return
			_gold -= cost
			_aztec_shop_data.sacrifice_rate += 1
			_aztec_shop_data.sacrifice_purchases += 1
		"tribute":
			# Use a free Blood Font charge if available, otherwise consume the round flag
			if _aztec_free_tributes_used < _aztec_free_tributes_available:
				_aztec_free_tributes_used += 1
				_do_blood_tribute(true)
			else:
				_do_blood_tribute(false)
			return
		"sacrifice":
			_start_sacrifice_targeting(false)
			return
	_save_resources()
	_update_resource_bar()
	_aztec_shop.refresh_gold(_gold, _player_hp, _aztec_tribute_used, _aztec_sacrifice_used)


func _on_construct_upgrade_bought(key: String) -> void:
	match key:
		"cache":
			var cost := _construct_shop_data.cache_cost()
			if _gold < cost:
				return
			_gold -= cost
			_construct_shop_data.charge_cache += 3
			_construct_shop_data.cache_purchases += 1
		"recoil":
			var cost := _construct_shop_data.recoil_cost()
			if _gold < cost:
				return
			_gold -= cost
			_construct_shop_data.recoil_charge += 1
			_construct_shop_data.recoil_purchases += 1
		"resonance":
			var cost := _construct_shop_data.resonance_cost()
			if _gold < cost:
				return
			_gold -= cost
			_construct_shop_data.resonance_charge += 1
			_construct_shop_data.resonance_purchases += 1
	_save_resources()
	_update_resource_bar()
	_construct_shop.refresh_gold(_gold)


func _on_reaper_upgrade_bought(key: String) -> void:
	match key:
		"doom_damage":
			var cost := _reaper_shop_data.damage_cost()
			if _gold < cost:
				return
			_gold -= cost
			_reaper_shop_data.doom_damage += 25
			_reaper_shop_data.damage_purchases += 1
		"reaper_aura":
			var cost := _reaper_shop_data.aura_cost()
			if _gold < cost:
				return
			_gold -= cost
			_reaper_shop_data.reaper_aura_bonus += 1
			_reaper_shop_data.aura_purchases += 1
	_save_resources()
	_update_resource_bar()
	_reaper_shop.refresh_gold(_gold)


func _on_myconid_upgrade_bought(key: String) -> void:
	match key:
		"sporulation":
			var cost := _myconid_shop_data.sporulation_cost()
			if _gold < cost:
				return
			_gold -= cost
			_myconid_shop_data.sporulation_rate += 1
			_myconid_shop_data.sporulation_purchases += 1
		"spore_buff":
			var cost := _myconid_shop_data.spore_buff_cost()
			if _gold < cost:
				return
			_gold -= cost
			_myconid_shop_data.spore_buff_level += 1
			_myconid_shop_data.spore_buff_purchases += 1
		"buy_spores":
			if _gold < 3:
				return
			_gold -= 3
			for card: UnitCard in player_board.units:
				if is_instance_valid(card) and card.data != null \
						and card.data.race == RaceType.Race.MYCONID \
						and card.data.myconid_effect != MyconidEffect.Effect.PARASITE:
					_give_spore_to(card, 1)
	_save_resources()
	_update_resource_bar()
	_myconid_shop.refresh_gold(_gold, _get_myconid_board_units())


func _on_satyr_upgrade_bought(key: String) -> void:
	match key:
		"crimson":
			var cost := _satyr_shop_data.crimson_cost()
			if _gold < cost:
				return
			_gold -= cost
			_satyr_shop_data.crimson_damage += 5
			_satyr_shop_data.crimson_purchases += 1
		"gold":
			var cost := _satyr_shop_data.gold_cost()
			if _gold < cost:
				return
			_gold -= cost
			_satyr_shop_data.gold_atk_bonus += 1
			_satyr_shop_data.gold_purchases += 1
		"silver":
			var cost := _satyr_shop_data.silver_cost()
			if _gold < cost:
				return
			_gold -= cost
			_satyr_shop_data.silver_bonus_damage += 5
			_satyr_shop_data.silver_purchases += 1
		"green":
			var cost := _satyr_shop_data.green_cost()
			if _gold < cost:
				return
			_gold -= cost
			_satyr_shop_data.green_stat_bonus += 1
			_satyr_shop_data.green_purchases += 1
		"black":
			var cost := _satyr_shop_data.black_cost()
			if _gold < cost:
				return
			_gold -= cost
			_satyr_shop_data.black_debuff_percent += 10
			_satyr_shop_data.black_purchases += 1
		"prismatic":
			var cost := _satyr_shop_data.prismatic_cost()
			if _gold < cost:
				return
			_gold -= cost
			_satyr_shop_data.prismatic_percent += 5
			_satyr_shop_data.prismatic_purchases += 1
	_save_resources()
	_update_resource_bar()
	_satyr_shop.refresh_gold(_gold)


func _give_spore_to(card: UnitCard, amount: int) -> void:
	var actual := amount
	if is_instance_valid(card) and card.data != null \
			and card.data.myconid_effect == MyconidEffect.Effect.DECOMPOSER:
		actual += 2 if card.is_radiant else 1
	card.myconid_spores += actual
	if card.data != null and card.data.myconid_effect == MyconidEffect.Effect.SPOREGUARD \
			and card.myconid_spores >= 10 \
			and (card.current_keywords & KeywordFlags.Keyword.DIVINE_SHIELD) == 0:
		card.current_keywords |= KeywordFlags.Keyword.DIVINE_SHIELD
	card.refresh_display()


func _on_myconid_spore_distributed(card: UnitCard) -> void:
	if _myconid_shop_data.spore_pool <= 0 or not is_instance_valid(card):
		return
	_myconid_shop_data.spore_pool -= 1
	_give_spore_to(card, 1)
	_save_player_order()
	_save_bench()
	_save_resources()
	_myconid_shop.refresh_gold(_gold, _get_myconid_board_units())


func _do_blood_tribute(free_use: bool) -> void:
	if not free_use and _aztec_tribute_used:
		return
	if not free_use and _player_hp <= 5:
		return
	var gold_gain := _aztec_shop_data.tribute_gold(_player_tier)
	if not free_use:
		_player_hp -= 5
	_gold += gold_gain
	if not free_use:
		_aztec_tribute_used = true
	# Devourer: each tribute counts toward run total
	_aztec_shop_data.devourer_count += 1
	_apply_devourer_bonus()
	_save_resources()
	_update_resource_bar()
	_aztec_shop.refresh_gold(_gold, _player_hp, _aztec_tribute_used, _aztec_sacrifice_used)
	print("Blood Tribute: %s+%dg (tier %d × rate %d)!" % [
		"" if free_use else "-5 HP, ", gold_gain, _player_tier, _aztec_shop_data.tribute_rate])


func _apply_devourer_bonus() -> void:
	for card in player_board.units + player_bench.units:
		if is_instance_valid(card) and card.data != null \
				and card.data.race == RaceType.Race.AZTEC \
				and card.data.aztec_effect == AztecEffect.Effect.THE_DEVOURER:
			card.current_attack += 4
			card.current_health += 4
			card.refresh_display()


func _count_blood_font_charges() -> int:
	var charges := 0
	for card in player_board.units + player_bench.units:
		if is_instance_valid(card) and card.data != null \
				and card.data.race == RaceType.Race.AZTEC \
				and card.data.aztec_effect == AztecEffect.Effect.BLOOD_FONT:
			charges += 2 if card.is_radiant else 1
	return charges


func _start_sacrifice_targeting(free_use: bool) -> void:
	if not free_use and _aztec_sacrifice_used:
		return
	var valid: Array = []
	for card in player_board.units:
		if is_instance_valid(card) and card.data != null:
			valid.append(card)
	for card in player_bench.units:
		if is_instance_valid(card) and card.data != null:
			valid.append(card)
	if valid.is_empty():
		return
	_aztec_shop.close()
	_start_targeting(null, valid, func(picked: UnitCard):
		var is_aztec := picked.data.race == RaceType.Race.AZTEC
		var is_anointed := is_aztec and picked.data.aztec_effect == AztecEffect.Effect.ANOINTED_VESSEL
		var gold_gain := picked.data.tier * _aztec_shop_data.sacrifice_rate
		if is_aztec:
			gold_gain *= 2
		if is_anointed:
			gold_gain *= 2
		var sac_atk := picked.current_attack
		var sac_hp := picked.current_health
		if not free_use:
			_aztec_sacrifice_used = true
		_remove_unit_card(picked)
		# Devourer: +4/+4 per sacrifice, track run count
		_aztec_shop_data.devourer_count += 1
		_apply_devourer_bonus()
		# Blood Witness: +2/+2 (Radiant: +4/+4) on any friendly board/bench unit with this effect
		for card in player_board.units + player_bench.units:
			if is_instance_valid(card) and card.data != null \
					and card.data.race == RaceType.Race.AZTEC \
					and card.data.aztec_effect == AztecEffect.Effect.BLOOD_WITNESS:
				var gain := 4 if card.is_radiant else 2
				card.current_attack += gain
				card.current_health += gain
				card.refresh_display()
		# Blood Feast: gain sacrificed unit's ATK and HP
		for card in player_board.units + player_bench.units:
			if is_instance_valid(card) and card.data != null \
					and card.data.race == RaceType.Race.AZTEC \
					and card.data.aztec_effect == AztecEffect.Effect.BLOOD_FEAST:
				card.current_attack += sac_atk
				card.current_health += sac_hp
				card.refresh_display()
		_gold += gold_gain
		_save_resources()
		_update_resource_bar()
		_save_player_order()
		_save_bench()
		print("Sacrifice: +%dg for %s (tier %d%s%s)!" % [
			gold_gain, picked.data.display_name, picked.data.tier,
			" (Aztec x2)" if is_aztec else "",
			" (Anointed x2)" if is_anointed else ""])
	)


func _remove_unit_card(card: UnitCard) -> void:
	if player_board.units.has(card):
		player_board.remove_unit(card)  # remove_unit already calls queue_free
		_save_player_order()
	elif player_bench.units.has(card):
		player_bench.remove_unit_from_display(card)
		card.queue_free()
		_save_bench()


func _on_mage_trigger_bought(trigger: int) -> void:
	var target := _mage_shop.get_target_card()
	if not is_instance_valid(target) or target.equipped_spell == null:
		return
	var inst: SpellInstance = target.equipped_spell
	var cost := inst.get_upgrade_cost(trigger)
	if _gold < cost:
		return
	_gold -= cost
	inst.upgrade_trigger(trigger)
	target.refresh_display()
	_save_resources()
	_update_resource_bar()
	_mage_shop.refresh(_gold)


func _on_mage_effect_upgraded() -> void:
	var target := _mage_shop.get_target_card()
	if not is_instance_valid(target):
		return
	var cost := 4 + target.mage_effect_level
	if _gold < cost:
		return
	_gold -= cost
	target.mage_effect_level += 1
	target.refresh_display()
	_save_resources()
	_update_resource_bar()
	_mage_shop.refresh(_gold)


func _on_spell_bought(spell: SpellData) -> void:
	if _gold < spell.buy_price:
		return
	_gold -= spell.buy_price
	_save_resources()
	_update_resource_bar()
	_spell_shop.remove_offering(spell)
	_spell_shop.refresh_gold(_gold)
	_spell_hand.append(spell)
	_add_spell_card_to_bench(spell)


func _on_spell_shop_refresh_requested() -> void:
	if _gold < 1:
		return
	_gold -= 1
	_save_resources()
	_update_resource_bar()
	_spell_shop.do_refresh(_gold)


func _add_spell_card_to_bench(spell: SpellData) -> void:
	var card := Panel.new()
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.14, 0.08, 0.26, 1.0)
	style.set_corner_radius_all(4)
	style.set_border_width_all(1)
	style.border_color = Color(0.55, 0.40, 0.80, 1.0)
	card.add_theme_stylebox_override("panel", style)
	card.custom_minimum_size = Vector2(92, 109)
	card.mouse_filter = Control.MOUSE_FILTER_STOP
	card.tooltip_text = spell.description

	var vbox := VBoxContainer.new()
	vbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	vbox.add_theme_constant_override("separation", 4)
	card.add_child(vbox)

	var spacer := Control.new()
	spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vbox.add_child(spacer)

	var name_lbl := Label.new()
	name_lbl.text = spell.display_name
	name_lbl.add_theme_font_size_override("font_size", 12)
	name_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD
	vbox.add_child(name_lbl)

	var type_lbl := Label.new()
	type_lbl.text = "SPELL"
	type_lbl.add_theme_font_size_override("font_size", 11)
	type_lbl.add_theme_color_override("font_color", Color(0.7, 0.5, 1.0))
	type_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(type_lbl)

	var spacer2 := Control.new()
	spacer2.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vbox.add_child(spacer2)

	card.gui_input.connect(func(event: InputEvent) -> void:
		if event is InputEventMouseButton \
				and event.button_index == MOUSE_BUTTON_LEFT \
				and event.pressed:
			_cast_hand_spell(spell, card))

	player_bench.slots_container.add_child(card)
	_spell_hand_nodes.append(card)


func _clear_spell_hand_nodes() -> void:
	for node in _spell_hand_nodes:
		if is_instance_valid(node):
			node.queue_free()
	_spell_hand_nodes.clear()
	_spell_hand.clear()


func _apply_instant_spell_effect(spell: SpellData) -> void:
	# Familiar: permanent +1/+1 whenever any spell is cast outside combat
	for unit in player_board.units:
		if is_instance_valid(unit) and not unit.is_dead \
				and unit.data.mage_effect == MageEffect.Effect.FAMILIAR:
			unit.current_attack += 1
			unit.current_health += 1
			unit.refresh_display()
	if _support_card != null and is_instance_valid(_support_card) and not _support_card.is_dead \
			and _support_card.data.mage_effect == MageEffect.Effect.FAMILIAR:
		_support_card.current_attack += 1
		_support_card.current_health += 1
		_support_card.refresh_display()

	match spell.spell_type:
		SpellData.SpellType.EMBOLDEN:
			_apply_board_buff(_asp, _hsp)
		SpellData.SpellType.WAR_SURGE:
			_apply_board_buff(_asp * 3, _hsp * 3)
			_apply_board_buff(_asp * 3, _hsp * 3)
		SpellData.SpellType.ARCANE_INFUSION:
			_asp += 1
			_hsp += 1
			_save_resources()
			_update_resource_bar()
		SpellData.SpellType.MENDING_TOUCH:
			var candidates: Array = []
			for unit in player_board.units:
				if is_instance_valid(unit) and not unit.is_dead:
					candidates.append(unit)
			if _support_card != null and is_instance_valid(_support_card) and not _support_card.is_dead:
				candidates.append(_support_card)
			if not candidates.is_empty():
				var target: UnitCard = candidates[randi() % candidates.size()]
				target.current_attack += 1 + _asp
				target.current_health += 1 + _hsp
				target.refresh_display()
		SpellData.SpellType.ARCANE_SURGE:
			pass  # damage only; no permanent out-of-combat effect
		SpellData.SpellType.KINDRED_SEARCH:
			var race := _get_most_common_race()
			if race != RaceType.Race.NONE:
				discovery_screen.activate_filtered(_player_tier, race)
		SpellData.SpellType.WILD_CALL:
			_wild_call_pending = true
			_open_race_picker()
		SpellData.SpellType.BATTLE_TRANCE:
			_apply_board_buff(_asp, _asp)
		SpellData.SpellType.ARCANE_SNARE:
			pass  # field effect only; stacks are tracked in CombatManager during combat
		SpellData.SpellType.BOLSTER:
			_open_unit_target_picker(func(target: UnitCard) -> void:
				target.current_attack += 2
				target.current_health += 2
				target.refresh_display()
				target.flash_surge_buff())
		SpellData.SpellType.FORTIFY:
			_open_unit_target_picker(func(target: UnitCard) -> void:
				target.current_attack += 1
				target.current_health += 6
				target.current_keywords |= KeywordFlags.Keyword.TAUNT
				target.refresh_display()
				target.flash_surge_buff())


func _open_witch_doctor_picker(source: UnitCard) -> void:
	var overlay := ColorRect.new()
	overlay.color = Color(0, 0, 0, 0.55)
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.z_index = 70
	overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(overlay)

	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	center.mouse_filter = Control.MOUSE_FILTER_PASS
	overlay.add_child(center)

	var panel := PanelContainer.new()
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.10, 0.12, 0.18, 1.0)
	style.set_corner_radius_all(8)
	style.set_border_width_all(2)
	style.border_color = Color(0.55, 0.40, 0.80, 1.0)
	panel.add_theme_stylebox_override("panel", style)
	panel.custom_minimum_size = Vector2(240, 0)
	center.add_child(panel)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 14)
	margin.add_theme_constant_override("margin_right", 14)
	margin.add_theme_constant_override("margin_top", 12)
	margin.add_theme_constant_override("margin_bottom", 12)
	panel.add_child(margin)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 8)
	margin.add_child(vbox)

	var title := Label.new()
	title.text = "Witch Doctor — choose a keyword:"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 14)
	vbox.add_child(title)

	vbox.add_child(HSeparator.new())

	for kw_pair: Array in [[KeywordFlags.Keyword.REBORN, "Reborn"], [KeywordFlags.Keyword.TAUNT, "Taunt"]]:
		var btn := Button.new()
		btn.text = kw_pair[1]
		var kw_flag: int = kw_pair[0]
		btn.pressed.connect(func() -> void:
			overlay.queue_free()
			_apply_witch_doctor_keyword(source, kw_flag))
		vbox.add_child(btn)

	var cancel := Button.new()
	cancel.text = "Cancel"
	cancel.pressed.connect(overlay.queue_free)
	vbox.add_child(cancel)


func _apply_witch_doctor_keyword(source: UnitCard, keyword: int) -> void:
	var targets: Array = player_board.units.filter(
		func(u): return is_instance_valid(u) and u.data != null and not u.is_dead)
	if targets.is_empty():
		return
	if targets.size() == 1:
		targets[0].current_keywords |= keyword
		targets[0].refresh_display()
		targets[0].flash_surge_buff()
		source.flash_surge_source()
		return
	_open_unit_target_picker_from_list(targets, func(target: UnitCard) -> void:
		target.current_keywords |= keyword
		target.refresh_display()
		target.flash_surge_buff()
		source.flash_surge_source())


func _open_unit_target_picker_from_list(targets: Array, callback: Callable) -> void:
	var overlay := ColorRect.new()
	overlay.color = Color(0, 0, 0, 0.55)
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.z_index = 70
	overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(overlay)

	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	center.mouse_filter = Control.MOUSE_FILTER_PASS
	overlay.add_child(center)

	var panel := PanelContainer.new()
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.10, 0.12, 0.18, 1.0)
	style.set_corner_radius_all(8)
	style.set_border_width_all(2)
	style.border_color = Color(0.55, 0.40, 0.80, 1.0)
	panel.add_theme_stylebox_override("panel", style)
	panel.custom_minimum_size = Vector2(240, 0)
	center.add_child(panel)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 14)
	margin.add_theme_constant_override("margin_right", 14)
	margin.add_theme_constant_override("margin_top", 12)
	margin.add_theme_constant_override("margin_bottom", 12)
	panel.add_child(margin)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 8)
	margin.add_child(vbox)

	var title := Label.new()
	title.text = "Choose a target"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 14)
	vbox.add_child(title)

	vbox.add_child(HSeparator.new())

	for unit: UnitCard in targets:
		var btn := Button.new()
		btn.text = "%s  %d/%d" % [unit.data.display_name, unit.current_attack, unit.current_health]
		btn.pressed.connect(func() -> void:
			overlay.queue_free()
			callback.call(unit))
		vbox.add_child(btn)

	var cancel := Button.new()
	cancel.text = "Cancel"
	cancel.pressed.connect(overlay.queue_free)
	vbox.add_child(cancel)


func _open_unit_target_picker(callback: Callable) -> void:
	var targets: Array = player_board.units.filter(
		func(u): return is_instance_valid(u) and u.data != null and not u.is_dead)
	if targets.is_empty():
		return
	if targets.size() == 1:
		callback.call(targets[0])
		return

	var overlay := ColorRect.new()
	overlay.color = Color(0, 0, 0, 0.55)
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.z_index = 70
	overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(overlay)

	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	center.mouse_filter = Control.MOUSE_FILTER_PASS
	overlay.add_child(center)

	var panel := PanelContainer.new()
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.10, 0.12, 0.18, 1.0)
	style.set_corner_radius_all(8)
	style.set_border_width_all(2)
	style.border_color = Color(0.55, 0.40, 0.80, 1.0)
	panel.add_theme_stylebox_override("panel", style)
	panel.custom_minimum_size = Vector2(240, 0)
	center.add_child(panel)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 14)
	margin.add_theme_constant_override("margin_right", 14)
	margin.add_theme_constant_override("margin_top", 12)
	margin.add_theme_constant_override("margin_bottom", 12)
	panel.add_child(margin)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 8)
	margin.add_child(vbox)

	var title := Label.new()
	title.text = "Choose a target"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 14)
	vbox.add_child(title)

	vbox.add_child(HSeparator.new())

	for unit: UnitCard in targets:
		var btn := Button.new()
		btn.text = "%s  %d/%d" % [unit.data.display_name, unit.current_attack, unit.current_health]
		btn.pressed.connect(func() -> void:
			overlay.queue_free()
			callback.call(unit))
		vbox.add_child(btn)

	var cancel := Button.new()
	cancel.text = "Cancel"
	cancel.pressed.connect(overlay.queue_free)
	vbox.add_child(cancel)


func _cast_hand_spell(spell: SpellData, card: Panel) -> void:
	if player_board.is_locked or not is_instance_valid(card):
		return
	_last_spell_bought = spell
	var idx := _spell_hand_nodes.find(card)
	if idx >= 0:
		_spell_hand.remove_at(idx)
		_spell_hand_nodes.remove_at(idx)
	card.queue_free()
	_apply_instant_spell_effect(spell)


func _apply_board_buff(atk_bonus: int, hp_bonus: int) -> void:
	for card: UnitCard in player_board.units:
		if is_instance_valid(card):
			card.current_attack += atk_bonus
			card.current_health += hp_bonus
			card.refresh_display()
	for card: UnitCard in player_bench.units:
		if is_instance_valid(card):
			card.current_attack += atk_bonus
			card.current_health += hp_bonus
			card.refresh_display()
	if _support_card != null and is_instance_valid(_support_card):
		_support_card.current_attack += atk_bonus
		_support_card.current_health += hp_bonus
		_support_card.refresh_display()


func _get_most_common_race() -> int:
	var counts: Dictionary = {}
	for card: UnitCard in player_board.units + player_bench.units:
		if not is_instance_valid(card) or card.data == null:
			continue
		var r := card.data.race
		counts[r] = counts.get(r, 0) + 1
	if _support_card != null and is_instance_valid(_support_card) and _support_card.data != null:
		var r := _support_card.data.race
		counts[r] = counts.get(r, 0) + 1
	var best_race := RaceType.Race.NONE
	var best_count := 0
	for r in counts:
		if counts[r] > best_count:
			best_count = counts[r]
			best_race = r
	return best_race


func _open_race_picker() -> void:
	if _race_picker != null:
		_race_picker.queue_free()

	_race_picker = Panel.new()
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.10, 0.12, 0.18, 1.0)
	style.set_corner_radius_all(6)
	style.set_border_width_all(1)
	style.border_color = Color(0.45, 0.50, 0.70, 1.0)
	_race_picker.add_theme_stylebox_override("panel", style)
	add_child(_race_picker)
	_race_picker.set_anchors_preset(Control.PRESET_CENTER)
	_race_picker.position = Vector2(200, 150)

	var vbox := VBoxContainer.new()
	vbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	vbox.add_theme_constant_override("separation", 6)
	_race_picker.add_child(vbox)

	var lbl := Label.new()
	lbl.text = "Wild Call — Choose a type:"
	lbl.add_theme_font_size_override("font_size", 12)
	vbox.add_child(lbl)

	var races := [
		[RaceType.Race.HUMAN, "Human"],
		[RaceType.Race.ELF, "Elf"],
		[RaceType.Race.MAGE, "Mage"],
		[RaceType.Race.GOBLIN, "Goblin"],
		[RaceType.Race.COVENANT, "Covenant"],
	]
	for pair in races:
		var btn := Button.new()
		btn.text = pair[1]
		btn.pressed.connect(_on_race_picked.bind(pair[0]))
		vbox.add_child(btn)


func _on_race_picked(race: int) -> void:
	if _race_picker != null:
		_race_picker.queue_free()
		_race_picker = null
	discovery_screen.activate_filtered(_player_tier, race)


# ── Sell ──────────────────────────────────────────────────────────────────────

func _handle_sell(sold_card: UnitCard) -> void:
	if sold_card.equipped_weapon != null:
		_gold += sold_card.equipped_weapon.get_sell_value()
	if sold_card.backpack_weapon != null:
		_gold += sold_card.backpack_weapon.get_sell_value()
	_save_resources()
	_update_resource_bar()
	_save_player_order()
	_save_bench()
	_sell_counter += 1
	_save_sell_counter()
	_update_sell_label()

	if _sell_counter >= GameData.sell_threshold:
		_sell_counter = 0
		_save_sell_counter()
		_update_sell_label()
		_discovery_from_combat = false
		discovery_screen.activate(_player_tier)


func _update_sell_label() -> void:
	sell_label.text = "SELL  —  %d / %d  →  Discovery" % [_sell_counter, GameData.sell_threshold]


# ── Resource bar ──────────────────────────────────────────────────────────────

func _update_resource_bar() -> void:
	_update_support_slot_ui()
	var next_income := _gold_income + 1
	gold_label.text = "Gold: %d  (+%d/turn)" % [_gold, next_income]
	hp_label.text = "HP: %d" % _player_hp
	hp_label.add_theme_color_override("font_color",
		Color(1, 0.38, 0.38, 1) if _player_hp <= 30 else Color(0.55, 1.0, 0.55, 1))
	tier_label.text = "Tier %d  |  ASP: %d  HSP: %d" % [_player_tier, _asp, _hsp]
	if _player_tier >= 4:
		tier_upgrade_button.visible = false
	else:
		var cost := _get_tier_upgrade_cost()
		tier_upgrade_button.visible = true
		tier_upgrade_button.text = "Upgrade Tier  (%dg)" % cost
		tier_upgrade_button.disabled = _gold < cost


# ── Persistence ───────────────────────────────────────────────────────────────

func _card_to_dict(card: UnitCard) -> Dictionary:
	var spell_path := ""
	var spell_triggers: Dictionary = {}
	if card.equipped_spell != null:
		spell_path = card.equipped_spell.spell_data.resource_path
		for k in card.equipped_spell.triggers:
			spell_triggers[str(k)] = int(card.equipped_spell.triggers[k])
	var d := {
		"path": card.data.resource_path,
		"atk": card.current_attack,
		"hp": card.current_health,
		"kw": card.current_keywords,
		"radiant": card.is_radiant,
		"weapon_level": card.equipped_weapon.level if card.equipped_weapon != null else -1,
		"backpack_type": card.backpack_weapon.weapon_type if card.backpack_weapon != null else -1,
		"backpack_level": card.backpack_weapon.level if card.backpack_weapon != null else -1,
		"spell_path": spell_path,
		"spell_triggers": spell_triggers,
		"construct_charge": card.construct_charge,
		"myconid_spores": card.myconid_spores,
	}
	return d


func _apply_card_entry(card: UnitCard, entry) -> void:
	var path: String = entry if entry is String else entry.get("path", "")
	var unit_data: UnitData = load(path)
	if unit_data == null:
		return
	card.initialize(unit_data)
	_connect_player_card(card)
	if entry is Dictionary:
		card.current_attack = int(entry.get("atk", unit_data.base_attack))
		card.current_health = int(entry.get("hp", unit_data.base_health))
		card.current_keywords = int(entry.get("kw", unit_data.keywords))
		card.is_radiant = bool(entry.get("radiant", false))
		var wlevel := int(entry.get("weapon_level", -1))
		if wlevel >= 0 and card.equipped_weapon != null:
			card.equipped_weapon.level = wlevel
		var btype := int(entry.get("backpack_type", -1))
		var blevel := int(entry.get("backpack_level", -1))
		if btype >= 0 and WEAPON_TEMPLATES.has(btype):
			card.backpack_weapon = WEAPON_TEMPLATES[btype].duplicate()
			card.backpack_weapon.level = blevel
		var spell_path: String = entry.get("spell_path", "")
		if spell_path != "":
			var sd: SpellData = load(spell_path)
			if sd != null:
				card.equipped_spell = SpellInstance.new(sd)
				var trig_dict = entry.get("spell_triggers", {})
				if trig_dict is Dictionary:
					for k in trig_dict:
						card.equipped_spell.triggers[int(k)] = int(trig_dict[k])
		card.construct_charge = int(entry.get("construct_charge", 0))
		card.myconid_spores = int(entry.get("myconid_spores", 0))
		if card.data != null and card.data.myconid_effect == MyconidEffect.Effect.SPOREGUARD \
				and card.myconid_spores >= 10:
			card.current_keywords |= KeywordFlags.Keyword.DIVINE_SHIELD
		card.refresh_display()


func _save_player_order() -> void:
	var order: Array = []
	for card: UnitCard in player_board.units:
		if is_instance_valid(card) and card.data != null:
			order.append(_card_to_dict(card))
	var file := FileAccess.open(ORDER_SAVE_PATH, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(order))
		file.close()


func _clear_cache_files() -> void:
	var dir := DirAccess.open("user://")
	if dir == null:
		return
	for path in [ORDER_SAVE_PATH, BENCH_SAVE_PATH, ROUND_SAVE_PATH,
			SELL_COUNTER_SAVE_PATH, RESOURCES_SAVE_PATH, FACTIONS_SAVE_PATH]:
		var fname := path.get_file()
		if DirAccess.open("user://") != null and FileAccess.file_exists(path):
			dir.remove(fname)


func _load_player_order() -> Array:
	if not FileAccess.file_exists(ORDER_SAVE_PATH):
		return []
	var file := FileAccess.open(ORDER_SAVE_PATH, FileAccess.READ)
	if file == null:
		return []
	var parsed = JSON.parse_string(file.get_as_text())
	file.close()
	return parsed if parsed is Array else []


func _save_bench() -> void:
	var order: Array = []
	for card: UnitCard in player_bench.units:
		if is_instance_valid(card) and card.data != null:
			order.append(_card_to_dict(card))
	var file := FileAccess.open(BENCH_SAVE_PATH, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(order))
		file.close()


func _load_bench() -> Array:
	if not FileAccess.file_exists(BENCH_SAVE_PATH):
		return []
	var file := FileAccess.open(BENCH_SAVE_PATH, FileAccess.READ)
	if file == null:
		return []
	var parsed = JSON.parse_string(file.get_as_text())
	file.close()
	return parsed if parsed is Array else []


func _save_sell_counter() -> void:
	var file := FileAccess.open(SELL_COUNTER_SAVE_PATH, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(_sell_counter))
		file.close()


func _load_sell_counter() -> void:
	if not FileAccess.file_exists(SELL_COUNTER_SAVE_PATH):
		return
	var file := FileAccess.open(SELL_COUNTER_SAVE_PATH, FileAccess.READ)
	if file == null:
		return
	var parsed = JSON.parse_string(file.get_as_text())
	file.close()
	if parsed != null:
		_sell_counter = int(parsed)


func _initialize_active_factions() -> void:
	if FileAccess.file_exists(FACTIONS_SAVE_PATH):
		var file := FileAccess.open(FACTIONS_SAVE_PATH, FileAccess.READ)
		if file:
			var parsed = JSON.parse_string(file.get_as_text())
			file.close()
			if parsed is Array and not parsed.is_empty():
				_active_factions = parsed.map(func(v): return int(v))
				return
	var pool: Array = ALL_PLAYABLE_FACTIONS.duplicate()
	pool.shuffle()
	_active_factions = pool.slice(0, 6)
	_save_active_factions()


func _save_active_factions() -> void:
	var file := FileAccess.open(FACTIONS_SAVE_PATH, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(_active_factions))
		file.close()


func _save_round() -> void:
	var file := FileAccess.open(ROUND_SAVE_PATH, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(_round))
		file.close()


func _load_round() -> void:
	if not FileAccess.file_exists(ROUND_SAVE_PATH):
		return
	var file := FileAccess.open(ROUND_SAVE_PATH, FileAccess.READ)
	if file == null:
		return
	var parsed = JSON.parse_string(file.get_as_text())
	file.close()
	if parsed != null:
		_round = int(parsed)


func _save_resources() -> void:
	var data := {
		"gold": _gold,
		"gold_income": _gold_income,
		"lifetime_gold": _lifetime_gold,
		"tier": _player_tier,
		"player_hp": _player_hp,
		"asp": _asp,
		"hsp": _hsp,
		"support_unlocked": _support_slot_unlocked,
		"support_card": _card_to_dict(_support_card) if _support_card != null else {},
		"goblin_shop": _goblin_shop_data.to_dict() if _goblin_shop_data != null else {},
		"elf_shop": _elf_shop_data.to_dict() if _elf_shop_data != null else {},
		"covenant_shop": _covenant_shop_data.to_dict() if _covenant_shop_data != null else {},
		"aztec_shop": _aztec_shop_data.to_dict() if _aztec_shop_data != null else {},
		"aztec_tribute_used": _aztec_tribute_used,
		"aztec_sacrifice_used": _aztec_sacrifice_used,
		"construct_shop": _construct_shop_data.to_dict() if _construct_shop_data != null else {},
		"reaper_shop": _reaper_shop_data.to_dict() if _reaper_shop_data != null else {},
		"myconid_shop": _myconid_shop_data.to_dict() if _myconid_shop_data != null else {},
		"satyr_shop": _satyr_shop_data.to_dict() if _satyr_shop_data != null else {},
	}
	var file := FileAccess.open(RESOURCES_SAVE_PATH, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(data))
		file.close()


func _load_resources() -> void:
	if not FileAccess.file_exists(RESOURCES_SAVE_PATH):
		return
	var file := FileAccess.open(RESOURCES_SAVE_PATH, FileAccess.READ)
	if file == null:
		return
	var parsed = JSON.parse_string(file.get_as_text())
	file.close()
	if parsed is Dictionary:
		_gold = int(parsed.get("gold", 0))
		_gold_income = int(parsed.get("gold_income", 0))
		_player_tier = int(parsed.get("tier", 1))
		if parsed.has("lifetime_gold"):
			_lifetime_gold = int(parsed.get("lifetime_gold", 0))
		else:
			# Approximate from existing data for saves that predate this field
			var rounds := maxi(0, _gold_income - 2)
			var tier_costs := [0, 10, 30, 60]
			_lifetime_gold = rounds * (rounds + 5) / 2 + tier_costs[clampi(_player_tier - 1, 0, 3)]
		_player_hp = int(parsed.get("player_hp", 100))
		_asp = int(parsed.get("asp", 1))
		_hsp = int(parsed.get("hsp", 1))
		_support_slot_unlocked = bool(parsed.get("support_unlocked", false))
		var sc = parsed.get("support_card", {})
		_pending_support_card_dict = sc if sc is Dictionary else {}
		var gs = parsed.get("goblin_shop", {})
		if gs is Dictionary and not gs.is_empty() and _goblin_shop_data != null:
			_goblin_shop_data.from_dict(gs)
		var es = parsed.get("elf_shop", {})
		if es is Dictionary and not es.is_empty() and _elf_shop_data != null:
			_elf_shop_data.from_dict(es)
		var cs = parsed.get("covenant_shop", {})
		if cs is Dictionary and not cs.is_empty() and _covenant_shop_data != null:
			_covenant_shop_data.from_dict(cs)
		var az = parsed.get("aztec_shop", {})
		if az is Dictionary and not az.is_empty() and _aztec_shop_data != null:
			_aztec_shop_data.from_dict(az)
		_aztec_tribute_used = bool(parsed.get("aztec_tribute_used", false))
		_aztec_sacrifice_used = bool(parsed.get("aztec_sacrifice_used", false))
		var csd = parsed.get("construct_shop", {})
		if csd is Dictionary and not csd.is_empty() and _construct_shop_data != null:
			_construct_shop_data.from_dict(csd)
		var rsd = parsed.get("reaper_shop", {})
		if rsd is Dictionary and not rsd.is_empty() and _reaper_shop_data != null:
			_reaper_shop_data.from_dict(rsd)
		var msd = parsed.get("myconid_shop", {})
		if msd is Dictionary and not msd.is_empty() and _myconid_shop_data != null:
			_myconid_shop_data.from_dict(msd)
		var ssd = parsed.get("satyr_shop", {})
		if ssd is Dictionary and not ssd.is_empty() and _satyr_shop_data != null:
			_satyr_shop_data.from_dict(ssd)


# ── Human shop (Armory) ───────────────────────────────────────────────────────

func _open_weapon_menu(card: UnitCard) -> void:
	var human_cards: Array = player_board.units.filter(
		func(c: UnitCard): return c.data.race == RaceType.Race.HUMAN)
	_human_shop.weapon_discount_mult = _get_arms_dealer_multiplier()
	_human_shop.pending_weapon_discount = _pending_weapon_discount
	_human_shop.open(human_cards, card, _gold)


func _close_weapon_menu() -> void:
	_human_shop.close()


func _get_arms_dealer_multiplier() -> float:
	var mult := 1.0
	for unit: UnitCard in player_board.units:
		if is_instance_valid(unit) and unit.data != null \
				and unit.data.human_effect == HumanEffect.Effect.UPGRADE_DISCOUNT:
			mult *= 0.8
			if unit.is_radiant:
				mult *= 0.8
	if _support_card != null and is_instance_valid(_support_card) and _support_card.data != null \
			and _support_card.data.human_effect == HumanEffect.Effect.UPGRADE_DISCOUNT:
		mult *= 0.8
		if _support_card.is_radiant:
			mult *= 0.8
	return mult


func _on_human_weapon_bought(wtype: int) -> void:
	var card := _human_shop.get_target_card()
	if not is_instance_valid(card):
		return
	if card.equipped_weapon != null and card.backpack_weapon != null:
		return
	var template: WeaponData = WEAPON_TEMPLATES[wtype]
	var price: int = max(0, ceili(template.buy_price * _get_arms_dealer_multiplier()) - _pending_weapon_discount)
	if _gold < price:
		return
	_gold -= price
	_pending_weapon_discount = 0
	var new_weapon := template.duplicate()
	if card.equipped_weapon == null:
		card.equipped_weapon = new_weapon
	else:
		card.backpack_weapon = new_weapon
	_save_resources()
	_update_resource_bar()
	card.refresh_display()
	_human_shop.weapon_discount_mult = _get_arms_dealer_multiplier()
	_human_shop.pending_weapon_discount = _pending_weapon_discount
	_human_shop.refresh(_gold)


func _on_human_weapon_upgraded() -> void:
	var card := _human_shop.get_target_card()
	if not is_instance_valid(card) or card.equipped_weapon == null:
		return
	var w := card.equipped_weapon
	var cost: int = max(1, ceili(w.get_upgrade_cost() * _get_arms_dealer_multiplier()) - _pending_weapon_discount)
	if _gold < cost:
		return
	_gold -= cost
	_pending_weapon_discount = 0
	w.level += 1
	if card.data.human_effect == HumanEffect.Effect.DUAL_WIELD and card.backpack_weapon != null:
		card.backpack_weapon.level += 1
	_save_resources()
	_update_resource_bar()
	card.refresh_display()
	_human_shop.weapon_discount_mult = _get_arms_dealer_multiplier()
	_human_shop.pending_weapon_discount = _pending_weapon_discount
	_human_shop.refresh(_gold)


func _on_human_weapon_sold() -> void:
	var card := _human_shop.get_target_card()
	if not is_instance_valid(card) or card.equipped_weapon == null:
		return
	_gold += card.equipped_weapon.get_sell_value()
	card.equipped_weapon = card.backpack_weapon
	card.backpack_weapon = null
	_save_resources()
	_update_resource_bar()
	card.refresh_display()
	_human_shop.weapon_discount_mult = _get_arms_dealer_multiplier()
	_human_shop.pending_weapon_discount = _pending_weapon_discount
	_human_shop.refresh(_gold)


func _on_human_weapon_swapped() -> void:
	var card := _human_shop.get_target_card()
	if not is_instance_valid(card) or card.backpack_weapon == null:
		return
	var tmp := card.equipped_weapon
	card.equipped_weapon = card.backpack_weapon
	card.backpack_weapon = tmp
	card.refresh_display()
	_human_shop.refresh(_gold)


# ── Support slot ─────────────────────────────────────────────────────────────

func _setup_support_slot_panel() -> void:
	_support_slot_panel = Panel.new()
	_support_slot_panel.z_index = 20
	_support_slot_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.12, 0.16, 0.24, 0.92)
	style.set_corner_radius_all(8)
	style.set_border_width_all(2)
	style.border_color = Color(0.45, 0.50, 0.70, 1.0)
	_support_slot_panel.add_theme_stylebox_override("panel", style)
	add_child(_support_slot_panel)

	var vbox := VBoxContainer.new()
	vbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	vbox.offset_left = 6; vbox.offset_top = 6; vbox.offset_right = -6; vbox.offset_bottom = -6
	vbox.add_theme_constant_override("separation", 4)
	vbox.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_support_slot_panel.add_child(vbox)

	var title := Label.new()
	title.text = "SUPPORT"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 10)
	title.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vbox.add_child(title)

	_support_buy_button = Button.new()
	_support_buy_button.text = "Buy (50g)"
	_support_buy_button.pressed.connect(_on_buy_support_pressed)
	vbox.add_child(_support_buy_button)

	_support_empty_label = Label.new()
	_support_empty_label.text = "Drop unit here"
	_support_empty_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_support_empty_label.add_theme_font_size_override("font_size", 9)
	_support_empty_label.autowrap_mode = TextServer.AUTOWRAP_WORD
	_support_empty_label.visible = false
	_support_empty_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vbox.add_child(_support_empty_label)

	_update_support_slot_ui()

	# Apply pending support card loaded from save (old save format migration)
	if _pending_support_card_dict.size() > 0 and _support_slot_unlocked:
		var card: UnitCard = UnitCardScene.instantiate()
		_apply_card_entry(card, _pending_support_card_dict)
		_connect_player_card(card)
		_place_support_card(card)
		_pending_support_card_dict = {}


func _update_support_slot_ui() -> void:
	if _support_slot_panel == null:
		return
	var pb_rect := player_board.get_global_rect()
	_support_slot_panel.size = Vector2(110, 185)
	_support_slot_panel.global_position = Vector2(
		pb_rect.end.x - 118, pb_rect.position.y + 4)
	if _support_buy_button != null:
		_support_buy_button.visible = not _support_slot_unlocked
		_support_buy_button.disabled = _gold < 50
	if _support_empty_label != null:
		_support_empty_label.visible = _support_slot_unlocked and player_board.units.size() < 8


func _on_buy_support_pressed() -> void:
	if _gold < 50 or _support_slot_unlocked:
		return
	_gold -= 50
	_support_slot_unlocked = true
	_save_resources()
	_update_resource_bar()
	_update_support_slot_ui()


func _place_support_card(card: UnitCard) -> void:
	_support_card = card
	if card.get_parent() != null:
		card.get_parent().remove_child(card)
	_support_slot_panel.add_child(card)
	card.position = Vector2.ZERO
	card.size = _support_slot_panel.size
	card.is_draggable = true
	card.z_index = 0
	if _support_empty_label != null:
		_support_empty_label.visible = false
	_save_resources()


func _remove_support_card() -> UnitCard:
	var card := _support_card
	_support_card = null
	if card != null and is_instance_valid(card):
		if card.get_parent() == _support_slot_panel:
			_support_slot_panel.remove_child(card)
	if _support_empty_label != null:
		_support_empty_label.visible = _support_slot_unlocked
	_save_resources()
	return card


func _on_combat_ended(damage: int) -> void:
	# Gauntlet fights bypass all normal round logic
	if GameData.gauntlet_mode:
		_on_gauntlet_fight_ended(damage <= 0)
		return

	_aztec_tribute_used = false
	_aztec_sacrifice_used = false
	_aztec_free_tributes_used = 0
	_aztec_free_tributes_available = _count_blood_font_charges()

	# Restore persistent charge, clear combat state, run Accumulator
	var construct_post: Dictionary = {}
	for card: UnitCard in player_board.units:
		if is_instance_valid(card) and not card.is_dead and card.data != null \
				and card.data.race == RaceType.Race.CONSTRUCT:
			card.construct_charge = card.construct_persistent_charge
			card.construct_depowered = false
			card.construct_reignited = false
			card.construct_protocol_used = false
			var key := card.data.resource_path
			if not construct_post.has(key):
				construct_post[key] = []
			construct_post[key].append(card.construct_charge)
	for card: UnitCard in player_bench.units:
		if is_instance_valid(card) and card.data != null \
				and card.data.race == RaceType.Race.CONSTRUCT:
			card.construct_depowered = false
			card.construct_reignited = false
			card.construct_protocol_used = false
	# Accumulator: +3 persistent charge at end of each round
	for card: UnitCard in player_board.units + player_bench.units:
		if is_instance_valid(card) and card.data != null \
				and card.data.race == RaceType.Race.CONSTRUCT \
				and card.data.construct_effect == ConstructEffect.Effect.ACCUMULATOR:
			var acc_gain := 6 if card.is_radiant else 3
			card.construct_charge += acc_gain
			card.refresh_display()
			print("%s Accumulator: +%d persistent Charge (now %d)!" % [card.data.display_name, acc_gain, card.construct_charge])
	# Update board template so rebuilt cards inherit post-combat charge
	var path_idx: Dictionary = {}
	for entry in _board_template:
		var d: UnitData = entry.get("data")
		if d == null or d.race != RaceType.Race.CONSTRUCT:
			entry["construct_charge"] = 0
			continue
		var key: String = d.resource_path
		var idx: int = int(path_idx.get(key, 0))
		path_idx[key] = idx + 1
		if construct_post.has(key) and idx < (construct_post[key] as Array).size():
			entry["construct_charge"] = (construct_post[key] as Array)[idx]
		else:
			entry["construct_charge"] = 0

	# Post-combat Myconid spore persistence
	if _myconid_shop_data != null:
		if damage > 0:
			# Loss: last Myconid keeps 75% of its spores
			var kept: int = int(combat_manager._last_myconid_spores * 0.75)
			if combat_manager._last_myconid_is_parasite:
				_myconid_shop_data.spore_pool += kept
			else:
				# Find matching template entry and set its spores
				for entry in _board_template:
					var d: UnitData = entry.get("data")
					if d != null and d.resource_path == combat_manager._last_myconid_path:
						entry["myconid_spores"] = kept
						break
				# All other Myconid template entries lose their spores (transferred mid-combat)
				for entry in _board_template:
					var d: UnitData = entry.get("data")
					if d == null or d.race != RaceType.Race.MYCONID:
						continue
					if d.resource_path != combat_manager._last_myconid_path:
						entry["myconid_spores"] = 0
		else:
			# Win/Draw: collect surviving unit spore counts
			var myco_post: Dictionary = {}  # path → Array[int]
			for card: UnitCard in player_board.units:
				if not is_instance_valid(card) or card.is_dead or card.data == null:
					continue
				if card.data.race != RaceType.Race.MYCONID:
					continue
				if card.data.myconid_effect == MyconidEffect.Effect.PARASITE:
					_myconid_shop_data.spore_pool += card.myconid_spores
				else:
					var path := card.data.resource_path
					if not myco_post.has(path):
						myco_post[path] = []
					myco_post[path].append(card.myconid_spores)
			# Update template entries
			var myco_path_idx: Dictionary = {}
			for entry in _board_template:
				var d: UnitData = entry.get("data")
				if d == null or d.race != RaceType.Race.MYCONID \
						or d.myconid_effect == MyconidEffect.Effect.PARASITE:
					continue
				var path: String = d.resource_path
				var idx: int = int(myco_path_idx.get(path, 0))
				myco_path_idx[path] = idx + 1
				if myco_post.has(path) and idx < (myco_post[path] as Array).size():
					entry["myconid_spores"] = (myco_post[path] as Array)[idx]
				else:
					entry["myconid_spores"] = 0

	# Roll back combat-only buffs (Overload Core etc.) and sync permanent gains to template
	for card: UnitCard in player_board.units:
		if not is_instance_valid(card) or card.is_dead or card.data == null:
			continue
		if card.combat_temp_atk != 0 or card.combat_temp_hp != 0:
			card.current_attack = maxi(1, card.current_attack - card.combat_temp_atk)
			card.current_health = maxi(1, card.current_health - card.combat_temp_hp)
			card.combat_temp_atk = 0
			card.combat_temp_hp = 0
			card.refresh_display()
	for entry in _board_template:
		var ref = entry.get("card_ref")
		if ref == null or not is_instance_valid(ref):
			continue
		var ref_card: UnitCard = ref as UnitCard
		if ref_card.is_dead:
			continue
		var gain: Vector2i = combat_manager.pending_permanent_stats.get(ref_card, Vector2i(0, 0))
		if gain.x != 0 or gain.y != 0:
			entry["atk"] = int(entry["atk"]) + gain.x
			entry["hp"] = int(entry["hp"]) + gain.y

	# Apply pending rewards from death knells that fire during combat
	if combat_manager.pending_gold_reward > 0:
		_gold += combat_manager.pending_gold_reward
		print("Coin Sage / Jade Gatherer: +%d gold!" % combat_manager.pending_gold_reward)
	if combat_manager.pending_hsp_bonus > 0:
		_hsp += combat_manager.pending_hsp_bonus
		print("Warden: HSP permanently +%d!" % combat_manager.pending_hsp_bonus)

	if damage <= 0:
		# Victory after battle 25 (round index 24 because round increments post-discovery)
		if _round == GameData.MAX_BATTLES - 1:
			_save_resources()
			_update_resource_bar()
			_show_victory_screen()
			return
		_save_resources()
		_update_resource_bar()
		_sync_to_slot()
		return
	_player_hp -= damage
	_save_resources()
	_update_resource_bar()
	_sync_to_slot()
	if _player_hp <= 0:
		result_banner.text = "GAME OVER  (HP: %d)" % _player_hp
		continue_button.visible = false
		GameData.add_history({
			"result": "defeat",
			"battles": _round + 1,
			"date": Time.get_date_string_from_system(),
			"unit_names": _collect_board_unit_names(),
		})
		if GameData.current_slot >= 0:
			GameData.clear_slot(GameData.current_slot)


# ── Slot bridge ───────────────────────────────────────────────────────────────

func _collect_board_unit_names() -> Array:
	var names: Array = []
	for card: UnitCard in player_board.units:
		if is_instance_valid(card) and card.data != null:
			names.append(card.data.display_name)
	return names


func _collect_slot_data() -> Dictionary:
	var board_dicts: Array = []
	for card: UnitCard in player_board.units:
		if is_instance_valid(card) and card.data != null:
			board_dicts.append(_card_to_dict(card))
	var bench_dicts: Array = []
	for card: UnitCard in player_bench.units:
		if is_instance_valid(card) and card.data != null:
			bench_dicts.append(_card_to_dict(card))
	return {
		"round": _round,
		"gold": _gold,
		"gold_income": _gold_income,
		"lifetime_gold": _lifetime_gold,
		"tier": _player_tier,
		"player_hp": _player_hp,
		"asp": _asp,
		"hsp": _hsp,
		"sell_counter": _sell_counter,
		"support_unlocked": _support_slot_unlocked,
		"support_card": _card_to_dict(_support_card) if _support_card != null else {},
		"board": board_dicts,
		"bench": bench_dicts,
		"unit_names": board_dicts.map(func(d):
			var ud = load(d.get("path", ""))
			return ud.display_name if ud != null else "?"),
		"active_factions": _active_factions,
		"goblin_shop":    _goblin_shop_data.to_dict()   if _goblin_shop_data   != null else {},
		"elf_shop":       _elf_shop_data.to_dict()      if _elf_shop_data      != null else {},
		"covenant_shop":  _covenant_shop_data.to_dict() if _covenant_shop_data != null else {},
		"aztec_shop":     _aztec_shop_data.to_dict()    if _aztec_shop_data    != null else {},
		"aztec_tribute_used":   _aztec_tribute_used,
		"aztec_sacrifice_used": _aztec_sacrifice_used,
		"construct_shop": _construct_shop_data.to_dict() if _construct_shop_data != null else {},
		"reaper_shop":    _reaper_shop_data.to_dict()   if _reaper_shop_data   != null else {},
		"myconid_shop":   _myconid_shop_data.to_dict()  if _myconid_shop_data  != null else {},
		"satyr_shop":     _satyr_shop_data.to_dict()    if _satyr_shop_data    != null else {},
	}


func _write_slot_to_files(slot: Dictionary) -> void:
	var f: FileAccess
	f = FileAccess.open(ORDER_SAVE_PATH, FileAccess.WRITE)
	if f:
		f.store_string(JSON.stringify(slot.get("board", [])))
		f.close()
	f = FileAccess.open(BENCH_SAVE_PATH, FileAccess.WRITE)
	if f:
		f.store_string(JSON.stringify(slot.get("bench", [])))
		f.close()
	f = FileAccess.open(ROUND_SAVE_PATH, FileAccess.WRITE)
	if f:
		f.store_string(JSON.stringify(slot.get("round", 0)))
		f.close()
	f = FileAccess.open(SELL_COUNTER_SAVE_PATH, FileAccess.WRITE)
	if f:
		f.store_string(JSON.stringify(slot.get("sell_counter", 0)))
		f.close()
	f = FileAccess.open(FACTIONS_SAVE_PATH, FileAccess.WRITE)
	if f:
		f.store_string(JSON.stringify(slot.get("active_factions", [])))
		f.close()
	var res := {
		"gold": slot.get("gold", 0),
		"gold_income": slot.get("gold_income", 2),
		"lifetime_gold": slot.get("lifetime_gold", 0),
		"tier": slot.get("tier", 1),
		"player_hp": slot.get("player_hp", 100),
		"asp": slot.get("asp", 1),
		"hsp": slot.get("hsp", 1),
		"support_unlocked": slot.get("support_unlocked", false),
		"support_card": slot.get("support_card", {}),
		"goblin_shop":    slot.get("goblin_shop", {}),
		"elf_shop":       slot.get("elf_shop", {}),
		"covenant_shop":  slot.get("covenant_shop", {}),
		"aztec_shop":     slot.get("aztec_shop", {}),
		"aztec_tribute_used":   slot.get("aztec_tribute_used", false),
		"aztec_sacrifice_used": slot.get("aztec_sacrifice_used", false),
		"construct_shop": slot.get("construct_shop", {}),
		"reaper_shop":    slot.get("reaper_shop", {}),
		"myconid_shop":   slot.get("myconid_shop", {}),
		"satyr_shop":     slot.get("satyr_shop", {}),
	}
	f = FileAccess.open(RESOURCES_SAVE_PATH, FileAccess.WRITE)
	if f:
		f.store_string(JSON.stringify(res))
		f.close()


func _sync_to_slot() -> void:
	if GameData.current_slot < 0 or GameData.gauntlet_mode:
		return
	GameData.set_slot(GameData.current_slot, _collect_slot_data())


func _return_to_menu() -> void:
	_sync_to_slot()
	GameData.gauntlet_mode = false
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")


# ── Victory screen ────────────────────────────────────────────────────────────

func _show_victory_screen() -> void:
	var slot_data := _collect_slot_data()
	GameData.record_winning_run(slot_data)
	GameData.unlock_next_difficulty()
	GameData.add_history({
		"result": "victory",
		"battles": GameData.MAX_BATTLES,
		"date": Time.get_date_string_from_system(),
		"unit_names": slot_data.get("unit_names", []),
	})
	if GameData.current_slot >= 0:
		GameData.clear_slot(GameData.current_slot)

	var overlay := ColorRect.new()
	overlay.color = Color(0.04, 0.04, 0.08, 0.92)
	overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	overlay.z_index = 150
	overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(overlay)

	var center := VBoxContainer.new()
	center.set_anchors_preset(Control.PRESET_CENTER)
	center.add_theme_constant_override("separation", 18)
	center.z_index = 151
	add_child(center)

	var title_lbl := Label.new()
	title_lbl.text = "VICTORY!"
	title_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_lbl.add_theme_font_size_override("font_size", 64)
	title_lbl.add_theme_color_override("font_color", Color(1.0, 0.85, 0.20))
	center.add_child(title_lbl)

	var sub_lbl := Label.new()
	sub_lbl.text = "You survived all %d battles!" % GameData.MAX_BATTLES
	sub_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	sub_lbl.add_theme_font_size_override("font_size", 20)
	sub_lbl.add_theme_color_override("font_color", Color(0.85, 0.85, 0.95))
	center.add_child(sub_lbl)

	var units_lbl := Label.new()
	units_lbl.text = "Your board: " + ", ".join(slot_data.get("unit_names", []))
	units_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	units_lbl.add_theme_color_override("font_color", Color(0.65, 0.85, 0.65))
	units_lbl.add_theme_font_size_override("font_size", 14)
	center.add_child(units_lbl)

	center.add_child(HSeparator.new())

	var btns := HBoxContainer.new()
	btns.alignment = BoxContainer.ALIGNMENT_CENTER
	btns.add_theme_constant_override("separation", 16)
	center.add_child(btns)

	if GameData.has_gauntlet_data():
		var gauntlet_btn := Button.new()
		gauntlet_btn.text = "Challenge Gauntlet"
		gauntlet_btn.custom_minimum_size = Vector2(220, 48)
		gauntlet_btn.add_theme_color_override("font_color", Color(1.0, 0.80, 0.20))
		gauntlet_btn.pressed.connect(func():
			GameData.begin_gauntlet(slot_data)
			GameData.current_slot = -1
			get_tree().change_scene_to_file("res://scenes/combat_arena.tscn"))
		btns.add_child(gauntlet_btn)

	var menu_btn := Button.new()
	menu_btn.text = "Return to Menu"
	menu_btn.custom_minimum_size = Vector2(180, 48)
	menu_btn.pressed.connect(func():
		GameData.gauntlet_mode = false
		get_tree().change_scene_to_file("res://scenes/main_menu.tscn"))
	btns.add_child(menu_btn)


# ── Gauntlet mode ─────────────────────────────────────────────────────────────

func _enter_gauntlet_mode() -> void:
	# Hide interactive UI elements that don't apply in gauntlet
	_all_shops_btn.visible = false
	if tier_upgrade_button:
		tier_upgrade_button.visible = false
	fight_button.visible = false
	continue_button.visible = false

	# Restore player board from gauntlet_player_slot (full shop data too)
	_write_slot_to_files(GameData.gauntlet_player_slot)
	_load_resources()
	_active_factions = (GameData.gauntlet_player_slot.get("active_factions", []) as Array).map(
		func(v): return int(v))
	player_board.clear_units()
	for d in GameData.gauntlet_player_slot.get("board", []):
		var card: UnitCard = UnitCardScene.instantiate()
		player_board.add_unit(card)
		_apply_card_entry(card, d)

	_reload_gauntlet_enemy()
	_show_gauntlet_fight_start()


func _reload_gauntlet_enemy() -> void:
	enemy_board.clear_units()
	for d in GameData.get_gauntlet_opponent_board():
		var card: UnitCard = UnitCardScene.instantiate()
		enemy_board.add_unit(card)
		_apply_enemy_card_dict(card, d)
	_load_enemy_shops_from_slot(GameData.get_gauntlet_opponent_slot())


func _load_enemy_shops_from_slot(slot: Dictionary) -> void:
	var gs = slot.get("goblin_shop", {})
	if gs is Dictionary and not gs.is_empty():
		_enemy_goblin_shop_data = GoblinShopData.new()
		_enemy_goblin_shop_data.from_dict(gs)
	else:
		_enemy_goblin_shop_data = GoblinShopData.new()
	var es = slot.get("elf_shop", {})
	if es is Dictionary and not es.is_empty():
		_enemy_elf_shop_data = ElfShopData.new()
		_enemy_elf_shop_data.from_dict(es)
	else:
		_enemy_elf_shop_data = ElfShopData.new()
	var cs = slot.get("covenant_shop", {})
	if cs is Dictionary and not cs.is_empty():
		_enemy_covenant_shop_data = CovenantShopData.new()
		_enemy_covenant_shop_data.from_dict(cs)
	else:
		_enemy_covenant_shop_data = CovenantShopData.new()
	var az = slot.get("aztec_shop", {})
	if az is Dictionary and not az.is_empty():
		_enemy_aztec_shop_data = AztecShopData.new()
		_enemy_aztec_shop_data.from_dict(az)
	else:
		_enemy_aztec_shop_data = AztecShopData.new()
	_enemy_aztec_gold = int(slot.get("gold", 0))
	var csd = slot.get("construct_shop", {})
	if csd is Dictionary and not csd.is_empty():
		_enemy_construct_shop_data = ConstructShopData.new()
		_enemy_construct_shop_data.from_dict(csd)
	else:
		_enemy_construct_shop_data = ConstructShopData.new()
	var rsd = slot.get("reaper_shop", {})
	if rsd is Dictionary and not rsd.is_empty():
		_enemy_reaper_shop_data = ReaperShopData.new()
		_enemy_reaper_shop_data.from_dict(rsd)
	else:
		_enemy_reaper_shop_data = ReaperShopData.new()
	var msd = slot.get("myconid_shop", {})
	if msd is Dictionary and not msd.is_empty():
		_enemy_myconid_shop_data = MyconidShopData.new()
		_enemy_myconid_shop_data.from_dict(msd)
	else:
		_enemy_myconid_shop_data = MyconidShopData.new()
	var ssd = slot.get("satyr_shop", {})
	if ssd is Dictionary and not ssd.is_empty():
		_enemy_satyr_shop_data = SatyrShopData.new()
		_enemy_satyr_shop_data.from_dict(ssd)
	else:
		_enemy_satyr_shop_data = SatyrShopData.new()


func _reload_gauntlet_boards() -> void:
	player_board.clear_units()
	for d in GameData.gauntlet_player_slot.get("board", []):
		var card: UnitCard = UnitCardScene.instantiate()
		player_board.add_unit(card)
		_apply_card_entry(card, d)
	_reload_gauntlet_enemy()


func _apply_enemy_card_dict(card: UnitCard, d: Dictionary) -> void:
	var path: String = d.get("path", "")
	var unit_data: UnitData = load(path)
	if unit_data == null:
		return
	card.initialize(unit_data)
	card.current_attack   = int(d.get("atk", unit_data.base_attack))
	card.current_health   = int(d.get("hp",  unit_data.base_health))
	card.current_keywords = int(d.get("kw",  unit_data.keywords))
	card.is_radiant       = bool(d.get("radiant", false))
	var wlevel := int(d.get("weapon_level", -1))
	if wlevel >= 0 and card.equipped_weapon != null:
		card.equipped_weapon.level = wlevel
	var btype  := int(d.get("backpack_type", -1))
	var blevel := int(d.get("backpack_level", -1))
	if btype >= 0 and WEAPON_TEMPLATES.has(btype):
		card.backpack_weapon = WEAPON_TEMPLATES[btype].duplicate()
		card.backpack_weapon.level = blevel
	var spell_path: String = d.get("spell_path", "")
	if spell_path != "":
		var sd: SpellData = load(spell_path)
		if sd != null:
			card.equipped_spell = SpellInstance.new(sd)
			var trig_dict = d.get("spell_triggers", {})
			if trig_dict is Dictionary:
				for k in trig_dict:
					card.equipped_spell.triggers[int(k)] = int(trig_dict[k])
	card.construct_charge = int(d.get("construct_charge", 0))
	card.myconid_spores   = int(d.get("myconid_spores",   0))
	card.refresh_display()


func _show_gauntlet_fight_start() -> void:
	var stage_name := "Last Winning Board" if GameData.gauntlet_stage == 0 else "Champion Board"
	var opp_names: Array = []
	for d in GameData.get_gauntlet_opponent_board():
		if d is Dictionary:
			var ud = load(d.get("path", ""))
			if ud != null:
				opp_names.append(ud.display_name)

	var overlay := _gauntlet_info_overlay(
		"GAUNTLET  —  Stage %d of %d" % [GameData.gauntlet_stage + 1, 2 if GameData.has_champion() else 1],
		"vs  %s\n%s\n\nBest of 3  ·  Score: %d – %d" % [
			stage_name,
			", ".join(opp_names),
			GameData.gauntlet_player_wins, GameData.gauntlet_enemy_wins],
		"Start Fight",
		func():
			fight_button.visible = true
			player_board.is_locked = false)
	add_child(overlay)


func _on_gauntlet_fight_ended(player_won: bool) -> void:
	player_board.is_locked = true
	fight_button.visible   = false

	if player_won:
		GameData.gauntlet_player_wins += 1
	else:
		GameData.gauntlet_enemy_wins += 1

	var p := GameData.gauntlet_player_wins
	var e := GameData.gauntlet_enemy_wins
	var stage_decided := p >= 2 or e >= 2

	if not stage_decided:
		# Another fight needed — reload boards and show score
		_reload_gauntlet_boards()
		var overlay := _gauntlet_info_overlay(
			"Fight result: %s" % ("YOU WIN" if player_won else "YOU LOSE"),
			"Score: %d – %d  (first to 2 wins the stage)" % [p, e],
			"Next Fight",
			func():
				fight_button.visible = true
				player_board.is_locked = false)
		add_child(overlay)
		return

	# Stage decided
	if not player_won or e >= 2:
		# Player lost the stage → gauntlet over
		_show_gauntlet_end(false)
		return

	# Player won the stage
	if GameData.gauntlet_stage == 0:
		if GameData.has_champion():
			# Advance to stage 2 vs champion
			GameData.gauntlet_stage       = 1
			GameData.gauntlet_player_wins = 0
			GameData.gauntlet_enemy_wins  = 0
			_reload_gauntlet_boards()
			var overlay := _gauntlet_info_overlay(
				"Stage 1 Clear!",
				"You defeated the Last Winning Board.\nNow face the Champion!",
				"Continue to Stage 2",
				func():
					fight_button.visible = true
					player_board.is_locked = false)
			add_child(overlay)
		else:
			# No champion yet — player IS the new champion
			GameData.record_champion(GameData.gauntlet_player_slot)
			_show_gauntlet_end(true)
	else:
		# Player won stage 2 — new champion!
		GameData.record_champion(GameData.gauntlet_player_slot)
		_show_gauntlet_end(true)


func _show_gauntlet_end(player_won: bool) -> void:
	var title := "NEW CHAMPION!" if player_won else "GAUNTLET FAILED"
	var msg   := ("Your board has been recorded as the new Champion!" if player_won
		else "Better luck next time.")
	var overlay := _gauntlet_info_overlay(title, msg, "Return to Menu",
		func(): get_tree().change_scene_to_file("res://scenes/main_menu.tscn"))
	add_child(overlay)


func _gauntlet_info_overlay(title: String, body: String,
		btn_label: String, on_btn: Callable) -> Control:
	var overlay := ColorRect.new()
	overlay.color = Color(0.04, 0.04, 0.08, 0.88)
	overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	overlay.z_index = 160
	overlay.mouse_filter = Control.MOUSE_FILTER_STOP

	var vb := VBoxContainer.new()
	vb.set_anchors_preset(Control.PRESET_CENTER)
	vb.add_theme_constant_override("separation", 16)
	vb.z_index = 161
	overlay.add_child(vb)

	var t := Label.new()
	t.text = title
	t.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	t.add_theme_font_size_override("font_size", 32)
	t.add_theme_color_override("font_color", Color(1.0, 0.85, 0.20))
	vb.add_child(t)

	var b := Label.new()
	b.text = body
	b.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	b.add_theme_font_size_override("font_size", 15)
	b.add_theme_color_override("font_color", Color(0.85, 0.85, 0.95))
	b.autowrap_mode = TextServer.AUTOWRAP_WORD
	b.custom_minimum_size = Vector2(480, 0)
	vb.add_child(b)

	var btn := Button.new()
	btn.text = btn_label
	btn.custom_minimum_size = Vector2(200, 48)
	btn.pressed.connect(func():
		overlay.queue_free()
		on_btn.call())
	vb.add_child(btn)

	return overlay


# ── Drag handling ─────────────────────────────────────────────────────────────

func _input(event: InputEvent) -> void:
	# Full-screen overlays block everything while open
	if _spell_shop.visible:
		return
	if _goblin_shop != null and _goblin_shop.visible:
		return
	if _aztec_shop != null and _aztec_shop.visible:
		return
	if _all_shops_panel != null and _all_shops_panel.visible:
		return
	if _construct_shop != null and _construct_shop.visible:
		return
	if _reaper_shop != null and _reaper_shop.visible:
		return
	if _myconid_shop != null and _myconid_shop.visible:
		return
	if _spell_discovery_panel != null and _spell_discovery_panel.visible:
		return

	# Overlays handle their own closing; block all other input while open
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if _human_shop.visible or _mage_shop.visible:
			return

	if _targeting_callback.is_valid():
		if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			var card := _get_card_at_pos(event.global_position)
			if card != null and card in _targeting_valid:
				_on_targeting_pick(card)
			else:
				_cancel_targeting()
			get_viewport().set_input_as_handled()
		return

	if player_board.is_locked:
		return

	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			_try_start_drag(event.global_position)
		else:
			_end_drag(event.global_position)
	elif event is InputEventMouseMotion and _drag_card != null:
		_drag_card.global_position = event.global_position - _drag_card_size * 0.5


func _try_start_drag(pos: Vector2) -> void:
	var card := player_board.get_unit_at_screen_pos(pos)
	var origin = player_board
	if card == null:
		card = player_bench.get_unit_at_screen_pos(pos)
		origin = player_bench
	if card == null and _support_card != null and is_instance_valid(_support_card):
		if Rect2(_support_card.global_position, _support_card.size).has_point(pos):
			card = _support_card
			origin = null
	if card == null:
		_close_weapon_menu()
		return

	# Top-right 26×34 area = weapon button for Humans, mage button for Mages
	var top_right := Rect2(card.global_position + Vector2(card.size.x - 26, 0), Vector2(26, 34))
	if card.data.race == RaceType.Race.HUMAN:
		if top_right.has_point(pos):
			_open_weapon_menu(card)
			get_viewport().set_input_as_handled()
			return
	if card.data.race == RaceType.Race.MAGE:
		if top_right.has_point(pos):
			_open_mage_shop(card)
			return
	if card.data.race == RaceType.Race.GOBLIN:
		if top_right.has_point(pos):
			if card.data.goblin_effect == GoblinEffect.Effect.WITCH_DOCTOR_BLESS:
				_open_witch_doctor_picker(card)
			else:
				_open_goblin_shop()
			return
	if card.data.race == RaceType.Race.ELF:
		if top_right.has_point(pos):
			_open_elf_shop()
			return
	if card.data.race == RaceType.Race.COVENANT:
		if top_right.has_point(pos):
			_open_covenant_shop()
			return
	if card.data.race == RaceType.Race.AZTEC:
		if top_right.has_point(pos):
			_open_aztec_shop()
			return
	if card.data.race == RaceType.Race.CONSTRUCT:
		if top_right.has_point(pos):
			_open_construct_shop()
			return
	if card.data.race == RaceType.Race.REAPER:
		if top_right.has_point(pos):
			_open_reaper_shop()
			return
	if card.data.race == RaceType.Race.MYCONID:
		if top_right.has_point(pos):
			_open_myconid_shop()
			return

	_drag_from_support = (origin == null)
	if _drag_from_support:
		_support_card = null
		if _support_empty_label != null:
			_support_empty_label.visible = _support_slot_unlocked

	_drag_card = card
	_drag_card_size = card.size
	_drag_origin_container = origin
	_drag_origin_idx = -1 if origin == null else origin.units.find(card)
	_drag_origin_visual_idx = -1 if origin == null else origin.slots_container.get_children().find(card)

	var gpos := card.global_position
	card.get_parent().remove_child(card)
	add_child(card)
	card.size = _drag_card_size
	card.global_position = gpos
	card.z_index = 10
	card.set_lifted(true)


func _end_drag(pos: Vector2) -> void:
	if _drag_card == null:
		return

	remove_child(_drag_card)
	_drag_card.z_index = 0
	_drag_card.set_lifted(false)

	# Sell zone check
	if Rect2(sell_zone.global_position, sell_zone.size).has_point(pos):
		if _drag_origin_container != null:
			_drag_origin_container.units.erase(_drag_card)
		var sold := _drag_card
		_drag_card.queue_free()
		_drag_card = null
		_drag_origin_idx = -1
		_drag_origin_visual_idx = -1
		_drag_origin_container = null
		_drag_from_support = false
		_handle_sell(sold)
		_update_support_slot_ui()
		return

	# Support slot drop
	if _support_slot_unlocked and _support_card == null and _support_slot_panel != null:
		if Rect2(_support_slot_panel.global_position, _support_slot_panel.size).has_point(pos):
			if _drag_origin_container != null:
				_drag_origin_container.units.erase(_drag_card)
			var dropped := _drag_card
			var came_from_bench_support: bool = _drag_origin_container == player_bench
			_drag_card = null
			_drag_origin_idx = -1
			_drag_origin_visual_idx = -1
			_drag_origin_container = null
			_drag_from_support = false
			_place_support_card(dropped)
			_save_bench()
			_save_player_order()
			_check_for_triples()
			_update_support_slot_ui()
			if came_from_bench_support:
				_fire_surge(dropped)
			return

	# Determine drop target
	var target = _drag_origin_container
	var came_from_bench: bool = _drag_origin_container == player_bench

	if Rect2(player_board.global_position, player_board.size).has_point(pos):
		if _drag_origin_container == player_board:
			target = player_board
		elif player_board.units.size() < 7:
			target = player_board
	elif player_bench.contains_screen_point(pos):
		if _drag_origin_container == player_bench:
			target = player_bench

	# Support card with no valid target: put it back in the slot
	if _drag_from_support and target == null:
		var dropped := _drag_card
		_drag_card = null
		_drag_origin_idx = -1
		_drag_origin_visual_idx = -1
		_drag_origin_container = null
		_drag_from_support = false
		_place_support_card(dropped)
		_update_support_slot_ui()
		return

	_drag_from_support = false

	if _drag_origin_container != null:
		_drag_origin_container.units.erase(_drag_card)

	var unit_idx: int
	var visual_idx: int
	if target == _drag_origin_container and \
			not Rect2(player_board.global_position, player_board.size).has_point(pos) and \
			not player_bench.contains_screen_point(pos):
		unit_idx = _drag_origin_idx
		visual_idx = _drag_origin_visual_idx
	else:
		visual_idx = target.get_insert_index_for_x(pos.x)
		unit_idx = target.get_unit_insert_idx_for_visual_idx(visual_idx)

	target.units.insert(unit_idx, _drag_card)
	target.slots_container.add_child(_drag_card)
	target.slots_container.move_child(_drag_card, visual_idx)

	_save_player_order()
	_save_bench()

	var placed_card := _drag_card
	var moved_to_board: bool = came_from_bench and target == player_board
	_drag_card = null
	_drag_origin_idx = -1
	_drag_origin_visual_idx = -1
	_drag_origin_container = null

	if moved_to_board:
		_fire_surge(placed_card)

	_check_for_triples()
	_update_support_slot_ui()


# ── Keyboard shortcuts ────────────────────────────────────────────────────────

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_SPACE and not combat_manager.is_running:
			_on_fight_pressed()
		elif event.keycode == KEY_R and not combat_manager.is_running:
			_on_continue_pressed()


func _on_fight_pressed() -> void:
	print("=== FIGHT pressed ===")
	_board_template = []
	for card: UnitCard in player_board.units:
		if is_instance_valid(card) and card.data != null:
			_board_template.append({
				"data": card.data,
				"atk": card.current_attack,
				"hp": card.current_health,
				"kw": card.current_keywords,
				"radiant": card.is_radiant,
				"equipped_weapon": card.equipped_weapon,
				"backpack_weapon": card.backpack_weapon,
				"equipped_spell": card.equipped_spell,
				"construct_charge": card.construct_charge,
				"myconid_spores": card.myconid_spores,
				"card_ref": card,
			})
	player_board.is_locked = true
	var active_spells: Array = []
	for card: UnitCard in player_board.units:
		if is_instance_valid(card) and card.data != null:
			if card.data.race == RaceType.Race.MAGE and card.equipped_spell != null:
				active_spells.append(card.equipped_spell)
	if _support_card != null and is_instance_valid(_support_card) and _support_card.data != null \
			and _support_card.data.race == RaceType.Race.MAGE \
			and _support_card.equipped_spell != null:
		active_spells.append(_support_card.equipped_spell)
	combat_manager.active_spells = active_spells
	combat_manager.asp = _asp
	combat_manager.hsp = _hsp
	combat_manager.support_card = _support_card
	combat_manager.goblin_shop_data = _goblin_shop_data
	combat_manager.elf_shop_data = _elf_shop_data
	combat_manager.covenant_shop_data = _covenant_shop_data
	combat_manager.aztec_shop_data = _aztec_shop_data
	combat_manager.aztec_gold = _gold
	combat_manager.aztec_player_hp = _player_hp
	combat_manager.aztec_bench_count = player_bench.units.filter(func(u): return is_instance_valid(u) and u.data != null).size()
	combat_manager.construct_shop_data = _construct_shop_data
	combat_manager.reaper_shop_data = _reaper_shop_data
	combat_manager.myconid_shop_data = _myconid_shop_data
	combat_manager.satyr_shop_data = _satyr_shop_data
	combat_manager.enemy_goblin_shop_data = _enemy_goblin_shop_data
	combat_manager.enemy_elf_shop_data = _enemy_elf_shop_data
	combat_manager.enemy_covenant_shop_data = _enemy_covenant_shop_data
	combat_manager.enemy_aztec_shop_data = _enemy_aztec_shop_data
	combat_manager.enemy_aztec_gold = _enemy_aztec_gold
	combat_manager.enemy_construct_shop_data = _enemy_construct_shop_data
	combat_manager.enemy_reaper_shop_data = _enemy_reaper_shop_data
	combat_manager.enemy_myconid_shop_data = _enemy_myconid_shop_data
	combat_manager.enemy_satyr_shop_data = _enemy_satyr_shop_data
	combat_manager.start_combat()
