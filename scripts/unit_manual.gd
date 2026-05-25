class_name UnitManual
extends Control

# ── Faction data ──────────────────────────────────────────────────────────────

const FACTIONS := [
	"Human", "Goblin", "Mage", "Elf",
	"Aztec", "Myconid", "Reaper", "Covenant", "Satyr", "Construct", "Generic"
]

const FACTION_SHOP_NAMES := {
	"Human":    "Armory",
	"Goblin":   "Goblin Workshop",
	"Mage":     "Mage Shop",
	"Elf":      "Elven Echo Chamber",
	"Aztec":    "The Temple",
	"Myconid":  "The Grove",
	"Reaper":   "The Rift",
	"Covenant": "Covenant Blood Pact",
	"Satyr":    "The Sacred Grove",
	"Construct": "The Coilworks",
}

const FACTION_COLORS := {
	"Human":     Color(0.30, 0.14, 0.04),
	"Goblin":    Color(0.26, 0.24, 0.02),
	"Mage":      Color(0.08, 0.10, 0.44),
	"Elf":       Color(0.04, 0.24, 0.06),
	"Aztec":     Color(0.22, 0.14, 0.02),
	"Myconid":   Color(0.24, 0.04, 0.20),
	"Reaper":    Color(0.14, 0.04, 0.24),
	"Covenant":  Color(0.04, 0.22, 0.28),
	"Satyr":     Color(0.10, 0.18, 0.10),
	"Construct": Color(0.14, 0.18, 0.22),
	"Generic":   Color(0.18, 0.20, 0.28),
}

const FACTION_UNITS := {
	"Human": [
		preload("res://resources/units/humans/grunt.tres"),
		preload("res://resources/units/humans/gunslinger.tres"),
		preload("res://resources/units/humans/recruit.tres"),
		preload("res://resources/units/humans/arms_dealer.tres"),
		preload("res://resources/units/humans/sharpshooter.tres"),
		preload("res://resources/units/humans/demolitionist.tres"),
		preload("res://resources/units/humans/gunner.tres"),
		preload("res://resources/units/humans/brawler.tres"),
		preload("res://resources/units/humans/commander.tres"),
		preload("res://resources/units/humans/quartermaster.tres"),
		preload("res://resources/units/humans/breacher.tres"),
		preload("res://resources/units/humans/heavy.tres"),
		preload("res://resources/units/humans/ranger.tres"),
		preload("res://resources/units/humans/warlord.tres"),
		preload("res://resources/units/humans/duelist.tres"),
	],
	"Goblin": [
		preload("res://resources/units/goblins/mob_runt.tres"),
		preload("res://resources/units/goblins/grub_grabber.tres"),
		preload("res://resources/units/goblins/sneak.tres"),
		preload("res://resources/units/goblins/pack_leader.tres"),
		preload("res://resources/units/goblins/scrap_bomber.tres"),
		preload("res://resources/units/goblins/rabble_riser.tres"),
		preload("res://resources/units/goblins/reckoner.tres"),
		preload("res://resources/units/goblins/bomb_king.tres"),
		preload("res://resources/units/goblins/brood_witch.tres"),
		preload("res://resources/units/goblins/litter_lord.tres"),
		preload("res://resources/units/goblins/taskmaster.tres"),
		preload("res://resources/units/goblins/rage_brand.tres"),
		preload("res://resources/units/goblins/witch_doctor.tres"),
		preload("res://resources/units/goblins/warchief.tres"),
		preload("res://resources/units/goblins/chaos_caller.tres"),
	],
	"Mage": [
		preload("res://resources/units/mages/novice.tres"),
		preload("res://resources/units/mages/acolyte.tres"),
		preload("res://resources/units/mages/familiar.tres"),
		preload("res://resources/units/mages/runecaller.tres"),
		preload("res://resources/units/mages/spellwright.tres"),
		preload("res://resources/units/mages/coin_sage.tres"),
		preload("res://resources/units/mages/warden.tres"),
		preload("res://resources/units/mages/harrower.tres"),
		preload("res://resources/units/mages/arcane_conduit.tres"),
		preload("res://resources/units/mages/echo_caster.tres"),
		preload("res://resources/units/mages/hexweaver.tres"),
		preload("res://resources/units/mages/runic_scribe.tres"),
		preload("res://resources/units/mages/wellspring.tres"),
		preload("res://resources/units/mages/arcanist.tres"),
		preload("res://resources/units/mages/channeler.tres"),
		preload("res://resources/units/mages/warchanter.tres"),
	],
	"Elf": [
		preload("res://resources/units/elves/elf_scout.tres"),
		preload("res://resources/units/elves/thornguard.tres"),
		preload("res://resources/units/elves/duskblade.tres"),
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
	],
	"Aztec": [
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
	],
	"Myconid": [
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
	],
	"Reaper": [
		preload("res://resources/units/reapers/wraith.tres"),
		preload("res://resources/units/reapers/pale_shroud.tres"),
		preload("res://resources/units/reapers/dread_knell.tres"),
		preload("res://resources/units/reapers/grave_stalker.tres"),
		preload("res://resources/units/reapers/void_wraith.tres"),
		preload("res://resources/units/reapers/pale_reaper.tres"),
		preload("res://resources/units/reapers/dread_seer.tres"),
		preload("res://resources/units/reapers/doom_herald.tres"),
		preload("res://resources/units/reapers/shade_stalker.tres"),
		preload("res://resources/units/reapers/wail_specter.tres"),
		preload("res://resources/units/reapers/dread_lord.tres"),
		preload("res://resources/units/reapers/grave_collector.tres"),
		preload("res://resources/units/reapers/soul_harvester.tres"),
		preload("res://resources/units/reapers/rift_caller.tres"),
		preload("res://resources/units/reapers/death_sovereign.tres"),
		preload("res://resources/units/reapers/grave_pact.tres"),
	],
	"Covenant": [
		preload("res://resources/units/covenant/covenant_initiate.tres"),
		preload("res://resources/units/covenant/seeker.tres"),
		preload("res://resources/units/covenant/pact_kin.tres"),
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
	],
	"Satyr": [
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
		preload("res://resources/units/satyrs/blood_hunger.tres"),
		preload("res://resources/units/satyrs/auric_mirror.tres"),
		preload("res://resources/units/satyrs/pack_sovereign.tres"),
		preload("res://resources/units/satyrs/eternal_grove.tres"),
		preload("res://resources/units/satyrs/dark_reveler.tres"),
		preload("res://resources/units/satyrs/prismatic_reveler.tres"),
	],
	"Construct": [
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
	],
	"Generic": [
		preload("res://resources/units/grave_conductor.tres"),
		preload("res://resources/units/surge_master.tres"),
	],
}

