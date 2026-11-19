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
var mage_invested_gold: int = 0

# Construct charge — persists between combats
var construct_charge: int = 0
var construct_persistent_charge: int = 0  # snapshot before SOC; restored after combat
var construct_peak_charge: int = 0        # max charge reached this combat (Arc Coil)
var construct_depowered: bool = false
var construct_reignited: bool = false
var construct_protocol_used: bool = false

# Myconid spores — persists between combats
var myconid_spores: int = 0

# Covenant bonds — reset each combat
var bonded_units: Array = []

# Runtime combat state — reset each combat, never saved
var combat_gun_damage: int = 0
var combat_shots: int = 0
var combat_shot_bonus: int = 0   # Gunner: added per shot
var combat_bonus_damage: int = 0 # Commander aura etc.
var combat_temp_atk: int = 0     # rolled back at end of combat (Overload Core etc.)
var combat_temp_hp: int = 0

# Combat FX: floating numbers only while a fight is running.
const FX_HP_UNSET := -999999
static var fx_live := false
var _fx_hp: int = FX_HP_UNSET
var _fx_atk: int = FX_HP_UNSET

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
	_apply_facelift()
	if data != null:
		art_drawer.setup(data)
		refresh_display()
	_shop_button = Button.new()
	_shop_button.anchor_left = 1.0
	_shop_button.anchor_top = 0.0
	_shop_button.anchor_right = 1.0
	_shop_button.anchor_bottom = 0.0
	_shop_button.offset_left = -29
	_shop_button.offset_right = -3
	_shop_button.offset_top = 3
	_shop_button.offset_bottom = 29
	_shop_button.text = "⚙"
	_shop_button.add_theme_font_size_override("font_size", 20)
	_shop_button.add_theme_color_override("font_color", Color(1, 0.9, 0.6))
	_shop_button.add_theme_color_override("font_hover_color", Color(1, 1, 1))
	var badge := StyleBoxFlat.new()
	badge.bg_color = Color(0.08, 0.08, 0.12, 0.8)
	badge.border_color = Color(1, 0.85, 0.5, 0.7)
	badge.set_border_width_all(1)
	badge.set_corner_radius_all(13)
	badge.content_margin_left = 0
	badge.content_margin_right = 0
	badge.content_margin_top = 0
	badge.content_margin_bottom = 0
	var badge_hover := badge.duplicate() as StyleBoxFlat
	badge_hover.bg_color = Color(0.25, 0.2, 0.1, 0.9)
	_shop_button.add_theme_stylebox_override("normal", badge)
	_shop_button.add_theme_stylebox_override("hover", badge_hover)
	_shop_button.add_theme_stylebox_override("pressed", badge_hover)
	_shop_button.focus_mode = Control.FOCUS_NONE
	_shop_button.visible = false
	_shop_button.pressed.connect(func(): shop_pressed.emit(self))
	add_child(_shop_button)
	_update_menu_badge()

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
	_update_menu_badge()
	if art_drawer != null:
		art_drawer.setup(unit_data)
	refresh_display()


const _MENU_RACES := [
	RaceType.Race.HUMAN, RaceType.Race.MAGE, RaceType.Race.ELF,
	RaceType.Race.COVENANT, RaceType.Race.AZTEC,
	RaceType.Race.CONSTRUCT, RaceType.Race.REAPER, RaceType.Race.MYCONID,
	RaceType.Race.GOBLIN, RaceType.Race.SATYR,
]


func _notification(what: int) -> void:
	if what == NOTIFICATION_ENTER_TREE:
		_update_menu_badge()


