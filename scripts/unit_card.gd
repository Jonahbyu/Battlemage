class_name UnitCard
extends Control

signal buy_pressed(card: UnitCard)
signal shop_pressed(card: UnitCard)

var data: UnitData
var current_attack: int = 1
var current_health: int = 1
var current_keywords: int = 0
var is_dead: bool = false
var is_radiant: bool = false
var reborn_triggered: bool = false
var attack_direction: Vector2 = Vector2(0, -25)
var is_draggable: bool = false

# Weapon slots (persist across rounds)
var equipped_weapon: WeaponData = null
var backpack_weapon: WeaponData = null

# Spell slot — Mage units only
var equipped_spell: SpellInstance = null
var mage_effect_level: int = 1  # used by upgradeable passive effects (e.g. Coin Sage gold per death)

# Construct charge — persists between combats
var construct_charge: int = 0
var construct_depowered: bool = false

# Myconid spores — persists between combats
var myconid_spores: int = 0

# Covenant bonds — reset each combat
var bonded_units: Array = []

# Runtime combat state — reset each combat, never saved
var combat_gun_damage: int = 0
var combat_shots: int = 0
var combat_shot_bonus: int = 0   # Gunner: added per shot
var combat_bonus_damage: int = 0 # Commander aura etc.

@onready var card_background: Panel = $CardBackground
@onready var attack_label: Label = $AttackBadge/AttackLabel
@onready var name_label: Label = $HoverNamePanel/NameLabel
@onready var health_label: Label = $HealthBadge/HealthLabel
@onready var weapon_label: Label = $WeaponLabel
@onready var weapon_indicator: Label = $WeaponIndicator
@onready var taunt_border: Panel = $TauntBorder
@onready var select_border: Panel = $SelectBorder
@onready var radiant_border: Panel = $RadiantBorder
@onready var divine_shield_overlay: ColorRect = $DivineShieldOverlay
@onready var highlight_overlay: ColorRect = $HighlightOverlay
@onready var buy_button: Button = $BuyButton
var _shop_button: Button = null
var _charge_label: Label = null
var _spore_label: Label = null
@onready var art_drawer: UnitArtDrawer = $ArtDrawer
@onready var hover_name_panel: Panel = $HoverNamePanel
@onready var card_preview: Panel = $CardPreview
@onready var preview_name_label: Label = $CardPreview/PreviewContent/PreviewNameLabel
@onready var preview_body_label: Label = $CardPreview/PreviewContent/PreviewBodyLabel


func _ready() -> void:
	if data != null:
		art_drawer.setup(data)
		refresh_display()
	_shop_button = Button.new()
	_shop_button.anchor_left = 1.0
	_shop_button.anchor_top = 0.0
	_shop_button.anchor_right = 1.0
	_shop_button.anchor_bottom = 0.0
	_shop_button.offset_left = -24
	_shop_button.offset_right = -2
	_shop_button.offset_top = 2
	_shop_button.offset_bottom = 34
	_shop_button.text = "🛒"
	_shop_button.flat = true
	_shop_button.focus_mode = Control.FOCUS_NONE
	_shop_button.visible = false
	_shop_button.pressed.connect(func(): shop_pressed.emit(self))
	add_child(_shop_button)

	_charge_label = Label.new()
	_charge_label.anchor_left = 0.0
	_charge_label.anchor_top = 1.0
	_charge_label.anchor_right = 0.0
	_charge_label.anchor_bottom = 1.0
	_charge_label.offset_left = 2
	_charge_label.offset_right = 44
	_charge_label.offset_top = -46
	_charge_label.offset_bottom = -28
	_charge_label.add_theme_font_size_override("font_size", 11)
	_charge_label.add_theme_color_override("font_color", Color(0.75, 0.92, 1.0))
	_charge_label.visible = false
	add_child(_charge_label)

	_spore_label = Label.new()
	_spore_label.anchor_left = 0.0
	_spore_label.anchor_top = 1.0
	_spore_label.anchor_right = 0.0
	_spore_label.anchor_bottom = 1.0
	_spore_label.offset_left = 2
	_spore_label.offset_right = 44
	_spore_label.offset_top = -46
	_spore_label.offset_bottom = -28
	_spore_label.add_theme_font_size_override("font_size", 11)
	_spore_label.add_theme_color_override("font_color", Color(0.45, 0.95, 0.55))
	_spore_label.visible = false
	add_child(_spore_label)


func initialize(unit_data: UnitData) -> void:
	data = unit_data
	current_attack = unit_data.base_attack
	current_health = unit_data.base_health
	current_keywords = unit_data.keywords
	if unit_data.default_weapon != null:
		equipped_weapon = unit_data.default_weapon.duplicate()
	else:
		equipped_weapon = null
	backpack_weapon = null
	equipped_spell = _get_default_spell()
	if _shop_button != null:
		_shop_button.visible = unit_data.race in [
			RaceType.Race.HUMAN, RaceType.Race.MAGE, RaceType.Race.ELF,
			RaceType.Race.COVENANT, RaceType.Race.AZTEC,
			RaceType.Race.CONSTRUCT, RaceType.Race.REAPER, RaceType.Race.MYCONID,
		]
	if art_drawer != null:
		art_drawer.setup(unit_data)
	refresh_display()