# ── State ─────────────────────────────────────────────────────────────────────

var _active_faction: String = "Human"
var _grid_scroll: ScrollContainer
var _grid_content: VBoxContainer
var _detail_root: Control
var _selected_border: Panel = null
var _faction_buttons: Array[Button] = []
var _shop_callbacks: Dictionary = {}

# ── Entry point ───────────────────────────────────────────────────────────────

static func open(parent: Control, shop_callbacks: Dictionary = {}) -> void:
	var m := UnitManual.new()
	m._shop_callbacks = shop_callbacks
	m.set_anchors_preset(Control.PRESET_FULL_RECT)
	m.z_index = 200
	parent.add_child(m)


func _ready() -> void:
	_build()


# ── UI construction ───────────────────────────────────────────────────────────

func _build() -> void:
	var dim := ColorRect.new()
	dim.color = Color(0, 0, 0, 0.82)
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	dim.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(dim)

	var panel := Panel.new()
	var ps := StyleBoxFlat.new()
	ps.bg_color = Color(0.08, 0.09, 0.13)
	ps.set_corner_radius_all(10)
	ps.set_border_width_all(2)
	ps.border_color = Color(0.28, 0.30, 0.42)
	panel.add_theme_stylebox_override("panel", ps)
	panel.set_anchors_preset(Control.PRESET_FULL_RECT)
	panel.offset_left   = 28
	panel.offset_top    = 20
	panel.offset_right  = -28
	panel.offset_bottom = -20
	add_child(panel)

	var root_mg := MarginContainer.new()
	root_mg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	for s in ["margin_left", "margin_right", "margin_top", "margin_bottom"]:
		root_mg.add_theme_constant_override(s, 14)
	panel.add_child(root_mg)

	var root_vbox := VBoxContainer.new()
	root_vbox.add_theme_constant_override("separation", 10)
	root_mg.add_child(root_vbox)

	# Header row
	var header := HBoxContainer.new()
	root_vbox.add_child(header)

	var title_lbl := Label.new()
	title_lbl.text = "UNIT MANUAL"
	title_lbl.add_theme_font_size_override("font_size", 20)
	title_lbl.add_theme_color_override("font_color", Color(1.0, 0.88, 0.38))
	title_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(title_lbl)

	var close_btn := Button.new()
	close_btn.text = "✕  Close"
	close_btn.custom_minimum_size = Vector2(96, 34)
	close_btn.pressed.connect(queue_free)
	header.add_child(close_btn)

	root_vbox.add_child(HSeparator.new())

	# 3-column body
	var body := HBoxContainer.new()
	body.add_theme_constant_override("separation", 0)
	body.size_flags_vertical = Control.SIZE_EXPAND_FILL
	root_vbox.add_child(body)

	body.add_child(_build_faction_nav())
	body.add_child(VSeparator.new())

	_grid_scroll = ScrollContainer.new()
	_grid_scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_grid_scroll.size_flags_vertical   = Control.SIZE_EXPAND_FILL
	_grid_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	body.add_child(_grid_scroll)

	_grid_content = VBoxContainer.new()
	_grid_content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_grid_content.add_theme_constant_override("separation", 6)
	_grid_scroll.add_child(_grid_content)

	body.add_child(VSeparator.new())

	# Detail panel
	var detail_panel := Panel.new()
	detail_panel.custom_minimum_size = Vector2(260, 0)
	var dps := StyleBoxFlat.new()
	dps.bg_color = Color(0.09, 0.10, 0.15)
	detail_panel.add_theme_stylebox_override("panel", dps)
	body.add_child(detail_panel)

	var detail_mg := MarginContainer.new()
	detail_mg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	for s in ["margin_left", "margin_right", "margin_top", "margin_bottom"]:
		detail_mg.add_theme_constant_override(s, 12)
	detail_panel.add_child(detail_mg)

	_detail_root = detail_mg

	_refresh_grid()