# The ⚙ menu badge only means something on the player's own units, so hide it
# on enemy boards and on the discovery picker.
func _update_menu_badge() -> void:
	if _shop_button == null or data == null:
		return
	var is_players := false
	var node := get_parent()
	while node != null:
		if node is Board:
			is_players = (node as Board).is_draggable
			break
		if node is Bench:
			is_players = true
			break
		node = node.get_parent()
	_shop_button.visible = is_players and data.race in _MENU_RACES


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
	bg_style.set_corner_radius_all(8)
	bg_style.shadow_color = Color(0, 0, 0, 0.6)
	bg_style.shadow_size = 8
	bg_style.shadow_offset = Vector2(0, 4)
	card_background.add_theme_stylebox_override("panel", bg_style)
	if _frame != null:
		var fr := StyleBoxFlat.new()
		fr.draw_center = false
		fr.set_corner_radius_all(8)
		fr.set_border_width_all(2)
		fr.border_color = _tier_color(data.tier)
		fr.anti_aliasing = true
		_frame.add_theme_stylebox_override("panel", fr)

	name_label.text = data.display_name + "  " + "★".repeat(data.tier)
	attack_label.text = str(current_attack)
	health_label.text = str(current_health)
	_fx_health_changed()
	_fx_attack_changed()
	taunt_border.visible = (current_keywords & KeywordFlags.Keyword.TAUNT) != 0
	divine_shield_overlay.visible = (current_keywords & KeywordFlags.Keyword.DIVINE_SHIELD) != 0
	radiant_border.visible = is_radiant

	var is_human := data.race == RaceType.Race.HUMAN
	var has_weapon := is_human and equipped_weapon != null
	var is_mage := data.race == RaceType.Race.MAGE
	var has_spell := is_mage and equipped_spell != null
	# The ⚙ badge (_shop_button) marks races with a menu; the indicator just
	# adds the equipped weapon's short name under it.
	weapon_indicator.visible = false
	weapon_label.visible = has_weapon or has_spell
	if has_weapon:
		var w := equipped_weapon
		var gun := w.get_total_damage()
		weapon_indicator.visible = true
		match w.weapon_type:
			WeaponData.WeaponType.PISTOL:
				weapon_indicator.text = "P"
				weapon_label.text = "+%d dmg" % gun
			WeaponData.WeaponType.SHOTGUN:
				weapon_indicator.text = "SG"
				weapon_label.text = "+%d(+%d spl)" % [gun, w.get_splash_damage()]
			WeaponData.WeaponType.SNIPER:
				weapon_indicator.text = "SNP"
				weapon_label.text = "+%d dmg" % gun
			WeaponData.WeaponType.MACHINE_GUN:
				weapon_indicator.text = "MG"
				weapon_label.text = "+%d/shot x%d" % [gun, w.get_total_shots()]
	elif has_spell:
		weapon_label.text = equipped_spell.spell_data.display_name

	if _charge_label != null:
		if data.race == RaceType.Race.CONSTRUCT and construct_charge > 0:
			_charge_label.text = "⚡%d" % construct_charge
			_charge_label.visible = true
		else:
			_charge_label.visible = false

	if _spore_label != null:
		if data.race == RaceType.Race.MYCONID and myconid_spores > 0:
			_spore_label.text = "✿%d" % myconid_spores
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
			AztecEffect.Effect.GILDED_MARTYR:
				return "Death Knell: deal %d damage per gold held to a random enemy" % m
			AztecEffect.Effect.BLOOD_WITNESS:
				return "When any friendly is sacrificed: permanently +%d/+%d" % [m * 2, m * 2]
			AztecEffect.Effect.TRIBUTE_HUNTER:
				return "On Kill: gain +%d gold" % m
			AztecEffect.Effect.ANOINTED_VESSEL:
				return "Gives %dx gold when sacrificed (stacks with race bonus)" % (m + 1)
			AztecEffect.Effect.SUN_IDOL:
				return "Aura: +%d blessing rate while alive" % m
			AztecEffect.Effect.BLOOD_FEAST:
				return "When any friendly is sacrificed: permanently gain its ATK+HP"
			AztecEffect.Effect.SACRIFICE_SCOUT:
				return "Surge: sacrifice a target friendly unit (doesn't consume the round flag)"
			AztecEffect.Effect.VAULT_KEEPER:
				return "End of combat turn: gain +1 gold per bench unit"
			AztecEffect.Effect.GOLD_EFFIGY:
				return "Death Knell: deal damage equal to gold held to a random enemy"
			AztecEffect.Effect.TITHE_WARDEN:
				return "Aura: all friendly units gain +1 gold on kill"
			AztecEffect.Effect.SUN_SEEKER:
				return "Surge: if you own another Aztec, discover a random Aztec unit"
			AztecEffect.Effect.THE_DEVOURER:
				return "Permanently gains +%d/+%d for each sacrifice or tribute this run" % [m * 4, m * 4]
			AztecEffect.Effect.BLOOD_FONT:
				return "Off-board: grants %d free Blood Tribute(s) per shop phase" % m
			AztecEffect.Effect.GOLDEN_SOVEREIGN:
				return "Aura: doubles gold count for blessing calculation while alive"
			AztecEffect.Effect.THE_STARVED:
				return "Gains +%d/+%d per player HP missing at combat start; receives full blessing" % [m, m]
			AztecEffect.Effect.SUN_HERALD:
				return "Death Knell: summon a Gold Idol token (1/1 Aztec, 2× blessing)"
		return ""
	if data.race == RaceType.Race.CONSTRUCT:
		match data.construct_effect:
			ConstructEffect.Effect.WINDER:
				return "Click ⚙ to open The Coilworks. Start of Combat: adjacent Constructs gain +%d Charge." % (m * 2)
			ConstructEffect.Effect.CAPACITOR:
				return "Start of Combat: gain 1 Charge per friendly Construct in play." if not is_radiant else "Start of Combat: gain 2 Charge per friendly Construct in play."
			ConstructEffect.Effect.VOLT_STRIKER:
				return "Counter Strike: each spent Charge deals 2 damage back instead of 1." if not is_radiant else "Counter Strike: each spent Charge deals 4 damage back instead of 1."
			ConstructEffect.Effect.REIGNITER:
				return "When Depowered: regain %d Charge once per combat." % (m * 3)
			ConstructEffect.Effect.COIL_WEAVER:
				return "Battlecry: all Constructs gain +%d permanent SOC Charge." % m
			ConstructEffect.Effect.IRON_SENTINEL:
				return "When attacked: gain %d Charge." % (m * 3)
			ConstructEffect.Effect.ARC_COIL:
				return "Death Knell: give this unit's peak Charge from this combat to a random adjacent Construct."
			ConstructEffect.Effect.ACCUMULATOR:
				return "End of round: gain +%d persistent Charge." % (m * 3)
			ConstructEffect.Effect.DISCHARGE_ENGINE:
				return "When any friendly Construct loses a Charge point, your board gains +%d ATK." % m
			ConstructEffect.Effect.SURGE_CONDUIT:
				return "Battlecry: give all friendly Constructs +%d persistent Charge." % (m * 3)
			ConstructEffect.Effect.CHARGE_SIPHON:
				return "When another friendly Construct loses Charge, permanently gain +%d/+%d for each point lost." % [m, m]
			ConstructEffect.Effect.OVERLOAD_CORE:
				return "Aura: when a friendly Construct is Depowered, give it +%d/+%d (this combat only)." % [m * 10, m * 10]
			ConstructEffect.Effect.MELTDOWN:
				return "Death Knell: give all Constructs +%d Charge and give your entire board +%d/+%d permanently." % [m * 3, m * 3, m * 3]
			ConstructEffect.Effect.RELAY_NODE:
				return "Death Knell: trigger the Battlecry of a random adjacent unit."
			ConstructEffect.Effect.GRAND_CAPACITOR:
				return "Start of Combat: gain 1 Charge for every Charge point among all friendly Constructs." if not is_radiant else "Start of Combat: gain 2 Charge for every Charge point among all friendly Constructs."
			ConstructEffect.Effect.RECHARGE_PROTOCOL:
				return "Aura: the first time each friendly Construct would be Depowered this combat, it gains +%d Charge instead." % (m * 5)
			ConstructEffect.Effect.FISSION_CORE:
				return "Death Knell: give all friendly units +%d/+%d permanently for each point of peak Charge this unit reached this combat." % [m, m]
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
	if data.race == RaceType.Race.SATYR:
		match data.satyr_effect:
			SatyrEffect.Effect.CRIMSON:
				return "On death: deal Crimson damage to a random enemy"
			SatyrEffect.Effect.GOLD:
				return "Aura: give all allies +ATK while alive"
			SatyrEffect.Effect.SILVER:
				return "Targets the highest-HP enemy and deals bonus damage"
			SatyrEffect.Effect.GREEN:
				return "Death Knell: pass a stat-bonus chain to the next unit"
			SatyrEffect.Effect.BLACK:
				return "On hit: apply an ATK debuff to a random enemy"
			SatyrEffect.Effect.CRIMSON_T2:
				return "Reborn. Death Knell: permanently +1 Crimson death damage"
			SatyrEffect.Effect.GOLD_T2:
				return "Death Knell: +5%% Prismatic token summon chance"
			SatyrEffect.Effect.SILVER_T2:
				return "Divine Shield, Windfury. Always targets the highest-HP enemy"
			SatyrEffect.Effect.GREEN_T2:
				return "Death Knell: summon 2 Green Satyrs"
			SatyrEffect.Effect.BLACK_T2:
				return "End of turn: permanently +5%% to Black ATK debuff strength"
			SatyrEffect.Effect.CRIMSON_T3:
				return "Death Knell: deal Crimson damage to 2 random enemies (3 total with passive)"
			SatyrEffect.Effect.GOLD_T3:
				return "For every 2 ATK given by the Gold aura, also give +1 HP"
			SatyrEffect.Effect.SILVER_T3:
				return "On Attack: give all Satyrs +%d/+%d per Silver Satyr on board" % [m * 2, m * 2]
			SatyrEffect.Effect.GREEN_T3:
				return "Reborn. Death Knell: permanently +1 to Green stat chain bonus"
			SatyrEffect.Effect.BLACK_T3:
				return "On Attack: apply Black debuff to both enemies adjacent to the target"
			SatyrEffect.Effect.PRISMATIC_T4:
				return "When any friendly Satyr dies: summon a random-color Satyr token in its place"
			SatyrEffect.Effect.BLACK_T4:
				return "Whenever any friendly Satyr attacks: apply Black debuff to that target"
			SatyrEffect.Effect.GOLD_T4:
				return "Each Silver Satyr on board also counts as a Gold Satyr for the aura"
			SatyrEffect.Effect.GREEN_T4:
				return "When a Green Satyr dies: resummon it at full current stats (max 2× per fight)"
			SatyrEffect.Effect.CRIMSON_T4:
				return "Each time this unit deals damage: permanently +%d/+%d" % [m * 3, m * 3]
			SatyrEffect.Effect.SILVER_T4:
				return "After any friendly makes a kill: permanently give the whole board +%d/+%d" % [m * 3, m * 3]
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
	var preview_style := UITheme.panel_box(
		_get_race_bg_color().darkened(0.45).lerp(UITheme.PANEL_HI, 0.5), _tier_color(data.tier), 6, 18)
	preview_style.bg_color.a = 0.97
	card_preview.add_theme_stylebox_override("panel", preview_style)
	preview_name_label.add_theme_color_override("font_color", _tier_color(data.tier).lightened(0.25))
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


