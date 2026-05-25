class_name UnitData
extends Resource

@export var display_name: String = "Unit"
@export var base_attack: int = 1
@export var base_health: int = 1
@export var keywords: int = 0
@export var art_texture: Texture2D = null
@export var race: int = 0           # RaceType.Race
@export var human_effect: int = 0   # HumanEffect.Effect
@export var mage_effect: int = 0    # MageEffect.Effect
@export var goblin_effect: int = 0   # GoblinEffect.Effect
@export var generic_effect: int = 0 # GenericEffect.Effect
@export var elf_effect: int = 0        # ElfEffect.Effect
@export var aztec_effect: int = 0      # AztecEffect.Effect
@export var construct_effect: int = 0  # ConstructEffect.Effect
@export var reaper_effect: int = 0     # ReaperEffect.Effect
@export var myconid_effect: int = 0    # MyconidEffect.Effect
@export var covenant_effect: int = 0  # CovenantEffect.Effect
@export var satyr_effect: int = 0     # SatyrEffect.Effect
@export var satyr_color: int = 0      # SatyrColor.Hue
@export var is_satyr_token: bool = false  # tokens don't trigger Prismatic Reveler's replacement effect
@export var tier: int = 1
@export var default_weapon: WeaponData = null
@export var pre_equipped_spell: SpellData = null