func _build_faction_nav() -> Control:
	var scroll := ScrollContainer.new()
	scroll.custom_minimum_size = Vector2(118, 0)
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 3)
	var mg := MarginContainer.new()
	for s in ["margin_left", "margin_right", "margin_top", "margin_bottom"]:
		mg.add_theme_constant_override(s, 4)
	mg.add_child(vbox)
	scroll.add_child(mg)

	_faction_buttons.clear()
	for faction: String in FACTIONS:
		var btn := Button.new()
		btn.text = faction
		btn.custom_minimum_size = Vector2(108, 36)
		btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
		var captured_faction := faction
		btn.pressed.connect(func():
			_active_faction = captured_faction
			_selected_border = null
			_refresh_grid()
			_restyle_faction_buttons())
		_faction_buttons.append(btn)
		vbox.add_child(btn)

	_restyle_faction_buttons()
	return scroll


func _restyle_faction_buttons() -> void:
	for i in _faction_buttons.size():
		var btn := _faction_buttons[i]
		var faction: String = FACTIONS[i]
		var fc: Color = FACTION_COLORS.get(faction, Color(0.18, 0.20, 0.28))
		var is_active := faction == _active_faction

		var normal_sty := StyleBoxFlat.new()
		normal_sty.bg_color = fc.lightened(0.06) if is_active else Color(0.11, 0.12, 0.18)
		normal_sty.set_corner_radius_all(5)
		if is_active:
			normal_sty.set_border_width_all(2)
			normal_sty.border_color = fc.lightened(0.35)

		var hover_sty := StyleBoxFlat.new()
		hover_sty.bg_color = fc.lightened(0.14) if is_active else Color(0.16, 0.17, 0.24)
		hover_sty.set_corner_radius_all(5)

		btn.add_theme_stylebox_override("normal", normal_sty)
		btn.add_theme_stylebox_override("hover",  hover_sty)
		btn.add_theme_stylebox_override("pressed", normal_sty)
		btn.add_theme_color_override("font_color", Color(1, 1, 1) if is_active else Color(0.72, 0.72, 0.82))
		btn.add_theme_font_size_override("font_size", 13)


# ── Grid ──────────────────────────────────────────────────────────────────────