func _get_default_spell() -> SpellInstance:
	if data.pre_equipped_spell != null:
		var inst := SpellInstance.new(data.pre_equipped_spell)
		inst.triggers[SpellTrigger.Trigger.ON_ATTACK] = 1
		return inst
	return null


func set_lifted(lifted: bool) -> void:
	select_border.visible = lifted
	modulate.a = 0.5 if lifted else 1.0


func show_targeted(on: bool) -> void:
	select_border.visible = on


func get_display_attack() -> int:
	if equipped_weapon == null:
		return current_attack
	var gun := equipped_weapon.get_total_damage()
	if equipped_weapon.weapon_type == WeaponData.WeaponType.MACHINE_GUN:
		return current_attack + gun * equipped_weapon.get_total_shots()
	return current_attack + gun


func _get_race_bg_color() -> Color:
	match data.race:
		RaceType.Race.HUMAN:  return Color(0.30, 0.18, 0.08, 1.0)
		RaceType.Race.MAGE:   return Color(0.10, 0.14, 0.32, 1.0)
		RaceType.Race.ELF:    return Color(0.10, 0.22, 0.12, 1.0)
		RaceType.Race.AZTEC:  return Color(0.28, 0.18, 0.04, 1.0)
		RaceType.Race.GOBLIN: return Color(0.18, 0.20, 0.08, 1.0)
		RaceType.Race.COVENANT:  return Color(0.08, 0.20, 0.22, 1.0)
		RaceType.Race.MYCONID: return Color(0.06, 0.14, 0.08, 1.0)
	return Color(0.20, 0.22, 0.28, 1.0)


func refresh_display() -> void:
	if not is_node_ready():
		return
	var bg_style := StyleBoxFlat.new()
	bg_style.bg_color = _get_race_bg_color()
	bg_style.set_corner_radius_all(12)
	card_background.add_theme_stylebox_override("panel", bg_style)

	name_label.text = data.display_name + "  " + "★".repeat(data.tier)
	attack_label.text = str(current_attack)
	health_label.text = str(current_health)
	taunt_border.visible = (current_keywords & KeywordFlags.Keyword.TAUNT) != 0
	divine_shield_overlay.visible = (current_keywords & KeywordFlags.Keyword.DIVINE_SHIELD) != 0
	radiant_border.visible = is_radiant

	var is_human := data.race == RaceType.Race.HUMAN
	var has_weapon := is_human and equipped_weapon != null
	var is_mage := data.race == RaceType.Race.MAGE
	var has_spell := is_mage and equipped_spell != null
	var is_goblin := data.race == RaceType.Race.GOBLIN
	var is_elf := data.race == RaceType.Race.ELF
	var is_covenant := data.race == RaceType.Race.COVENANT
	weapon_indicator.visible = is_human or is_mage or is_goblin or is_elf or is_covenant or data.race == RaceType.Race.AZTEC
	weapon_label.visible = has_weapon or has_spell
	if has_weapon:
		var w := equipped_weapon
		var gun := w.get_total_damage()
		match w.weapon_type:
			WeaponData.WeaponType.PISTOL:
				weapon_indicator.text = "⚙\nP"
				weapon_label.text = "+%d dmg" % gun
			WeaponData.WeaponType.SHOTGUN:
				weapon_indicator.text = "⚙\nSG"
				weapon_label.text = "+%d(+%d spl)" % [gun, w.get_splash_damage()]
			WeaponData.WeaponType.SNIPER:
				weapon_indicator.text = "⚙\nSNP"
				weapon_label.text = "+%d dmg" % gun
			WeaponData.WeaponType.MACHINE_GUN:
				weapon_indicator.text = "⚙\nMG"
				weapon_label.text = "+%d/shot x%d" % [gun, w.get_total_shots()]
	elif has_spell:
		weapon_indicator.text = "⚙"
		weapon_label.text = equipped_spell.spell_data.display_name
	elif is_mage:
		weapon_indicator.text = "⚙"
	elif is_goblin:
		weapon_indicator.text = "⚙"
	elif is_elf:
		weapon_indicator.text = "⚙"
	elif is_covenant:
		weapon_indicator.text = "⚙"
	elif data.race == RaceType.Race.AZTEC:
		weapon_indicator.text = "⚙"
	elif is_human:
		weapon_indicator.text = "⚙"

	if _charge_label != null:
		if data.race == RaceType.Race.CONSTRUCT and construct_charge > 0:
			_charge_label.text = "⚡%d" % construct_charge
			_charge_label.visible = true
		else:
			_charge_label.visible = false

	if _spore_label != null:
		if data.race == RaceType.Race.MYCONID and myconid_spores > 0:
			_spore_label.text = "🍄%d" % myconid_spores
			_spore_label.visible = true
		else:
			_spore_label.visible = false

	tooltip_text = ""


