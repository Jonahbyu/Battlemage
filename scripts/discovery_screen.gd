class_name DiscoveryScreen
extends Control

signal unit_chosen(unit_data: UnitData)

const UnitCardScene := preload("res://scenes/unit_card.tscn")

const ALL_UNITS := [
	# Tier 1
	preload("res://resources/units/footman.tres"),
	preload("res://resources/units/viper.tres"),
	preload("res://resources/units/warrior.tres"),
	preload("res://resources/units/humans/grunt.tres"),
	preload("res://resources/units/humans/gunslinger.tres"),
	preload("res://resources/units/humans/recruit.tres"),
	preload("res://resources/units/mages/novice.tres"),
	preload("res://resources/units/mages/acolyte.tres"),
	preload("res://resources/units/mages/familiar.tres"),
	# Tier 2
	preload("res://resources/units/defender.tres"),
	preload("res://resources/units/humans/sharpshooter.tres"),
	preload("res://resources/units/humans/arms_dealer.tres"),
	preload("res://resources/units/humans/brawler.tres"),
	preload("res://resources/units/humans/demolitionist.tres"),
	preload("res://resources/units/humans/gunner.tres"),
	preload("res://resources/units/humans/commander.tres"),
	preload("res://resources/units/mages/runecaller.tres"),
	preload("res://resources/units/mages/amplifier.tres"),
	preload("res://resources/units/mages/coin_sage.tres"),
	preload("res://resources/units/mages/harrower.tres"),
	preload("res://resources/units/mages/oracle.tres"),
	preload("res://resources/units/mages/spellbinder.tres"),
	preload("res://resources/units/mages/spellwright.tres"),
	preload("res://resources/units/mages/warden.tres"),
	# Tier 3
	preload("res://resources/units/harvest_golem.tres"),
	preload("res://resources/units/mages/arcane_conduit.tres"),
	preload("res://resources/units/mages/wellspring.tres"),
	preload("res://resources/units/mages/hexweaver.tres"),
	preload("res://resources/units/mages/echo_caster.tres"),
	preload("res://resources/units/mages/runic_scribe.tres"),
	preload("res://resources/units/humans/quartermaster.tres"),
	# Tier 4
	preload("res://resources/units/mages/arcanist.tres"),
	preload("res://resources/units/mages/channeler.tres"),
	preload("res://resources/units/mages/warchanter.tres"),
	preload("res://resources/units/humans/warlord.tres"),
	preload("res://resources/units/humans/duelist.tres"),
	preload("res://resources/units/grave_conductor.tres"),
	preload("res://resources/units/surge_master.tres"),
	preload("res://resources/units/humans/breacher.tres"),
	preload("res://resources/units/humans/ranger.tres"),
	preload("res://resources/units/humans/heavy.tres"),
	# Goblins
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
	# Myconids
	preload("res://resources/units/myconids/sporekeeper.tres"),
	preload("res://resources/units/myconids/sporeling.tres"),
	preload("res://resources/units/myconids/parasite.tres"),
	preload("res://resources/units/myconids/myco_cap.tres"),
	preload("res://resources/units/myconids/bloom.tres"),
	preload("res://resources/units/myconids/spore_vent.tres"),
	preload("res://resources/units/myconids/mycelium.tres"),
	preload("res://resources/units/myconids/decomposer.tres"),
	preload("res://resources/units/myconids/hyphae.tres"),
	preload("res://resources/units/myconids/sporefront.tres"),
	preload("res://resources/units/myconids/spore_hoarder.tres"),
	preload("res://resources/units/myconids/sporeguard.tres"),
	preload("res://resources/units/myconids/myco_sage.tres"),
	preload("res://resources/units/myconids/cultivator.tres"),
	preload("res://resources/units/myconids/spore_sovereign.tres"),
	preload("res://resources/units/myconids/fungal_ascendant.tres"),
	# Constructs
	preload("res://resources/units/constructs/winder.tres"),
	preload("res://resources/units/constructs/capacitor.tres"),
	preload("res://resources/units/constructs/reigniter.tres"),
	preload("res://resources/units/constructs/volt_striker.tres"),
	preload("res://resources/units/constructs/accumulator.tres"),
	preload("res://resources/units/constructs/arc_coil.tres"),
	preload("res://resources/units/constructs/coil_weaver.tres"),
	preload("res://resources/units/constructs/discharge_engine.tres"),
	preload("res://resources/units/constructs/iron_sentinel.tres"),
	preload("res://resources/units/constructs/charge_siphon.tres"),
	preload("res://resources/units/constructs/meltdown.tres"),
	preload("res://resources/units/constructs/overload_core.tres"),
	preload("res://resources/units/constructs/relay_node.tres"),
	preload("res://resources/units/constructs/surge_conduit.tres"),
	preload("res://resources/units/constructs/fission_core.tres"),
	preload("res://resources/units/constructs/grand_capacitor.tres"),
	preload("res://resources/units/constructs/recharge_protocol.tres"),
	# Reapers
	preload("res://resources/units/reapers/gravewarden.tres"),
	preload("res://resources/units/reapers/wraith.tres"),
	preload("res://resources/units/reapers/pale_shroud.tres"),
	preload("res://resources/units/reapers/dread_knell.tres"),
	preload("res://resources/units/reapers/doom_herald.tres"),
	preload("res://resources/units/reapers/dread_seer.tres"),
	preload("res://resources/units/reapers/grave_stalker.tres"),
	preload("res://resources/units/reapers/pale_reaper.tres"),
	preload("res://resources/units/reapers/shade_stalker.tres"),
	preload("res://resources/units/reapers/void_wraith.tres"),
	preload("res://resources/units/reapers/dread_lord.tres"),
	preload("res://resources/units/reapers/grave_collector.tres"),
	preload("res://resources/units/reapers/rift_caller.tres"),
	preload("res://resources/units/reapers/soul_harvester.tres"),
	preload("res://resources/units/reapers/wail_specter.tres"),
	preload("res://resources/units/reapers/death_sovereign.tres"),
	preload("res://resources/units/reapers/grave_pact.tres"),
	# Satyrs
	preload("res://resources/units/satyrs/black_satyr.tres"),
	preload("res://resources/units/satyrs/crimson_satyr.tres"),
	preload("res://resources/units/satyrs/gold_satyr.tres"),
	preload("res://resources/units/satyrs/green_satyr.tres"),
	preload("res://resources/units/satyrs/silver_satyr.tres"),
	preload("res://resources/units/satyrs/crimson_revenant.tres"),
	preload("res://resources/units/satyrs/grove_caller.tres"),
	preload("res://resources/units/satyrs/moon_striker.tres"),
	preload("res://resources/units/satyrs/plague_sovereign.tres"),
	preload("res://resources/units/satyrs/surge_herald.tres"),
	preload("res://resources/units/satyrs/ancient_root.tres"),
	preload("res://resources/units/satyrs/gilded_balance.tres"),
	preload("res://resources/units/satyrs/lunar_surge.tres"),
	preload("res://resources/units/satyrs/pestilence.tres"),
	preload("res://resources/units/satyrs/twin_pyre.tres"),
	preload("res://resources/units/satyrs/auric_mirror.tres"),
	preload("res://resources/units/satyrs/blood_hunger.tres"),
	preload("res://resources/units/satyrs/dark_reveler.tres"),
	preload("res://resources/units/satyrs/eternal_grove.tres"),
	preload("res://resources/units/satyrs/pack_sovereign.tres"),
	preload("res://resources/units/satyrs/prismatic_reveler.tres"),
	# Elves
	preload("res://resources/units/elves/elf_scout.tres"),
	preload("res://resources/units/elves/duskblade.tres"),
	preload("res://resources/units/elves/thornguard.tres"),
	preload("res://resources/units/elves/fernweave.tres"),
	preload("res://resources/units/elves/moonsong.tres"),
	preload("res://resources/units/elves/soul_tender.tres"),
	preload("res://resources/units/elves/spiritbark.tres"),
	preload("res://resources/units/elves/verdant_archer.tres"),
	preload("res://resources/units/elves/ashveil.tres"),
	preload("res://resources/units/elves/dreamhunter.tres"),
	preload("res://resources/units/elves/pale_warden.tres"),
	preload("res://resources/units/elves/root_caller.tres"),
	preload("res://resources/units/elves/thornborn.tres"),
	preload("res://resources/units/elves/ancient_grove.tres"),
	preload("res://resources/units/elves/the_dreamer.tres"),
	# Covenant
	preload("res://resources/units/covenant/covenant_initiate.tres"),
	preload("res://resources/units/covenant/seeker.tres"),
	preload("res://resources/units/covenant/pact_kin.tres"),
	preload("res://resources/units/covenant/covenantling.tres"),
	preload("res://resources/units/covenant/fury_kin.tres"),
	preload("res://resources/units/covenant/weave_kin.tres"),
	preload("res://resources/units/covenant/oath_binder.tres"),
	preload("res://resources/units/covenant/bond_warden.tres"),
	preload("res://resources/units/covenant/martyr_kin.tres"),
	preload("res://resources/units/covenant/rite_herald.tres"),
	preload("res://resources/units/covenant/vow_guard.tres"),
	preload("res://resources/units/covenant/bond_shatter.tres"),
	preload("res://resources/units/covenant/rite_sage.tres"),
	preload("res://resources/units/covenant/soul_tether.tres"),
	preload("res://resources/units/covenant/chain_hunter.tres"),
	preload("res://resources/units/covenant/grief_kin.tres"),
	preload("res://resources/units/covenant/rite_spawner.tres"),
	# Aztecs
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
]