func _center() -> Vector2:
	return global_position + size * 0.5


func fx_tint() -> Color:
	return _get_race_bg_color().lightened(0.45)


func _uses_gun() -> bool:
	return data != null and data.race == RaceType.Race.HUMAN and equipped_weapon != null


# Floating number + badge punch whenever health changes during combat.
func _fx_health_changed() -> void:
	if not fx_live:
		_fx_hp = current_health
		return
	if _fx_hp == FX_HP_UNSET:
		_fx_hp = current_health
		return
	var delta := current_health - _fx_hp
	_fx_hp = current_health
	if delta == 0 or not is_inside_tree() or not is_visible_in_tree():
		return
	if delta > 0 and current_health <= 0:
		return
	var top := global_position + Vector2(size.x * 0.5, size.y * 0.42)
	if delta < 0:
		var lethal := current_health <= 0
		CombatFX.number(self, top, str(delta),
			Color(1, 0.25, 0.2) if not lethal else Color(1, 0.85, 0.3), lethal or delta <= -8)
	else:
		CombatFX.number(self, top, "+%d" % delta, Color(0.45, 1, 0.5))
	_punch(get_node_or_null("HealthBadge"))


func _fx_attack_changed() -> void:
	if fx_live and _fx_atk != FX_HP_UNSET and current_attack > _fx_atk and is_visible_in_tree():
		_punch(get_node_or_null("AttackBadge"))
	_fx_atk = current_attack