func _build_tooltip_text() -> String:
	var lines: Array[String] = []
	lines.append(data.display_name)

	# Race
	match data.race:
		RaceType.Race.HUMAN:    lines.append("Race: Human")
		RaceType.Race.ELF:      lines.append("Race: Elf")
		RaceType.Race.MAGE:     lines.append("Race: Mage")
		RaceType.Race.GOBLIN:   lines.append("Race: Goblin")
		RaceType.Race.COVENANT: lines.append("Race: Covenant")
		RaceType.Race.AZTEC:    lines.append("Race: Aztec")
		RaceType.Race.MYCONID:  lines.append("Race: Myconid")

	# Keywords
	var kws: Array[String] = []
	if (current_keywords & KeywordFlags.Keyword.TAUNT) != 0:        kws.append("Taunt")
	if (current_keywords & KeywordFlags.Keyword.DIVINE_SHIELD) != 0: kws.append("Divine Shield")
	if (current_keywords & KeywordFlags.Keyword.POISONOUS) != 0:    kws.append("Poisonous")
	if (current_keywords & KeywordFlags.Keyword.REBORN) != 0:       kws.append("Reborn")
	if (current_keywords & KeywordFlags.Keyword.WINDFURY) != 0:    kws.append("Windfury")
	if (current_keywords & KeywordFlags.Keyword.STEALTH) != 0:     kws.append("Stealth")
	if (current_keywords & KeywordFlags.Keyword.ECHO) != 0:        kws.append("Echo")
	if not kws.is_empty():
		lines.append(" | ".join(kws))

	# Human effect
	var effect := _get_effect_description()
	if effect != "":
		lines.append(effect)

	# Spell
	if equipped_spell != null:
		lines.append("Spell: %s  |  %s" % [
			equipped_spell.spell_data.display_name, equipped_spell.describe_triggers()])

	# Weapon
	if equipped_weapon != null:
		var w := equipped_weapon
		var dmg_text: String
		match w.weapon_type:
			WeaponData.WeaponType.MACHINE_GUN:
				dmg_text = "%d shots × %d dmg" % [w.get_total_shots(), w.get_total_damage()]
			WeaponData.WeaponType.SHOTGUN:
				dmg_text = "%d dmg  +  %d splash" % [w.get_total_damage(), w.get_splash_damage()]
			_:
				dmg_text = "%d dmg" % w.get_total_damage()
		lines.append("%s Lv.%d  |  %s" % [w.display_name, w.level, dmg_text])
		if backpack_weapon != null:
			lines.append("Backpack: %s Lv.%d" % [backpack_weapon.display_name, backpack_weapon.level])

	return "\n".join(lines)