func _refresh_grid() -> void:
	for child in _grid_content.get_children():
		child.queue_free()
	_clear_detail()

	var units: Array = FACTION_UNITS.get(_active_faction, [])

	# Shop button row
	if _shop_callbacks.has(_active_faction):
		var shop_row := HBoxContainer.new()
		shop_row.add_theme_constant_override("separation", 10)
		var shop_mg := MarginContainer.new()
		for s in ["margin_left", "margin_top", "margin_bottom"]:
			shop_mg.add_theme_constant_override(s, 6)
		shop_mg.add_child(shop_row)
		_grid_content.add_child(shop_mg)
		var shop_name_lbl := Label.new()
		shop_name_lbl.text = "Shop: " + FACTION_SHOP_NAMES.get(_active_faction, "")
		shop_name_lbl.add_theme_font_size_override("font_size", 12)
		shop_name_lbl.add_theme_color_override("font_color", Color(0.70, 0.88, 1.0))
		shop_name_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		shop_row.add_child(shop_name_lbl)
		var shop_btn := Button.new()
		shop_btn.text = "Open Shop"
		shop_btn.custom_minimum_size = Vector2(100, 28)
		shop_btn.pressed.connect(_shop_callbacks[_active_faction])
		shop_row.add_child(shop_btn)
		_grid_content.add_child(HSeparator.new())

	var by_tier: Dictionary = {1: [], 2: [], 3: [], 4: []}
	for ud: UnitData in units:
		var t := clampi(ud.tier, 1, 4)
		by_tier[t].append(ud)

	for tier in [1, 2, 3, 4]:
		var tier_units: Array = by_tier[tier]
		if tier_units.is_empty():
			continue

		var header_mg := MarginContainer.new()
		for s in ["margin_left", "margin_top"]:
			header_mg.add_theme_constant_override(s, 6)
		var tier_lbl := Label.new()
		tier_lbl.text = "  Tier %d  %s" % [tier, "★".repeat(tier)]
		tier_lbl.add_theme_font_size_override("font_size", 12)
		tier_lbl.add_theme_color_override("font_color", Color(0.65, 0.65, 0.80))
		header_mg.add_child(tier_lbl)
		_grid_content.add_child(header_mg)

		var row_mg := MarginContainer.new()
		for s in ["margin_left", "margin_bottom"]:
			row_mg.add_theme_constant_override(s, 8)
		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 6)
		row_mg.add_child(row)
		_grid_content.add_child(row_mg)

		for ud: UnitData in tier_units:
			row.add_child(_build_unit_entry(ud))

	_grid_scroll.scroll_vertical = 0