func _punch(node: Control) -> void:
	if node == null:
		return
	node.pivot_offset = node.size * 0.5
	var tw := node.create_tween()
	tw.tween_property(node, "scale", Vector2(1.45, 1.45), 0.07)
	tw.tween_property(node, "scale", Vector2.ONE, 0.2) \
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


# ── Attack ───────────────────────────────────────────────────────────────────

func flash_attack_toward(target_center: Vector2, target_card: UnitCard = null) -> void:
	if _uses_gun():
		await _shoot_toward(target_center, target_card)
	else:
		await _lunge_toward(target_center, target_card)


func _lunge_toward(target_center: Vector2, target_card: UnitCard) -> void:
	var container := get_parent()
	var slot_idx := get_index()
	var my_size := size
	var start_gpos := global_position
	var my_center := start_gpos + my_size * 0.5

	var to_target := target_center - my_center
	var n := to_target.normalized() if to_target.length() > 1.0 else Vector2.UP
	# Stop with our leading edge on the target's centre line, offset toward us.
	var stop_dist := maxf(0.0, to_target.length() - my_size.y * 0.55)
	var lunge_gpos := start_gpos + n * stop_dist
	var windup_gpos := start_gpos - n * 14.0
	var lean := clampf(n.x, -1.0, 1.0) * 0.18

	var arena := get_tree().current_scene
	container.remove_child(self)
	arena.add_child(self)
	size = my_size
	global_position = start_gpos
	pivot_offset = my_size * 0.5
	z_index = 5

	# Wind-up: pull back and squash.
	var tw := create_tween()
	tw.set_parallel(true)
	tw.tween_property(self, "global_position", windup_gpos, 0.1) \
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tw.tween_property(self, "scale", Vector2(1.08, 0.9), 0.1)
	tw.tween_property(self, "rotation", -lean, 0.1)
	await tw.finished

	# Strike: fast snap in, stretched along the motion.
	tw = create_tween()
	tw.set_parallel(true)
	tw.tween_property(self, "global_position", lunge_gpos, 0.09) \
		.set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_IN)
	tw.tween_property(self, "scale", Vector2(0.92, 1.12), 0.09)
	tw.tween_property(self, "rotation", lean, 0.09)
	await tw.finished

	# Impact + hit-stop.
	var contact := target_center - n * (target_card.size.y * 0.35 if target_card != null else 30.0)
	var heavy := current_attack >= 8
	CombatFX.melee_impact(self, contact, n, fx_tint(), heavy)
	CombatFX.shake(self, 9.0 if heavy else 5.0, 0.16)
	if is_instance_valid(target_card):
		target_card.play_impact(n, heavy)
	scale = Vector2(1.1, 0.92)
	await get_tree().create_timer(0.06).timeout

	# Recover.
	tw = create_tween()
	tw.set_parallel(true)
	tw.tween_property(self, "global_position", start_gpos, 0.2) \
		.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tw.tween_property(self, "scale", Vector2.ONE, 0.2) \
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tw.tween_property(self, "rotation", 0.0, 0.18)
	await tw.finished

	rotation = 0.0
	scale = Vector2.ONE
	z_index = 0
	arena.remove_child(self)
	container.add_child(self)
	container.move_child(self, slot_idx)