func _get_effect_description() -> String:
	var m := 2 if is_radiant else 1
	match data.generic_effect:
		GenericEffect.Effect.KNELL_DOUBLER:
			var times := 3 if is_radiant else 2
			return "All friendly Death Knells trigger %d× instead of once" % times
		GenericEffect.Effect.SURGE_MASTER:
			var times := 3 if is_radiant else 2
			return "All friendly Surges fire %d× instead of once" % times
	if data.race == RaceType.Race.MAGE:
		match data.mage_effect:
			MageEffect.Effect.RUNECALLER:
				return "Surge: discover %d spell(s) to equip and immediately cast" % m
			MageEffect.Effect.SPELL_POWER_SURGE:
				return "Surge: permanently +%d ASP and +%d HSP" % [m, m]
			MageEffect.Effect.SPELL_FEEDER:
				return "Passive: your board gets +%d/+%d each time any spell fires" % [m, m]
			MageEffect.Effect.TRIGGER_BOOST:
				return "Aura: all spell triggers fire +%d extra time(s) while alive" % m
			MageEffect.Effect.SPELL_DOUBLER:
				return "Aura: %dx the first trigger of each type on each spell" % (m + 1)
			MageEffect.Effect.SURGE_TRIGGER_UP:
				return "Surge: +%d level on a random trigger on a random allied Mage" % m
			MageEffect.Effect.SPELL_POWER_AURA:
				return "Aura: +%d ASP while alive" % m
			MageEffect.Effect.ECHO_CASTER:
				var ec_avenge := 1 if is_radiant else 2
				var ec_desc := "re-cast the last triggered spell %s" % ("2× as many times as it fired" if is_radiant else "the same number of times it fired")
				return "Avenge %d: %s" % [ec_avenge, ec_desc]
			MageEffect.Effect.FAMILIAR:
				return "Gains +%d/+%d whenever any spell fires (permanent out of combat)" % [m, m]
			MageEffect.Effect.DEATH_KNELL_GOLD:
				return "Death Knell: generate %d gold  (Lv.%d)" % [mage_effect_level * m, mage_effect_level]
			MageEffect.Effect.DEATH_KNELL_HSP:
				return "Death Knell: permanently +%d HSP" % m
			MageEffect.Effect.RUNIC_SCRIBE:
				return "Death Knell: +%d level on a random trigger on a random friendly Mage" % m
		return ""
	if data.race == RaceType.Race.GOBLIN:
		match data.goblin_effect:
			GoblinEffect.Effect.NONE:
				return ""
			GoblinEffect.Effect.SUMMON_ON_ATTACK:
				return "On Attack: summon a Goblin Peon"
			GoblinEffect.Effect.PACK_LEADER_AURA:
				return "Aura: all other Goblins get +%d ATK" % (m * 2)
			GoblinEffect.Effect.DEATH_BOMB:
				return "Death Knell: deal %d damage to a random enemy and summon a Peon" % (m * 2)
			GoblinEffect.Effect.BROOD_WITCH:
				return "On Attack: give all friendly Peons +%d/+%d for this fight" % [m * 3, m * 3]
			GoblinEffect.Effect.WARCHIEF_AURA:
				return "Aura: when any friendly Goblin dies, summon %d replacement Peon(s)" % m
			GoblinEffect.Effect.DEATH_KNELL_CHAIN:
				return "Death Knell: summon %d Peon(s) with Reborn" % m
			GoblinEffect.Effect.DEATH_KNELL_ONCE:
				return "Death Knell: summon %d Goblin Peon(s)" % m
			GoblinEffect.Effect.STAT_BUDGET_SURGE:
				return "Surge: permanently +%d Peon stat budget" % (m * 2)
			GoblinEffect.Effect.DOUBLE_BUDGET_AURA:
				return "Aura: all Peons spawn with %dx stat budget" % (m + 1)
			GoblinEffect.Effect.DEATH_KNELL_PEON_BURST:
				return "Death Knell: summon 4 Peons at %dx budget" % (m + 1)
			GoblinEffect.Effect.DEATH_PEON_DAMAGE:
				return "When a friendly Peon dies: deal %d damage to a random enemy" % (m * 2)
			GoblinEffect.Effect.ATK_SKEW_AURA:
				return "Aura: all Peons spawn with %sattack-skewed stats" % ("wider " if is_radiant else "")
			GoblinEffect.Effect.AVENGE_BUDGET:
				return "Avenge %d: +1 Peon stat budget. Death Knell: summon %d Peon(s)" % [3 - m, m]
			GoblinEffect.Effect.WITCH_DOCTOR_BLESS:
				return "Click ⚙ to give a friendly unit Reborn or Taunt"
			GoblinEffect.Effect.DEATH_KNELL_BUDGET:
				return "Death Knell: permanently +%d Peon stat budget" % m
			GoblinEffect.Effect.KILL_BUDGET:
				return "On Kill: permanently +%d Peon stat budget" % m
		return ""
	if data.race == RaceType.Race.AZTEC:
		match data.aztec_effect:
			AztecEffect.Effect.SUN_PRIEST:
				return "Click ⚙ to open The Temple shop"
			AztecEffect.Effect.KILL_GOLD:
				return "On Kill: +%d gold" % m
			AztecEffect.Effect.BLESSING_AURA:
				return "Aura: +%d to your blessing rate while alive" % m
			AztecEffect.Effect.TRIBUTE_SURGE:
				return "Surge: use Blood Tribute without consuming the round use"
			AztecEffect.Effect.SACRIFICE_SURGE:
				return "Surge: sacrifice a unit for 2× gold"
			AztecEffect.Effect.WARDEN_AURA:
				return "Start of Combat: all friendly Aztecs get +2/+2 flat"
			AztecEffect.Effect.JAGUAR_BONUS:
				return "Start of Combat: gains +1 ATK per 5 gold you have saved (bonus on top of blessing)"
			AztecEffect.Effect.HIGH_PRIEST_AURA:
				return "Aura: your blessing rate is doubled while alive"
		return ""
	if data.race == RaceType.Race.CONSTRUCT:
		match data.construct_effect:
			ConstructEffect.Effect.WINDER:
				return "Click ⚙ to open The Coilworks. Start of Combat: adjacent Constructs gain +%d Charge." % (m * 2)
		return ""
	if data.race == RaceType.Race.REAPER:
		match data.reaper_effect:
			ReaperEffect.Effect.GRAVEWARDEN:
				return "Click ⚙ to open The Rift."
			ReaperEffect.Effect.WRAITH:
				return "On Attack: apply %d doom to target" % (m * 6)
			ReaperEffect.Effect.PALE_SHROUD:
				return "Aura: doomed enemies take +%d damage" % m
			ReaperEffect.Effect.GRAVE_STALKER:
				return "Start of Combat: apply 8 doom to %d random enemies" % (m * 2)
			ReaperEffect.Effect.VOID_WRAITH:
				return "On Attack: summon %d Shadow token(s) (2/2)" % (m * 2)
			ReaperEffect.Effect.PALE_REAPER:
				return "Death Knell: apply %d doom to all enemies" % (m * 10)
			ReaperEffect.Effect.DREAD_SEER:
				return "Surge: give board +%d max HP" % (m * 5)
			ReaperEffect.Effect.DOOM_HERALD:
				return "End of turn: increase doom damage by +%d" % (m * 10)
			ReaperEffect.Effect.SHADE_STALKER:
				return "Surge: give %d unit(s) Windfury" % m
			ReaperEffect.Effect.WAIL_SPECTER:
				return "On Attack: remove %d doom from target (Windfury)" % (m * 3)
			ReaperEffect.Effect.DREAD_LORD:
				return "Each time doom is applied: give board +%d/+%d" % [m * 5, m * 5]
			ReaperEffect.Effect.GRAVE_COLLECTOR:
				return "On Attack: apply 8 doom to target and %s" % ("all adjacent enemies" if is_radiant else "an adjacent enemy")
			ReaperEffect.Effect.SOUL_HARVESTER:
				return "On Attack: apply %d doom; when doom expires, +%d/+%d" % [m * 5, m * 5, m * 5]
			ReaperEffect.Effect.RIFT_CALLER:
				return "Avenge %d: reduce a random doom by %d" % [3 - m, m * 2]
			ReaperEffect.Effect.DEATH_SOVEREIGN:
				return "Aura: all friendly attacks tick doom by %d" % (m * 2)
			ReaperEffect.Effect.GRAVE_PACT:
				return "Start of Combat: apply 10 doom to all units%s; friendlies take %d%% doom damage" % [(" twice" if is_radiant else ""), (25 if is_radiant else 50)]
		return ""
	if data.race == RaceType.Race.MYCONID:
		match data.myconid_effect:
			MyconidEffect.Effect.SPOREKEEPER:
				return "End of turn: give an adjacent Myconid +%d Spore." % m
			MyconidEffect.Effect.PARASITE:
				return "On death: spores transfer to %d adjacent Myconid(s)." % m
			MyconidEffect.Effect.SPORELING_ATTACK:
				return "On Attack: gain +%d Spore." % m
			MyconidEffect.Effect.MYCO_CAP_AURA:
				return "Start of Combat: spores give +%d extra +1/+1 to all friendly Myconids this fight." % m
			MyconidEffect.Effect.BLOOM_EOT:
				return "End of turn: give each friendly Myconid %d spore(s) per Myconid on your board." % m
			MyconidEffect.Effect.SPORE_VENT_KNELL:
				return "Death Knell: deal %d damage per spore on this unit to a random enemy." % m
			MyconidEffect.Effect.MYCELIUM_DEATH:
				return "When a friendly Myconid dies: gain +%d spore(s)." % (m * 2)
			MyconidEffect.Effect.DECOMPOSER:
				return "Whenever this gains a spore, gain +%d more. Works in and out of combat." % m
			MyconidEffect.Effect.HYPHAE_SURGE:
				return "Surge: give all friendly Myconids +%d spore." % m
			MyconidEffect.Effect.SPOREFRONT_ATTACK:
				return "On Attack: every other friendly Myconid gains +%d spore(s)." % m
			MyconidEffect.Effect.SPORE_HOARDER_SOC:
				return "Start of Combat: steal %s the spores from each adjacent Myconid." % ("all of" if is_radiant else "half")
			MyconidEffect.Effect.SPOREGUARD:
				return "When this reaches 10 spores, gain Divine Shield."
			MyconidEffect.Effect.MYCO_SAGE_KNELL:
				return "Death Knell: all friendly Myconids gain +%d/+%d per spore this unit had." % [m, m]
			MyconidEffect.Effect.CULTIVATOR_AURA:
				return "Aura: Parasites spawn with %dx the spores they would normally receive." % (m + 1)
			MyconidEffect.Effect.SPORE_SOVEREIGN_AURA:
				return "Aura: When any friendly summon overflows a full board, %d random Parasite(s) gain its stats (or this unit if none)." % m
			MyconidEffect.Effect.FUNGAL_ASCENDANT_KNELL:
				return "Death Knell: permanently raise spore buff level by +%d per living Myconid." % m
		return ""
	if data.race == RaceType.Race.ELF:
		match data.elf_effect:
			ElfEffect.Effect.DEATH_KNELL_ECHO:
				return "Death Knell: enter the Echo pool%s (spawn in wave 2)" % (" with 2× echo stats" if is_radiant else "")
			ElfEffect.Effect.WHEN_ATTACKED_BUFF:
				return "When Attacked: give a random other friendly unit +%d/+%d permanently" % [m, m]
			ElfEffect.Effect.ECHO_ADJACENT_BUFF:
				return "Start of Combat: adjacent units gain Echo and +%d/+%d permanently" % [m * 2, m * 2]
			ElfEffect.Effect.ON_KILL_STATS:
				return "On Kill: permanently +%d/+%d" % [m * 3, m * 3]
			ElfEffect.Effect.SURGE_ECHO_STAT:
				return "Surge: permanently +5%% to Echo stat percent"
			ElfEffect.Effect.ON_ATTACK_BUFF_ECHOED:
				return "On Attack: give all echoed friendly units +%d/+%d permanently" % [m * 2, m * 2]
			ElfEffect.Effect.DOUBLE_NEXT_ECHO:
				return "Start of Combat: next unit to enter the Echo pool spawns at %dx Echo stats" % (m + 1)
			ElfEffect.Effect.THORNBORN_GROWTH:
				return "Whenever a friendly unit dies: +%d/+%d permanently" % [m, m]
			ElfEffect.Effect.DEATH_KNELL_DIVINE_ECHO:
				return "Death Knell: give %d random echoed unit(s) Divine Shield" % m
			ElfEffect.Effect.DEATH_KNELL_BUFF_ECHOED:
				return "Death Knell: all echoed units permanently +%d/+%d" % [m * 4, m * 4]
			ElfEffect.Effect.AVENGE_BUFF_BOARD:
				return "Avenge 1: all surviving friendly units +%d/+%d permanently" % [m, m]
			ElfEffect.Effect.SURGE_ECHO_UNIT:
				return "Surge: give a target unit Echo and +%d/+%d permanently" % [m * 5, m * 5]
			ElfEffect.Effect.SOC_DOUBLE_ECHO_STAT:
				return "Start of Combat: Echo stat percent is %dx this combat" % (m + 1)
			ElfEffect.Effect.DEATH_KNELL_SUMMON_ECHO:
				return "Echo. Death Knell: summon a copy of a random Echo pool unit (it still spawns in wave 2)"
		return ""
	if data.race == RaceType.Race.COVENANT:
		match data.covenant_effect:
			CovenantEffect.Effect.TETHER:
				return "Start of Combat: Bond %s" % ("both adjacent allies" if is_radiant else "adjacent ally")
			CovenantEffect.Effect.SEEKER:
				return "Start of Combat: Bond %s" % ("the top 2 allies by ATK" if is_radiant else "the ally with the highest ATK")
			CovenantEffect.Effect.PACT_KIN:
				return "On Attack: permanently +%d HP. If bonded, also permanently +%d ATK" % [m * 2, m * 2]
			CovenantEffect.Effect.FURY_KIN:
				return "Berserk stat bonus is %dx for this unit" % (m + 1)
			CovenantEffect.Effect.WEAVE_KIN:
				return "End of turn: permanently increase Bond Share %% by %d%%" % (m * 5)
			CovenantEffect.Effect.OATH_BINDER:
				return "Surge: Bond this unit to a target ally"
			CovenantEffect.Effect.BOND_WARDEN:
				return "Aura: all bonded units gain +%d/+%d at Start of Combat" % [m * 3, m * 3]
			CovenantEffect.Effect.MARTYR_KIN:
				return "Death Knell: give this unit's stats to %s" % ("up to 2 bonded units" if is_radiant else "a bonded unit")
			CovenantEffect.Effect.RITE_HERALD:
				return "When a friendly attacks: give your board +%d/+%d (this combat)" % [m * 2, m * 2]
			CovenantEffect.Effect.VOW_GUARD:
				return "Aura: when any bonded unit goes Berserk, it gains Divine Shield%s" % (" and shares bonus with adjacent allies" if is_radiant else "")
			CovenantEffect.Effect.BOND_SHATTER:
				return "When a bond breaks: give your board +%d/+%d (this combat)" % [m * 5, m * 5]
			CovenantEffect.Effect.RITE_SAGE:
				return "Surge: permanently increase Berserk bonus by %d%%" % (m * 5)
			CovenantEffect.Effect.SOUL_TETHER:
				return "Start of Combat: Bond %s AND %s" % [("up to 2 adjacent allies" if is_radiant else "adjacent ally"), ("up to 2 adjacent enemies" if is_radiant else "adjacent enemy")]
			CovenantEffect.Effect.CHAIN_HUNTER:
				return "On Attack: Bond the target%s. If this kills a bonded unit, go Berserk and attack again bonding the next target. Repeats until a kill fails." % (" twice" if is_radiant else "")
			CovenantEffect.Effect.GRIEF_KIN:
				return "Avenge %d: Bond %d random friendly unit(s)" % [3 - m, m]
			CovenantEffect.Effect.RITE_SPAWNER:
				return "On Attack: Summon and Bond %d Covenantling(s) (2/2). %s attacks first. If %s die, go Berserk." % [m, ("Each" if is_radiant else "It"), ("they" if is_radiant else "it")]
		return ""
	if data.race != RaceType.Race.HUMAN:
		return ""
	match data.human_effect:
		HumanEffect.Effect.NONE:
			return ""
		HumanEffect.Effect.DEATH_KNELL_FIRE:
			return "Death Knell: fire weapon %d× at random enemy" % m
		HumanEffect.Effect.ON_FRIENDLY_DEATH_ATK:
			return "On friendly Human death: +%d ATK" % (m * 2)
		HumanEffect.Effect.SNIPER_BONUS:
			return "Sniper rifles deal +%d dmg" % (m * 2)
		HumanEffect.Effect.UPGRADE_DISCOUNT:
			return "Weapon upgrades cost %d less gold" % m
		HumanEffect.Effect.COUNTER_FIRE:
			return "When hit: fire weapon %d× at attacker" % m
		HumanEffect.Effect.SHOTGUN_BONUS:
			return "Shotgun splash deals +%d dmg" % (m * 2)
		HumanEffect.Effect.MACHINEGUN_BONUS:
			return "Machine gun shots: +%d dmg each" % m
		HumanEffect.Effect.COMMANDER_AURA:
			return "Aura: all other Humans +%d dmg per hit" % m
		HumanEffect.Effect.WEAPON_LEVEL_SURGE:
			return "Surge: own weapon +%d levels" % (3 if is_radiant else 2)
		HumanEffect.Effect.DOUBLE_FIRE_AURA:
			return "Aura: all friendly guns fire %s" % ("3× per attack" if is_radiant else "twice")
		HumanEffect.Effect.GUN_UPGRADE_SURGE:
			var lvls := 2 if is_radiant else 1
			return "Surge: give a friendly human +%d weapon level" % lvls
		HumanEffect.Effect.DUAL_WIELD:
			return "On Attack: also fires backup weapon at a random enemy; they cannot counter%s" % (" (Radiant: each weapon fires twice)" if is_radiant else "")
	return ""