func _build_unit_entry(ud: UnitData) -> Control:
	const W := 82
	const H := 114

	var container := Control.new()
	container.custom_minimum_size = Vector2(W, H)
	container.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND

	var fc: Color = FACTION_COLORS.get(_active_faction, Color(0.18, 0.20, 0.28))

	var bg := Panel.new()
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var bgs := StyleBoxFlat.new()
	bgs.bg_color = fc
	bgs.set_corner_radius_all(6)
	bgs.set_border_width_all(1)
	bgs.border_color = fc.lightened(0.22)
	bg.add_theme_stylebox_override("panel", bgs)
	container.add_child(bg)

	var art := UnitArtDrawer.new()
	art.set_anchors_preset(Control.PRESET_FULL_RECT)
	art.offset_bottom = -24
	art.mouse_filter  = Control.MOUSE_FILTER_IGNORE
	art.setup(ud)
	container.add_child(art)

	# ATK badge
	var atk_bg := Panel.new()
	atk_bg.anchor_right  = 0
	atk_bg.anchor_bottom = 0
	atk_bg.offset_left   = 2
	atk_bg.offset_top    = 2
	atk_bg.offset_right  = 26
	atk_bg.offset_bottom = 22
	atk_bg.mouse_filter  = Control.MOUSE_FILTER_IGNORE
	var atk_sty := StyleBoxFlat.new()
	atk_sty.bg_color = Color(0.12, 0.60, 0.18)
	atk_sty.set_corner_radius_all(4)
	atk_bg.add_theme_stylebox_override("panel", atk_sty)
	var atk_lbl := Label.new()
	atk_lbl.text = str(ud.base_attack)
	atk_lbl.set_anchors_preset(Control.PRESET_FULL_RECT)
	atk_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	atk_lbl.vertical_alignment   = VERTICAL_ALIGNMENT_CENTER
	atk_lbl.add_theme_font_size_override("font_size", 12)
	atk_lbl.add_theme_color_override("font_color", Color(1, 1, 1))
	atk_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	atk_bg.add_child(atk_lbl)
	container.add_child(atk_bg)

	# HP badge
	var hp_bg := Panel.new()
	hp_bg.anchor_left   = 1
	hp_bg.anchor_right  = 1
	hp_bg.anchor_bottom = 0
	hp_bg.offset_left   = -26
	hp_bg.offset_top    = 2
	hp_bg.offset_right  = -2
	hp_bg.offset_bottom = 22
	hp_bg.mouse_filter  = Control.MOUSE_FILTER_IGNORE
	var hp_sty := StyleBoxFlat.new()
	hp_sty.bg_color = Color(0.72, 0.10, 0.10)
	hp_sty.set_corner_radius_all(4)
	hp_bg.add_theme_stylebox_override("panel", hp_sty)
	var hp_lbl := Label.new()
	hp_lbl.text = str(ud.base_health)
	hp_lbl.set_anchors_preset(Control.PRESET_FULL_RECT)
	hp_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hp_lbl.vertical_alignment   = VERTICAL_ALIGNMENT_CENTER
	hp_lbl.add_theme_font_size_override("font_size", 12)
	hp_lbl.add_theme_color_override("font_color", Color(1, 1, 1))
	hp_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hp_bg.add_child(hp_lbl)
	container.add_child(hp_bg)

	# Name strip at bottom
	var name_bg := Panel.new()
	name_bg.anchor_top    = 1
	name_bg.anchor_bottom = 1
	name_bg.anchor_right  = 1
	name_bg.offset_top    = -24
	name_bg.mouse_filter  = Control.MOUSE_FILTER_IGNORE
	var ns := StyleBoxFlat.new()
	ns.bg_color = Color(0, 0, 0, 0.74)
	ns.corner_radius_bottom_left  = 6
	ns.corner_radius_bottom_right = 6
	name_bg.add_theme_stylebox_override("panel", ns)
	var name_lbl := Label.new()
	name_lbl.text = ud.display_name
	name_lbl.set_anchors_preset(Control.PRESET_FULL_RECT)
	name_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_lbl.vertical_alignment   = VERTICAL_ALIGNMENT_CENTER
	name_lbl.add_theme_font_size_override("font_size", 8)
	name_lbl.add_theme_color_override("font_color", Color(1, 1, 1))
	name_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	name_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD
	name_bg.add_child(name_lbl)
	container.add_child(name_bg)

	# Selection highlight border (hidden until clicked)
	var sel_border := Panel.new()
	sel_border.set_anchors_preset(Control.PRESET_FULL_RECT)
	sel_border.mouse_filter = Control.MOUSE_FILTER_IGNORE
	sel_border.visible = false
	var sb_sty := StyleBoxFlat.new()
	sb_sty.bg_color = Color(0, 0, 0, 0)
	sb_sty.set_border_width_all(3)
	sb_sty.border_color = Color(1.0, 0.88, 0.28)
	sb_sty.set_corner_radius_all(6)
	sel_border.add_theme_stylebox_override("panel", sb_sty)
	container.add_child(sel_border)

	# Invisible click region on top
	var btn := Button.new()
	btn.set_anchors_preset(Control.PRESET_FULL_RECT)
	btn.flat = true
	var btn_nrm := StyleBoxFlat.new()
	btn_nrm.bg_color = Color(0, 0, 0, 0)
	var btn_hvr := StyleBoxFlat.new()
	btn_hvr.bg_color = Color(1, 1, 1, 0.06)
	btn_hvr.set_corner_radius_all(6)
	btn.add_theme_stylebox_override("normal",  btn_nrm)
	btn.add_theme_stylebox_override("pressed", btn_nrm)
	btn.add_theme_stylebox_override("hover",   btn_hvr)
	btn.pressed.connect(func():
		if _selected_border != null:
			_selected_border.visible = false
		_selected_border = sel_border
		sel_border.visible = true
		_show_detail(ud))
	container.add_child(btn)

	return container


# ── Detail panel ──────────────────────────────────────────────────────────────

func _clear_detail() -> void:
	for child in _detail_root.get_children():
		child.queue_free()