func _shoot_toward(target_center: Vector2, target_card: UnitCard) -> void:
	var start_pos := position
	pivot_offset = size * 0.5
	var my_center := _center()
	var to_target := target_center - my_center
	var n := to_target.normalized() if to_target.length() > 1.0 else Vector2.UP
	var muzzle_pos := my_center + n * size.y * 0.45
	var hit_pos := target_center - n * (target_card.size.y * 0.2 if target_card != null else 20.0)
	z_index = 5

	# Aim: small lean in, slight grow.
	var tw := create_tween()
	tw.set_parallel(true)
	tw.tween_property(self, "position", start_pos + n * 8.0, 0.1) \
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tw.tween_property(self, "scale", Vector2(1.06, 1.06), 0.1)
	await tw.finished

	var wt: int = equipped_weapon.weapon_type
	var shots := 1
	var spread := 0.0
	var width := 3.0
	var kick := 10.0
	match wt:
		WeaponData.WeaponType.SNIPER:
			width = 5.0
			kick = 16.0
		WeaponData.WeaponType.SHOTGUN:
			shots = 5
			spread = 46.0
			width = 2.5
			kick = 18.0
		WeaponData.WeaponType.MACHINE_GUN:
			shots = clampi(maxi(combat_shots, equipped_weapon.get_total_shots()), 2, 8)
			spread = 18.0
			width = 2.5
			kick = 5.0

	var tracer_col := Color(1, 0.9, 0.5)
	if wt == WeaponData.WeaponType.SNIPER:
		tracer_col = Color(0.75, 0.95, 1.0)

	var simultaneous := wt == WeaponData.WeaponType.SHOTGUN
	var side := n.orthogonal()
	for i in range(shots):
		var off := side * randf_range(-spread, spread) if spread > 0.0 else Vector2.ZERO
		var dest := hit_pos + off
		CombatFX.muzzle(self, muzzle_pos, n)
		CombatFX.tracer(self, muzzle_pos, dest, tracer_col, width,
			0.22 if wt == WeaponData.WeaponType.SNIPER else 0.14)
		CombatFX.shot_impact(self, dest, n)
		# Recoil kick away from the target.
		position = start_pos - n * kick
		if not simultaneous:
			CombatFX.shake(self, 3.0 if wt == WeaponData.WeaponType.MACHINE_GUN else 6.0, 0.08)
			if i == 0 and is_instance_valid(target_card):
				target_card.play_impact(n, wt == WeaponData.WeaponType.SNIPER)
			var settle := create_tween()
			settle.tween_property(self, "position", start_pos, 0.05)
			await get_tree().create_timer(0.07 if wt == WeaponData.WeaponType.MACHINE_GUN else 0.05).timeout
	if simultaneous:
		CombatFX.shake(self, 8.0, 0.16)
		if is_instance_valid(target_card):
			target_card.play_impact(n, true)

	await get_tree().create_timer(0.05).timeout
	tw = create_tween()
	tw.set_parallel(true)
	tw.tween_property(self, "position", start_pos, 0.16) \
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tw.tween_property(self, "scale", Vector2.ONE, 0.16)
	await tw.finished
	position = start_pos
	scale = Vector2.ONE
	z_index = 0
	_resort_parent()