func show_buy_button(visible_state: bool) -> void:
	buy_button.visible = visible_state


func _on_buy_button_pressed() -> void:
	buy_pressed.emit(self)


func _on_mouse_entered() -> void:
	hover_name_panel.visible = true
	_show_preview()


func _on_mouse_exited() -> void:
	hover_name_panel.visible = false
	card_preview.visible = false


func _show_preview() -> void:
	preview_name_label.text = data.display_name + "  " + "★".repeat(data.tier)
	preview_body_label.text = _build_preview_body()
	var preview_style := StyleBoxFlat.new()
	preview_style.bg_color = _get_race_bg_color().darkened(0.12)
	preview_style.set_corner_radius_all(10)
	preview_style.border_width_left = 2
	preview_style.border_width_top = 2
	preview_style.border_width_right = 2
	preview_style.border_width_bottom = 2
	preview_style.border_color = _get_race_bg_color().lightened(0.40)
	card_preview.add_theme_stylebox_override("panel", preview_style)
	var pw := 200.0
	var ph := 280.0
	var px := (size.x - pw) * 0.5
	if global_position.y < ph + 10.0:
		card_preview.position = Vector2(px, size.y + 6.0)
	else:
		card_preview.position = Vector2(px, -ph - 6.0)
	card_preview.size = Vector2(pw, ph)
	card_preview.visible = true


