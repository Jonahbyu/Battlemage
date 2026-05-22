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
	preload("res://resources/units/mages/coin_sage.tres"),
	preload("res://resources/units/mages/harrower.tres"),
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
	# Elves
	preload("res://resources/units/elves/elf_scout.tres"),
	# Covenant
	preload("res://resources/units/covenant/covenant_initiate.tres"),
]

var _rerolls_left: int = 3
var _current_tier: int = 1
var _race_filter: int = RaceType.Race.NONE

@onready var cards_container: HBoxContainer = $CenterVBox/CardsContainer
@onready var reroll_button: Button = $CenterVBox/BottomRow/RerollButton
@onready var rerolls_label: Label = $CenterVBox/BottomRow/RerollsLabel


func activate(tier: int = 1) -> void:
	_current_tier = tier
	_race_filter = RaceType.Race.NONE
	visible = true
	_rerolls_left = 3
	_deal_cards()


func activate_filtered(tier: int, race: int) -> void:
	_current_tier = tier
	_race_filter = race
	visible = true
	_rerolls_left = 3
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
	match tier:
		1: return 3
		2: return 5
		3: return 7
		_: return 9


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