# Knockback + white flash at the moment of contact. Fire-and-forget.
func play_impact(dir: Vector2, heavy: bool = false) -> void:
	if not is_inside_tree():
		return
	pivot_offset = size * 0.5
	var start := position
	var push := dir.normalized() * (16.0 if heavy else 10.0)
	highlight_overlay.color = Color(1, 1, 1, 0.9)
	var tw := create_tween()
	tw.set_parallel(true)
	tw.tween_property(self, "position", start + push, 0.05)
	tw.tween_property(self, "rotation", dir.x * 0.08, 0.05)
	tw.tween_property(highlight_overlay, "color", Color(1, 0.15, 0.1, 0.6), 0.08)
	tw.chain().set_parallel(true)
	tw.tween_property(self, "position", start, 0.22) \
		.set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	tw.tween_property(self, "rotation", 0.0, 0.2)
	tw.chain().tween_callback(_resort_parent)


# ── Damage / death ───────────────────────────────────────────────────────────

func flash_hit(lethal: bool) -> void:
	pivot_offset = size * 0.5
	var tw := create_tween()
	tw.set_parallel(true)
	tw.tween_property(highlight_overlay, "color", Color(1, 0.1, 0.05, 0.8 if lethal else 0.65), 0.05)
	tw.tween_property(self, "scale", Vector2(0.86, 0.86) if lethal else Vector2(0.9, 0.9), 0.06)
	await tw.finished
	tw = create_tween()
	tw.set_parallel(true)
	tw.tween_property(highlight_overlay, "color", Color(1, 0, 0, 0), 0.2)
	tw.tween_property(self, "scale", Vector2.ONE, 0.2) \
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	await tw.finished


func apply_divine_shield_break() -> void:
	current_keywords &= ~KeywordFlags.Keyword.DIVINE_SHIELD
	divine_shield_overlay.visible = true
	CombatFX.shield_break(self, _center(), size.x * 0.75)
	CombatFX.number(self, global_position + Vector2(size.x * 0.5, size.y * 0.42),
		"BLOCK", Color(1, 0.9, 0.4))
	pivot_offset = size * 0.5
	var tw := create_tween()
	tw.set_parallel(true)
	tw.tween_property(divine_shield_overlay, "modulate:a", 0.0, 0.25)
	tw.tween_property(self, "scale", Vector2(1.08, 1.08), 0.06)
	tw.chain().tween_property(self, "scale", Vector2.ONE, 0.15)
	await tw.finished
	divine_shield_overlay.modulate.a = 1.0
	divine_shield_overlay.visible = false