func _build_preview_body() -> String:
	var lines: Array[String] = []
	var race_str: String
	match data.race:
		RaceType.Race.HUMAN:  race_str = "Human"
		RaceType.Race.ELF:    race_str = "Elf"
		RaceType.Race.MAGE:   race_str = "Mage"
		RaceType.Race.GOBLIN: race_str = "Goblin"
		RaceType.Race.COVENANT: race_str = "Covenant"
		RaceType.Race.AZTEC:    race_str = "Aztec"
		RaceType.Race.MYCONID:  race_str = "Myconid"
		_: race_str = "?"
	lines.append("Race: %s  |  ATK %d  HP %d" % [race_str, get_display_attack(), current_health])
	var kws: Array[String] = []
	if (current_keywords & KeywordFlags.Keyword.TAUNT) != 0:        kws.append("Taunt")
	if (current_keywords & KeywordFlags.Keyword.DIVINE_SHIELD) != 0: kws.append("Divine Shield")
	if (current_keywords & KeywordFlags.Keyword.POISONOUS) != 0:    kws.append("Poisonous")
	if (current_keywords & KeywordFlags.Keyword.REBORN) != 0:       kws.append("Reborn")
	if (current_keywords & KeywordFlags.Keyword.WINDFURY) != 0:    kws.append("Windfury")
	if (current_keywords & KeywordFlags.Keyword.ECHO) != 0:        kws.append("Echo")
	if not kws.is_empty():
		lines.append(" | ".join(kws))
	var effect := _get_effect_description()
	if effect != "":
		lines.append("")
		lines.append(effect)
	if equipped_spell != null:
		lines.append("")
		lines.append("Spell: " + equipped_spell.spell_data.display_name)
		lines.append(equipped_spell.describe_triggers())
	if equipped_weapon != null:
		lines.append("")
		var w := equipped_weapon
		var dmg_text: String
		match w.weapon_type:
			WeaponData.WeaponType.MACHINE_GUN:
				dmg_text = "%d shots x %d dmg" % [w.get_total_shots(), w.get_total_damage()]
			WeaponData.WeaponType.SHOTGUN:
				dmg_text = "%d dmg + %d splash" % [w.get_total_damage(), w.get_splash_damage()]
			_:
				dmg_text = "%d dmg" % w.get_total_damage()
		lines.append("%s Lv.%d  |  %s" % [w.display_name, w.level, dmg_text])
		if backpack_weapon != null:
			lines.append("Backpack: %s Lv.%d" % [backpack_weapon.display_name, backpack_weapon.level])
	return "\n".join(lines)