var _rerolls_left: int = 3
var _current_tier: int = 1
var _race_filter: int = RaceType.Race.NONE

@onready var cards_container: HBoxContainer = $CenterVBox/CardsContainer
@onready var reroll_button: Button = $CenterVBox/BottomRow/RerollButton
@onready var rerolls_label: Label = $CenterVBox/BottomRow/RerollsLabel


func activate(tier: int = 1, bonus_rerolls: int = 0) -> void:
	_current_tier = tier
	_race_filter = RaceType.Race.NONE
	visible = true
	_rerolls_left = GameData.discovery_rerolls + bonus_rerolls
	_deal_cards()


func activate_filtered(tier: int, race: int, bonus_rerolls: int = 0) -> void:
	_current_tier = tier
	_race_filter = race
	visible = true
	_rerolls_left = GameData.discovery_rerolls + bonus_rerolls
	_deal_cards()


func _deal_cards() -> void:
	for child in cards_container.get_children():
		child.queue_free()

	var pool: Array = ALL_UNITS.filter(func(u): return u.tier <= _current_tier)
	if _race_filter != RaceType.Race.NONE:
		pool = pool.filter(func(u): return u.race == _race_filter)
	pool.shuffle()

	var card_count := _cards_for_tier(_current_tier)
	for unit_data in pool.slice(0, mini(card_count, pool.size())):
		var card: UnitCard = UnitCardScene.instantiate()
		cards_container.add_child(card)
		card.initialize(unit_data)
		card.show_buy_button(true)
		card.buy_pressed.connect(_on_unit_card_buy_pressed)

	_refresh_ui()


func _cards_for_tier(tier: int) -> int:
	var base: int
	match tier:
		1: base = 3
		2: base = 5
		3: base = 7
		_: base = 9
	return maxi(1, base - GameData.discovery_reduction)


func _input(event: InputEvent) -> void:
	if not visible:
		return
	if not (event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed):
		return
	for child in cards_container.get_children():
		var card := child as UnitCard
		if card == null:
			continue
		if Rect2(card.global_position, card.size).has_point(event.global_position):
			visible = false
			unit_chosen.emit(card.data)
			return


func _on_unit_card_buy_pressed(card: UnitCard) -> void:
	if not visible:
		return
	visible = false
	unit_chosen.emit(card.data)


func _on_reroll_pressed() -> void:
	if _rerolls_left <= 0:
		return
	_rerolls_left -= 1
	_deal_cards()


func _refresh_ui() -> void:
	reroll_button.disabled = _rerolls_left <= 0
	rerolls_label.text = "Rerolls: %d" % _rerolls_left