func _show_detail(ud: UnitData) -> void:
	_clear_detail()

	var scroll := ScrollContainer.new()
	scroll.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	_detail_root.add_child(scroll)

	var vbox := VBoxContainer.new()
	vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox.add_theme_constant_override("separation", 10)
	scroll.add_child(vbox)

	# Art thumbnail
	var fc: Color = FACTION_COLORS.get(_active_faction, Color(0.18, 0.20, 0.28))
	var art_panel := Panel.new()
	art_panel.custom_minimum_size = Vector2(0, 152)
	var aps := StyleBoxFlat.new()
	aps.bg_color = fc
	aps.set_corner_radius_all(8)
	art_panel.add_theme_stylebox_override("panel", aps)
	vbox.add_child(art_panel)

	var art := UnitArtDrawer.new()
	art.set_anchors_preset(Control.PRESET_FULL_RECT)
	art.setup(ud)
	art_panel.add_child(art)

	# Name + tier
	var name_lbl := Label.new()
	name_lbl.text = ud.display_name + "  " + "★".repeat(ud.tier)
	name_lbl.add_theme_font_size_override("font_size", 15)
	name_lbl.add_theme_color_override("font_color", Color(1.0, 0.93, 0.55))
	name_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD
	vbox.add_child(name_lbl)

	vbox.add_child(HSeparator.new())

	# Stats row
	var stats_row := HBoxContainer.new()
	stats_row.alignment = BoxContainer.ALIGNMENT_CENTER
	stats_row.add_theme_constant_override("separation", 14)
	vbox.add_child(stats_row)

	var atk_l := Label.new()
	atk_l.text = "ATK  %d" % ud.base_attack
	atk_l.add_theme_color_override("font_color", Color(0.28, 0.88, 0.38))
	atk_l.add_theme_font_size_override("font_size", 13)
	stats_row.add_child(atk_l)

	var hp_l := Label.new()
	hp_l.text = "HP  %d" % ud.base_health
	hp_l.add_theme_color_override("font_color", Color(0.88, 0.28, 0.28))
	hp_l.add_theme_font_size_override("font_size", 13)
	stats_row.add_child(hp_l)

	# Keywords
	var kws: Array[String] = []
	if (ud.keywords & KeywordFlags.Keyword.TAUNT) != 0:        kws.append("Taunt")
	if (ud.keywords & KeywordFlags.Keyword.DIVINE_SHIELD) != 0: kws.append("Divine Shield")
	if (ud.keywords & KeywordFlags.Keyword.POISONOUS) != 0:    kws.append("Poisonous")
	if (ud.keywords & KeywordFlags.Keyword.REBORN) != 0:       kws.append("Reborn")
	if (ud.keywords & KeywordFlags.Keyword.WINDFURY) != 0:     kws.append("Windfury")
	if (ud.keywords & KeywordFlags.Keyword.STEALTH) != 0:      kws.append("Stealth")
	if (ud.keywords & KeywordFlags.Keyword.ECHO) != 0:         kws.append("Echo")
	if not kws.is_empty():
		var kw_lbl := Label.new()
		kw_lbl.text = " | ".join(kws)
		kw_lbl.add_theme_color_override("font_color", Color(0.72, 0.88, 1.0))
		kw_lbl.add_theme_font_size_override("font_size", 12)
		kw_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		kw_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD
		vbox.add_child(kw_lbl)

	# Ability description
	var desc := _get_description(ud)
	if desc != "":
		vbox.add_child(HSeparator.new())
		var desc_lbl := Label.new()
		desc_lbl.text = desc
		desc_lbl.add_theme_color_override("font_color", Color(0.88, 0.88, 0.94))
		desc_lbl.add_theme_font_size_override("font_size", 11)
		desc_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD
		desc_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		vbox.add_child(desc_lbl)

	# Pre-equipped spell note
	if ud.pre_equipped_spell != null:
		vbox.add_child(HSeparator.new())
		var spell_lbl := Label.new()
		spell_lbl.text = "Pre-equipped: " + ud.pre_equipped_spell.display_name
		spell_lbl.add_theme_color_override("font_color", Color(0.72, 0.82, 1.0))
		spell_lbl.add_theme_font_size_override("font_size", 11)
		spell_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD
		vbox.add_child(spell_lbl)


func _get_description(ud: UnitData) -> String:
	var temp := preload("res://scenes/unit_card.tscn").instantiate() as UnitCard
	temp.data = ud
	temp.is_radiant = false
	temp.mage_effect_level = 1
	var result := temp._get_effect_description()
	temp.free()
	return result