func flash_attack_toward(target_center: Vector2) -> void:
	var container := get_parent()
	var slot_idx := get_index()
	var my_size := size
	var start_gpos := global_position
	var my_center_x := start_gpos.x + my_size.x * 0.5

	var dx := target_center.x - my_center_x
	var edge_offset_x: float = my_size.x * 0.5 * signf(dx)
	var lunge_gpos := Vector2(
		target_center.x - my_size.x * 0.5 - edge_offset_x,
		target_center.y - my_size.y * 0.5
	)

	var arena := get_tree().current_scene
	container.remove_child(self)
	arena.add_child(self)
	size = my_size
	global_position = start_gpos
	z_index = 5

	var tween := create_tween()
	tween.tween_property(self, "global_position", lunge_gpos, 0.14) \
		.set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "global_position", start_gpos, 0.15) \
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	await tween.finished

	z_index = 0
	arena.remove_child(self)
	container.add_child(self)
	container.move_child(self, slot_idx)


func flash_hit(_lethal: bool) -> void:
	pivot_offset = size * 0.5
	highlight_overlay.color = Color(1, 0, 0, 0)
	var t1 := create_tween()
	t1.set_parallel(true)
	t1.tween_property(highlight_overlay, "color", Color(1, 0, 0, 0.85), 0.07)
	t1.tween_property(self, "scale", Vector2(0.82, 0.82), 0.07)
	await t1.finished
	var t2 := create_tween()
	t2.set_parallel(true)
	t2.tween_property(highlight_overlay, "color", Color(1, 0, 0, 0), 0.22)
	t2.tween_property(self, "scale", Vector2(1.0, 1.0), 0.18)
	await t2.finished