func play_death_animation() -> void:
	_fx_health_changed()
	pivot_offset = size * 0.5
	highlight_overlay.color = Color(1, 1, 1, 0.95)
	var tw := create_tween()
	tw.tween_property(self, "scale", Vector2(1.1, 1.1), 0.06)
	await tw.finished
	if is_inside_tree():
		CombatFX.shatter(self, Rect2(global_position, size), _get_race_bg_color().lightened(0.25))
		CombatFX.shake(self, 7.0, 0.18)
	tw = create_tween()
	tw.set_parallel(true)
	tw.tween_property(self, "scale", Vector2(0.4, 0.4), 0.24) \
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	tw.tween_property(self, "rotation", randf_range(-0.5, 0.5), 0.24)
	tw.tween_property(self, "modulate:a", 0.0, 0.22)
	await tw.finished


# Summoned mid-combat: pop in with a ring.
func play_spawn() -> void:
	scale = Vector2(0.2, 0.2)
	modulate.a = 0.0
	await get_tree().process_frame
	if not is_inside_tree():
		return
	pivot_offset = size * 0.5
	CombatFX.ring(self, _center(), fx_tint(), size.x * 0.7, 5.0, 0.35)
	CombatFX.sparkle_up(self, Rect2(global_position, size), fx_tint(), 10)
	var tw := create_tween()
	tw.set_parallel(true)
	tw.tween_property(self, "scale", Vector2.ONE, 0.28) \
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tw.tween_property(self, "modulate:a", 1.0, 0.12)


# ── Buff flashes ─────────────────────────────────────────────────────────────

func flash_triple_spawn() -> void:
	pivot_offset = size * 0.5
	scale = Vector2.ZERO
	highlight_overlay.color = Color(1, 0.85, 0, 0)
	await get_tree().process_frame
	if is_inside_tree():
		pivot_offset = size * 0.5
		CombatFX.ring(self, _center(), Color(1, 0.88, 0.3), size.x, 7.0, 0.5)
		CombatFX.burst(self, _center(), [Color(1, 0.95, 0.5), Color(1, 0.8, 0.2), Color.WHITE],
			24, 360.0, 4.0, 0.6, 300.0)
	var t1 := create_tween()
	t1.set_parallel(true)
	t1.tween_property(self, "scale", Vector2.ONE, 0.3) \
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	t1.tween_property(highlight_overlay, "color", Color(1, 0.85, 0, 0.7), 0.1)
	await t1.finished
	var t2 := create_tween()
	t2.tween_property(highlight_overlay, "color", Color(1, 0.85, 0, 0), 0.35)
	await t2.finished


func flash_surge_source() -> void:
	pivot_offset = size * 0.5
	highlight_overlay.color = Color(0.4, 0.85, 1, 0)
	if is_inside_tree():
		CombatFX.ring(self, _center(), Color(0.45, 0.85, 1), size.x * 0.8, 4.0, 0.4)
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
	if is_inside_tree():
		CombatFX.sparkle_up(self, Rect2(global_position, size), Color(1, 0.85, 0.3), 14)
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


# ── Facelift: gilded frame, heraldic stat badges ─────────────────────────────

var _frame: Panel = null

static func _tier_color(tier: int) -> Color:
	match tier:
		1: return Color(0.72, 0.50, 0.30)   # bronze
		2: return Color(0.78, 0.80, 0.86)   # silver
		3: return Color(0.95, 0.78, 0.40)   # gold
		4: return Color(0.42, 0.88, 0.70)   # verdigris
		5: return Color(0.55, 0.75, 1.00)   # sapphire
		6: return Color(0.86, 0.55, 1.00)   # amethyst
	return Color(1.0, 0.55, 0.30)           # ember (7+)