func apply_divine_shield_break() -> void:
	current_keywords &= ~KeywordFlags.Keyword.DIVINE_SHIELD
	divine_shield_overlay.visible = true
	var tween := create_tween()
	tween.tween_property(divine_shield_overlay, "modulate:a", 0.0, 0.25)
	await tween.finished
	divine_shield_overlay.modulate.a = 1.0
	divine_shield_overlay.visible = false


func flash_triple_spawn() -> void:
	pivot_offset = size * 0.5
	scale = Vector2.ZERO
	highlight_overlay.color = Color(1, 0.85, 0, 0)
	var t1 := create_tween()
	t1.set_parallel(true)
	t1.tween_property(self, "scale", Vector2.ONE, 0.3) \
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	t1.tween_property(highlight_overlay, "color", Color(1, 0.85, 0, 0.7), 0.1)
	await t1.finished
	var t2 := create_tween()
	t2.tween_property(highlight_overlay, "color", Color(1, 0.85, 0, 0), 0.35)
	await t2.finished


func play_death_animation() -> void:
	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(self, "scale", Vector2.ZERO, 0.35)
	tween.tween_property(self, "modulate:a", 0.0, 0.35)
	await tween.finished


func flash_surge_source() -> void:
	pivot_offset = size * 0.5
	highlight_overlay.color = Color(0.4, 0.85, 1, 0)
	var t1 := create_tween()
	t1.set_parallel(true)
	t1.tween_property(highlight_overlay, "color", Color(0.4, 0.85, 1, 0.75), 0.1)
	t1.tween_property(self, "scale", Vector2(1.06, 1.06), 0.1)
	await t1.finished
	var t2 := create_tween()
	t2.set_parallel(true)
	t2.tween_property(highlight_overlay, "color", Color(0.4, 0.85, 1, 0), 0.4)
	t2.tween_property(self, "scale", Vector2.ONE, 0.28)
	await t2.finished


func flash_surge_buff() -> void:
	pivot_offset = size * 0.5
	highlight_overlay.color = Color(1, 0.85, 0, 0)
	var t1 := create_tween()
	t1.set_parallel(true)
	t1.tween_property(highlight_overlay, "color", Color(1, 0.85, 0, 0.8), 0.1)
	t1.tween_property(self, "scale", Vector2(1.1, 1.1), 0.1)
	await t1.finished
	var t2 := create_tween()
	t2.set_parallel(true)
	t2.tween_property(highlight_overlay, "color", Color(1, 0.85, 0, 0), 0.45)
	t2.tween_property(self, "scale", Vector2.ONE, 0.3)
	await t2.finished