func _stat_box(bg: Color, rim: Color) -> StyleBoxFlat:
	var b := StyleBoxFlat.new()
	b.bg_color = bg
	b.border_color = rim
	b.set_border_width_all(2)
	b.set_corner_radius_all(14)
	b.corner_detail = 6
	b.shadow_color = Color(0, 0, 0, 0.55)
	b.shadow_size = 4
	b.shadow_offset = Vector2(0, 2)
	b.anti_aliasing = true
	return b


func _apply_facelift() -> void:
	# Frame drawn over the art, under the badges.
	_frame = Panel.new()
	_frame.name = "GildedFrame"
	_frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_frame.anchor_right = 1.0
	_frame.anchor_bottom = 1.0
	_frame.offset_bottom = -12.0
	_frame.add_theme_stylebox_override("panel", StyleBoxEmpty.new())
	add_child(_frame)
	move_child(_frame, art_drawer.get_index() + 1)

	var stat_font: Font = UITheme.font_display_bold
	$AttackBadge.add_theme_stylebox_override("panel",
		_stat_box(Color(0.86, 0.60, 0.16), Color(0.32, 0.18, 0.04)))
	$HealthBadge.add_theme_stylebox_override("panel",
		_stat_box(Color(0.70, 0.10, 0.12), Color(0.30, 0.03, 0.04)))
	for lbl: Label in [attack_label, health_label]:
		lbl.add_theme_font_override("font", stat_font)
		lbl.add_theme_font_size_override("font_size", 18)
		lbl.add_theme_color_override("font_outline_color", Color(0.10, 0.04, 0.02, 1.0))
		lbl.add_theme_constant_override("outline_size", 5)

	# Buy button: emerald seal with a gilt rim
	var bn := _stat_box(Color(0.10, 0.55, 0.30), Color(0.95, 0.80, 0.45))
	bn.set_corner_radius_all(20)
	var bh := bn.duplicate() as StyleBoxFlat
	bh.bg_color = Color(0.16, 0.72, 0.40)
	bh.shadow_color = Color(0.4, 1.0, 0.6, 0.35)
	bh.shadow_size = 8
	var bp := bn.duplicate() as StyleBoxFlat
	bp.bg_color = Color(0.06, 0.40, 0.20)
	buy_button.add_theme_stylebox_override("normal", bn)
	buy_button.add_theme_stylebox_override("hover", bh)
	buy_button.add_theme_stylebox_override("pressed", bp)
	buy_button.add_theme_font_override("font", UITheme.font_bold)
	buy_button.add_theme_font_size_override("font_size", 26)

	# Selection: arcane glow instead of a white outline
	var sel := StyleBoxFlat.new()
	sel.draw_center = false
	sel.set_border_width_all(3)
	sel.set_corner_radius_all(9)
	sel.border_color = UITheme.ARCANE
	sel.shadow_color = Color(UITheme.ARCANE, 0.45)
	sel.shadow_size = 10
	select_border.add_theme_stylebox_override("panel", sel)

	# Taunt: heavy iron rim
	var ta := StyleBoxFlat.new()
	ta.draw_center = false
	ta.set_border_width_all(4)
	ta.set_corner_radius_all(9)
	ta.border_color = Color(0.55, 0.58, 0.64)
	ta.shadow_color = Color(0, 0, 0, 0.5)
	ta.shadow_size = 4
	taunt_border.add_theme_stylebox_override("panel", ta)

	# Hover name plate
	var np := StyleBoxFlat.new()
	np.bg_color = Color(0.04, 0.03, 0.07, 0.82)
	np.border_color = Color(UITheme.GOLD_DIM, 0.8)
	np.border_width_top = 1
	np.border_width_bottom = 1
	hover_name_panel.add_theme_stylebox_override("panel", np)
	name_label.add_theme_font_override("font", UITheme.font_bold)
	name_label.add_theme_color_override("font_color", UITheme.GOLD_HI)
	preview_name_label.add_theme_font_override("font", UITheme.font_display_bold)
	preview_name_label.add_theme_font_size_override("font_size", 16)
	preview_body_label.add_theme_font_size_override("font_size", 13)
	preview_body_label.add_theme_color_override("font_color", UITheme.TEXT)


func _resort_parent() -> void:
	var p := get_parent()
	if p is Container:
		(p as Container).queue_sort()
