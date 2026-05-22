class_name UnitArtDrawer
extends Control

var _data: UnitData = null

func setup(unit_data: UnitData) -> void:
	_data = unit_data
	queue_redraw()

func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED:
		queue_redraw()

func _draw() -> void:
	if _data == null:
		return
	if _data.art_texture != null:
		draw_texture_rect(_data.art_texture, Rect2(Vector2.ZERO, size), false)
		return
	_draw_procedural()

func _draw_procedural() -> void:
	var w := size.x
	var h := size.y
	if w < 1.0 or h < 1.0:
		return
	var cx := w * 0.5
	var cy := h * 0.5
	_draw_background(w, h)
	_draw_unit_shape(cx, cy, w, h)

# ── Background ─────────────────────────────────────────────────────────────────

func _draw_background(w: float, h: float) -> void:
	var c := _race_color()
	var steps := 6
	for i in range(steps):
		var t := float(i) / (steps - 1)
		var mx := t * (w * 0.32)
		var my := t * (h * 0.28)
		var shade := c.lerp(c.lightened(0.38), t)
		draw_rect(Rect2(mx, my, w - mx * 2.0, h - my * 2.0), shade)

func _race_color() -> Color:
	match _data.race:
		RaceType.Race.HUMAN:     return Color(0.30, 0.14, 0.04)  # dark leather brown
		RaceType.Race.GOBLIN:    return Color(0.26, 0.24, 0.02)  # dark olive-gold
		RaceType.Race.ELF:       return Color(0.04, 0.24, 0.06)  # deep forest green
		RaceType.Race.COVENANT:  return Color(0.04, 0.22, 0.28)  # dark teal
		RaceType.Race.MAGE:      return Color(0.08, 0.10, 0.44)  # deep indigo
		RaceType.Race.CONSTRUCT: return Color(0.14, 0.18, 0.22)  # gunmetal
		RaceType.Race.REAPER:    return Color(0.14, 0.04, 0.24)  # deep purple
		RaceType.Race.MYCONID:   return Color(0.24, 0.04, 0.20)  # dark fuchsia
		RaceType.Race.AZTEC:     return Color(0.22, 0.14, 0.02)  # dark bronze
	return Color(0.18, 0.20, 0.28)

func _fg_color() -> Color:
	match _data.race:
		RaceType.Race.HUMAN:     return Color(0.96, 0.82, 0.56)  # warm cream
		RaceType.Race.GOBLIN:    return Color(0.96, 0.95, 0.18)  # acid yellow
		RaceType.Race.ELF:       return Color(0.54, 1.00, 0.56)  # bright mint
		RaceType.Race.COVENANT:  return Color(0.34, 1.00, 0.96)  # bright cyan
		RaceType.Race.MAGE:      return Color(0.60, 0.80, 1.00)  # sky blue
		RaceType.Race.CONSTRUCT: return Color(0.78, 0.86, 0.94)  # steel silver
		RaceType.Race.REAPER:    return Color(0.84, 0.64, 1.00)  # violet
		RaceType.Race.MYCONID:   return Color(1.00, 0.58, 0.88)  # hot pink
		RaceType.Race.AZTEC:     return Color(1.00, 0.84, 0.14)  # bright gold
	return Color(0.84, 0.84, 0.92)

# ── Shape dispatch ─────────────────────────────────────────────────────────────

func _draw_unit_shape(cx: float, cy: float, w: float, h: float) -> void:
	var fg := _fg_color()
	var shd := fg.darkened(0.35)
	match _data.display_name:
		"Grunt", "Warrior":   _draw_sword(cx, cy, w, h, fg, shd)
		"Brawler":            _draw_brawler(cx, cy, w, h, fg, shd)
		"Gunslinger":         _draw_pistol(cx, cy, w, h, fg, shd)
		"Ranger":             _draw_bow(cx, cy, w, h, fg, shd)
		"Sharpshooter":       _draw_rifle(cx, cy, w, h, fg, shd)
		"Recruit":            _draw_recruit(cx, cy, w, h, fg, shd)
		"Arms Dealer":        _draw_arms_dealer(cx, cy, w, h, fg, shd)
		"Demolitionist":      _draw_bomb(cx, cy, w, h, fg, shd)
		"Gunner":             _draw_minigun(cx, cy, w, h, fg, shd)
		"Commander":          _draw_star(cx, cy, w, h, fg, shd)
		"Footman", "Defender": _draw_shield(cx, cy, w, h, fg, shd)
		"Breacher":           _draw_breacher(cx, cy, w, h, fg, shd)
		"Heavy":              _draw_heavy(cx, cy, w, h, fg, shd)
		"Spellbinder":        _draw_spellbinder(cx, cy, w, h, fg, shd)
		"Runecaller":         _draw_runecaller(cx, cy, w, h, fg, shd)
		"Arcane Conduit":     _draw_arcane_conduit(cx, cy, w, h, fg, shd)
		"Wellspring":         _draw_wellspring(cx, cy, w, h, fg, shd)
		"Amplifier":          _draw_amplifier(cx, cy, w, h, fg, shd)
		"Arcanist":           _draw_arcanist(cx, cy, w, h, fg, shd)
		"Channeler":          _draw_channeler(cx, cy, w, h, fg, shd)
		"Echo Caster":        _draw_echo_caster(cx, cy, w, h, fg, shd)
		"Hexweaver":          _draw_hexweaver(cx, cy, w, h, fg, shd)
		"Novice":             _draw_novice(cx, cy, w, h, fg, shd)
		"Oracle":             _draw_oracle(cx, cy, w, h, fg, shd)
		"Spellwright":        _draw_spellwright(cx, cy, w, h, fg, shd)
		"Viper":              _draw_viper(cx, cy, w, h, fg, shd)
		"Shielded Bot":       _draw_robot(cx, cy, w, h, fg, shd)
		"Harvest Golem":      _draw_golem(cx, cy, w, h, fg, shd)
		"Grave Conductor":    _draw_scythe(cx, cy, w, h, fg, shd)
		"Surge Master":       _draw_lightning(cx, cy, w, h, fg, shd)
		"Goblin Peon":        _draw_goblin_peon(cx, cy, w, h, fg, shd)
		"Mob Runt":           _draw_sprint(cx, cy, w, h, fg, shd)
		"Sneak":              _draw_dagger(cx, cy, w, h, fg, shd)
		"Pack Leader":        _draw_paw(cx, cy, w, h, fg, shd)
		"Scrap Bomber":       _draw_scrap_bomb(cx, cy, w, h, fg, shd)
		"Brood Witch":        _draw_cauldron(cx, cy, w, h, fg, shd)
		"Warchief":           _draw_axe(cx, cy, w, h, fg, shd)
		"Litter Lord":        _draw_chain(cx, cy, w, h, fg, shd)
		"Rabble Riser":       _draw_fist(cx, cy, w, h, fg, shd)
		"Taskmaster":         _draw_taskmaster(cx, cy, w, h, fg, shd)
		"Chaos Caller":       _draw_vortex(cx, cy, w, h, fg, shd)
		"Bomb King":          _draw_crown(cx, cy, w, h, fg, shd)
		"Rage Brand":         _draw_flame(cx, cy, w, h, fg, shd)
		"Reckoner":           _draw_scales(cx, cy, w, h, fg, shd)
		"Witch Doctor":       _draw_skull(cx, cy, w, h, fg, shd)
		"Grub Grabber":       _draw_claw(cx, cy, w, h, fg, shd)
		"Wraith":             _draw_wraith(cx, cy, w, h, fg, shd)
		"Pale Shroud":        _draw_pale_shroud(cx, cy, w, h, fg, shd)
		"Dread Knell":        _draw_dread_knell(cx, cy, w, h, fg, shd)
		"Grave Stalker":      _draw_grave_stalker(cx, cy, w, h, fg, shd)
		"Void Wraith":        _draw_void_wraith(cx, cy, w, h, fg, shd)
		"Pale Reaper":        _draw_pale_reaper(cx, cy, w, h, fg, shd)
		"Dread Seer":         _draw_dread_seer(cx, cy, w, h, fg, shd)
		"Doom Herald":        _draw_doom_herald(cx, cy, w, h, fg, shd)
		"Shade Stalker":      _draw_shade_stalker(cx, cy, w, h, fg, shd)
		"Wail Specter":       _draw_wail_specter(cx, cy, w, h, fg, shd)
		"Dread Lord":         _draw_dread_lord(cx, cy, w, h, fg, shd)
		"Grave Collector":    _draw_grave_collector(cx, cy, w, h, fg, shd)
		"Soul Harvester":     _draw_soul_harvester(cx, cy, w, h, fg, shd)
		"Rift Caller":        _draw_rift_caller(cx, cy, w, h, fg, shd)
		"Death Sovereign":    _draw_death_sovereign(cx, cy, w, h, fg, shd)
		"Grave Pact":         _draw_grave_pact(cx, cy, w, h, fg, shd)
		"Shadow":             _draw_shadow_token(cx, cy, w, h, fg, shd)
		"Duelist":            _draw_duelist(cx, cy, w, h, fg, shd)
		"Warlord":            _draw_warlord(cx, cy, w, h, fg, shd)
		"Quartermaster":      _draw_quartermaster(cx, cy, w, h, fg, shd)
		"Acolyte":            _draw_acolyte(cx, cy, w, h, fg, shd)
		"Familiar":           _draw_familiar(cx, cy, w, h, fg, shd)
		"Coin Sage":          _draw_coin_sage(cx, cy, w, h, fg, shd)
		"Harrower":           _draw_harrower(cx, cy, w, h, fg, shd)
		"Warchanter":         _draw_warchanter(cx, cy, w, h, fg, shd)
		"Warden":             _draw_warden(cx, cy, w, h, fg, shd)
		"Runic Scribe":       _draw_runic_scribe(cx, cy, w, h, fg, shd)
		"Elf Scout":          _draw_elf_scout(cx, cy, w, h, fg, shd)
		"Thornguard":         _draw_thornguard(cx, cy, w, h, fg, shd)
		"Duskblade":          _draw_duskblade(cx, cy, w, h, fg, shd)
		"Spiritbark":         _draw_spiritbark(cx, cy, w, h, fg, shd)
		"Verdant Archer":     _draw_verdant_archer(cx, cy, w, h, fg, shd)
		"Moonsong":           _draw_moonsong(cx, cy, w, h, fg, shd)
		"Fernweave":          _draw_fernweave(cx, cy, w, h, fg, shd)
		"Soul Tender":        _draw_soul_tender(cx, cy, w, h, fg, shd)
		"Thornborn":          _draw_thornborn(cx, cy, w, h, fg, shd)
		"Dreamhunter":        _draw_dreamhunter(cx, cy, w, h, fg, shd)
		"Pale Warden":        _draw_pale_warden(cx, cy, w, h, fg, shd)
		"Ashveil":            _draw_ashveil(cx, cy, w, h, fg, shd)
		"Root Caller":        _draw_root_caller(cx, cy, w, h, fg, shd)
		"The Dreamer":        _draw_the_dreamer(cx, cy, w, h, fg, shd)
		"Ancient Grove":      _draw_ancient_grove(cx, cy, w, h, fg, shd)
		"Tether":             _draw_tether(cx, cy, w, h, fg, shd)
		"Seeker":             _draw_seeker(cx, cy, w, h, fg, shd)
		"Pact Kin":           _draw_pact_kin(cx, cy, w, h, fg, shd)
		"Fury Kin":           _draw_fury_kin(cx, cy, w, h, fg, shd)
		"Weave Kin":          _draw_weave_kin(cx, cy, w, h, fg, shd)
		"Oath Binder":        _draw_oath_binder(cx, cy, w, h, fg, shd)
		"Bond Warden":        _draw_bond_warden(cx, cy, w, h, fg, shd)
		"Martyr Kin":         _draw_martyr_kin(cx, cy, w, h, fg, shd)
		"Rite Herald":        _draw_rite_herald(cx, cy, w, h, fg, shd)
		"Vow Guard":          _draw_vow_guard(cx, cy, w, h, fg, shd)
		"Bond Shatter":       _draw_bond_shatter(cx, cy, w, h, fg, shd)
		"Rite Sage":          _draw_rite_sage(cx, cy, w, h, fg, shd)
		"Soul Tether":        _draw_soul_tether(cx, cy, w, h, fg, shd)
		"Chain Hunter":       _draw_chain_hunter(cx, cy, w, h, fg, shd)
		"Grief Kin":          _draw_grief_kin(cx, cy, w, h, fg, shd)
		"Rite Spawner":       _draw_rite_spawner(cx, cy, w, h, fg, shd)
		"Covenantling":       _draw_covenantling(cx, cy, w, h, fg, shd)
		"Winder":             _draw_winder(cx, cy, w, h, fg, shd)
		"Sporekeeper":        _draw_sporekeeper(cx, cy, w, h, fg, shd)
		"Parasite":           _draw_parasite(cx, cy, w, h, fg, shd)
		"Sporeling":          _draw_sporeling(cx, cy, w, h, fg, shd)
		"Myco Cap":           _draw_myco_cap(cx, cy, w, h, fg, shd)
		"Bloom":              _draw_bloom(cx, cy, w, h, fg, shd)
		"Spore Vent":         _draw_spore_vent(cx, cy, w, h, fg, shd)
		"Mycelium":           _draw_mycelium(cx, cy, w, h, fg, shd)
		"Decomposer":         _draw_decomposer(cx, cy, w, h, fg, shd)
		"Hyphae":             _draw_hyphae(cx, cy, w, h, fg, shd)
		"Sporefront":         _draw_sporefront(cx, cy, w, h, fg, shd)
		"Spore Hoarder":      _draw_spore_hoarder(cx, cy, w, h, fg, shd)
		"Sporeguard":         _draw_sporeguard(cx, cy, w, h, fg, shd)
		"Myco Sage":          _draw_myco_sage(cx, cy, w, h, fg, shd)
		"Cultivator":         _draw_cultivator(cx, cy, w, h, fg, shd)
		"Spore Sovereign":    _draw_spore_sovereign(cx, cy, w, h, fg, shd)
		"Fungal Ascendant":   _draw_fungal_ascendant(cx, cy, w, h, fg, shd)
		_:                    _draw_default(cx, cy, w, h, fg, shd)

# ── Sword (Grunt / Warrior) ────────────────────────────────────────────────────

func _draw_sword(cx: float, cy: float, w: float, h: float, fg: Color, shd: Color) -> void:
	var bw := w * 0.11
	var bh := h * 0.50
	var by := cy - bh * 0.5 - h * 0.07
	# Blade shadow
	draw_rect(Rect2(cx - bw*0.5 + 2, by + 2, bw, bh), shd)
	# Blade
	draw_rect(Rect2(cx - bw*0.5, by, bw, bh), fg)
	# Tip
	draw_polygon(PackedVector2Array([
		Vector2(cx, by - bw * 1.7),
		Vector2(cx - bw*0.5, by),
		Vector2(cx + bw*0.5, by),
	]), PackedColorArray([fg, fg, fg]))
	# Crossguard
	var gw := w * 0.44
	var gh := h * 0.055
	var gy := cy + h * 0.07
	draw_rect(Rect2(cx - gw*0.5 + 2, gy + 2, gw, gh), shd)
	draw_rect(Rect2(cx - gw*0.5, gy, gw, gh), shd.lightened(0.2))
	# Handle
	draw_rect(Rect2(cx - w*0.048 + 1, gy + gh + 1, w*0.096, h*0.18), shd)
	draw_rect(Rect2(cx - w*0.048, gy + gh, w*0.096, h*0.18), fg.lerp(shd, 0.5))
	# Pommel
	draw_circle(Vector2(cx + 1, gy + gh + h*0.19), w * 0.065, shd)
	draw_circle(Vector2(cx, gy + gh + h*0.18), w * 0.065, fg.lerp(shd, 0.25))

# ── Brawler ────────────────────────────────────────────────────────────────────

func _draw_brawler(cx: float, cy: float, w: float, h: float, fg: Color, shd: Color) -> void:
	for i in range(2):
		var side := -1.0 if i == 0 else 1.0
		var fcx := cx + side * w * 0.22
		draw_circle(Vector2(fcx + 2, cy + 2), w * 0.19, shd)
		draw_circle(Vector2(fcx, cy), w * 0.19, fg)
		draw_circle(Vector2(fcx - side * w*0.04, cy - h*0.04), w * 0.08, fg.lightened(0.28))
	draw_line(Vector2(cx - w*0.30, cy + h*0.07), Vector2(cx + w*0.30, cy + h*0.07), shd, 3.0)

# ── Pistol (Gunslinger) ────────────────────────────────────────────────────────

func _draw_pistol(cx: float, cy: float, w: float, h: float, fg: Color, shd: Color) -> void:
	var ox := cx - w * 0.04
	var oy := cy + h * 0.04
	draw_rect(Rect2(ox - w*0.32 + 2, oy - h*0.08 + 2, w*0.52, h*0.10), shd)
	draw_rect(Rect2(ox - w*0.32, oy - h*0.12, w*0.48, h*0.08), shd.lightened(0.18))
	draw_rect(Rect2(ox - w*0.32, oy - h*0.04, w*0.52, h*0.10), fg)
	draw_rect(Rect2(ox + w*0.14, oy - h*0.04, w*0.11, h*0.26), fg.darkened(0.15))
	draw_arc(Vector2(ox + w*0.10, oy + h*0.14), h*0.09, PI * 0.1, PI * 0.9, 12, shd, 3.5)
	draw_rect(Rect2(ox - w*0.22, oy - h*0.14, w*0.06, h*0.03), fg.lightened(0.2))

# ── Rifle (Sharpshooter) ───────────────────────────────────────────────────────

func _draw_rifle(cx: float, cy: float, w: float, h: float, fg: Color, shd: Color) -> void:
	var oy := cy + h * 0.03
	draw_rect(Rect2(cx - w*0.44 + 2, oy - h*0.035 + 2, w*0.70, h*0.07), shd)
	draw_rect(Rect2(cx - w*0.44, oy - h*0.035, w*0.70, h*0.07), fg)
	draw_rect(Rect2(cx - w*0.20, oy - h*0.13, w*0.24, h*0.10), shd)
	draw_circle(Vector2(cx - w*0.08, oy - h*0.08), w * 0.073, Color(0.3, 0.7, 1.0, 0.9))
	draw_circle(Vector2(cx - w*0.08, oy - h*0.08), w * 0.038, Color(0.85, 0.96, 1.0))
	draw_rect(Rect2(cx + w*0.24, oy - h*0.11, w*0.16, h*0.26), fg.darkened(0.18))

# ── Bow (Ranger) ───────────────────────────────────────────────────────────────

func _draw_bow(cx: float, cy: float, w: float, h: float, fg: Color, shd: Color) -> void:
	draw_arc(Vector2(cx - w*0.06, cy), w * 0.30, -PI * 0.55, PI * 0.55, 24, shd, 7.0)
	draw_arc(Vector2(cx - w*0.06, cy), w * 0.30, -PI * 0.55, PI * 0.55, 24, fg, 5.0)
	draw_line(Vector2(cx - w*0.06, cy - h*0.27), Vector2(cx - w*0.06, cy + h*0.27), fg.lightened(0.4), 1.5)
	draw_line(Vector2(cx - w*0.36, cy - h*0.04), Vector2(cx + w*0.28, cy - h*0.04), fg.lightened(0.2), 2.5)
	draw_polygon(PackedVector2Array([
		Vector2(cx + w*0.28, cy - h*0.04),
		Vector2(cx + w*0.14, cy - h*0.085),
		Vector2(cx + w*0.14, cy + h*0.005),
	]), PackedColorArray([fg, fg, fg]))

# ── Recruit ────────────────────────────────────────────────────────────────────

func _draw_recruit(cx: float, cy: float, w: float, h: float, fg: Color, shd: Color) -> void:
	draw_circle(Vector2(cx + 2, cy - h*0.29 + 2), w * 0.13, shd)
	draw_circle(Vector2(cx, cy - h*0.29), w * 0.13, fg)
	draw_arc(Vector2(cx, cy - h*0.29), w * 0.13, -PI, 0, 12, shd.lightened(0.12), 6.0)
	draw_rect(Rect2(cx - w*0.11 + 1, cy - h*0.17 + 1, w*0.22, h*0.30), shd)
	draw_rect(Rect2(cx - w*0.11, cy - h*0.17, w*0.22, h*0.30), fg.darkened(0.1))
	draw_rect(Rect2(cx - w*0.25, cy - h*0.15, w*0.14, h*0.07), fg.darkened(0.15))
	draw_rect(Rect2(cx + w*0.11, cy - h*0.15, w*0.14, h*0.07), fg.darkened(0.15))
	draw_rect(Rect2(cx - w*0.12, cy + h*0.13, w*0.10, h*0.22), fg.darkened(0.2))
	draw_rect(Rect2(cx + w*0.02, cy + h*0.13, w*0.10, h*0.22), fg.darkened(0.2))

# ── Arms Dealer ────────────────────────────────────────────────────────────────

func _draw_arms_dealer(cx: float, cy: float, w: float, h: float, fg: Color, shd: Color) -> void:
	var guns := [[cy - h*0.16, fg], [cy, fg.lightened(0.15)], [cy + h*0.16, fg.darkened(0.1)]]
	for g in guns:
		var gy: float = g[0]
		var gc: Color = g[1]
		draw_rect(Rect2(cx - w*0.37 + 1, gy - h*0.036 + 1, w*0.58, h*0.072), shd)
		draw_rect(Rect2(cx - w*0.37, gy - h*0.036, w*0.58, h*0.072), gc)
	draw_circle(Vector2(cx + w*0.32, cy - h*0.19), w * 0.082, Color(1, 0.85, 0.2))
	draw_circle(Vector2(cx + w*0.32, cy - h*0.19), w * 0.042, shd)

# ── Bomb (Demolitionist) ───────────────────────────────────────────────────────

func _draw_bomb(cx: float, cy: float, w: float, h: float, fg: Color, shd: Color) -> void:
	var bcy := cy + h * 0.08
	draw_circle(Vector2(cx + 3, bcy + 3), w * 0.28, shd)
	draw_circle(Vector2(cx, bcy), w * 0.28, shd.lightened(0.1))
	draw_circle(Vector2(cx, bcy), w * 0.22, fg)
	draw_circle(Vector2(cx - w*0.08, bcy - h*0.08), w * 0.09, fg.lightened(0.36))
	draw_line(Vector2(cx + w*0.20, bcy - h*0.18), Vector2(cx + w*0.32, bcy - h*0.34), fg.darkened(0.3), 4.0)
	draw_line(Vector2(cx + w*0.32, bcy - h*0.34), Vector2(cx + w*0.26, bcy - h*0.44), fg.darkened(0.3), 4.0)
	draw_circle(Vector2(cx + w*0.26, bcy - h*0.44), w * 0.055, Color(1, 0.9, 0.1))
	draw_circle(Vector2(cx + w*0.26, bcy - h*0.44), w * 0.030, Color(1, 1, 1))

# ── Minigun (Gunner) ───────────────────────────────────────────────────────────

func _draw_minigun(cx: float, cy: float, w: float, h: float, fg: Color, shd: Color) -> void:
	for i in range(3):
		var oy := (i - 1) * h * 0.10
		var bc := fg if i == 1 else fg.darkened(0.15)
		draw_rect(Rect2(cx - w*0.42 + 1, cy + oy - h*0.040 + 1, w*0.53, h*0.078), shd)
		draw_rect(Rect2(cx - w*0.42, cy + oy - h*0.040, w*0.53, h*0.078), bc)
		draw_circle(Vector2(cx - w*0.42, cy + oy), h * 0.039, bc.darkened(0.3))
	draw_rect(Rect2(cx + w*0.09 + 1, cy - h*0.18 + 1, w*0.20, h*0.36), shd)
	draw_rect(Rect2(cx + w*0.09, cy - h*0.18, w*0.20, h*0.36), fg.darkened(0.1))
	draw_rect(Rect2(cx + w*0.14, cy + h*0.16, w*0.10, h*0.20), shd.lightened(0.1))

# ── Star (Commander) ───────────────────────────────────────────────────────────

func _draw_star(cx: float, cy: float, w: float, _h: float, fg: Color, shd: Color) -> void:
	var r_out := w * 0.30
	var r_in  := w * 0.13
	var pts     := PackedVector2Array()
	var cols    := PackedColorArray()
	var shd_pts := PackedVector2Array()
	var shd_cols:= PackedColorArray()
	for i in range(10):
		var angle := (i * PI / 5.0) - PI * 0.5
		var r := r_out if i % 2 == 0 else r_in
		pts.append(Vector2(cx + r * cos(angle), cy + r * sin(angle)))
		cols.append(fg if i % 2 == 0 else fg.darkened(0.1))
		shd_pts.append(Vector2(cx + 2 + r * cos(angle), cy + 2 + r * sin(angle)))
		shd_cols.append(shd)
	draw_polygon(shd_pts, shd_cols)
	draw_polygon(pts, cols)
	draw_circle(Vector2(cx, cy), w * 0.07, shd.lightened(0.4))

# ── Shield (Footman / Defender) ────────────────────────────────────────────────

func _draw_shield(cx: float, cy: float, w: float, h: float, fg: Color, shd: Color) -> void:
	var sw := w * 0.52
	var sh := h * 0.62
	var sy := cy - sh * 0.48
	var pts := PackedVector2Array([
		Vector2(cx - sw*0.5, sy),
		Vector2(cx + sw*0.5, sy),
		Vector2(cx + sw*0.5, sy + sh*0.52),
		Vector2(cx, sy + sh),
		Vector2(cx - sw*0.5, sy + sh*0.52),
	])
	var shd_pts := PackedVector2Array()
	for p in pts:
		shd_pts.append(p + Vector2(2, 2))
	draw_polygon(shd_pts, PackedColorArray([shd, shd, shd, shd, shd]))
	draw_polygon(pts, PackedColorArray([fg, fg, fg, fg, fg]))
	draw_circle(Vector2(cx, cy - h*0.02), w * 0.10, shd)
	draw_circle(Vector2(cx, cy - h*0.02), w * 0.07, fg.lightened(0.3))
	draw_rect(Rect2(cx - sw*0.42, cy - h*0.10, sw*0.84, sh*0.065), shd.lightened(0.15))

# ── Breacher ───────────────────────────────────────────────────────────────────

func _draw_breacher(cx: float, cy: float, w: float, h: float, fg: Color, shd: Color) -> void:
	draw_rect(Rect2(cx - w*0.07 + 1, cy - h*0.45 + 1, w*0.14, h*0.60), shd)
	draw_rect(Rect2(cx - w*0.07, cy - h*0.45, w*0.14, h*0.60), fg.darkened(0.15))
	draw_rect(Rect2(cx - w*0.28 + 1, cy - h*0.45 + 1, w*0.56, h*0.25), shd)
	draw_rect(Rect2(cx - w*0.28, cy - h*0.45, w*0.56, h*0.25), fg)
	for i in range(3):
		draw_circle(Vector2(cx + (i - 1) * w * 0.18, cy - h*0.34), w * 0.04, fg.lightened(0.3))

# ── Heavy ──────────────────────────────────────────────────────────────────────

func _draw_heavy(cx: float, cy: float, w: float, h: float, fg: Color, shd: Color) -> void:
	draw_rect(Rect2(cx - w*0.30 + 1, cy - h*0.12 + 1, w*0.60, h*0.46), shd)
	draw_rect(Rect2(cx - w*0.30, cy - h*0.12, w*0.60, h*0.46), fg.darkened(0.1))
	draw_rect(Rect2(cx - w*0.38, cy - h*0.22, w*0.76, h*0.12), fg)
	draw_circle(Vector2(cx + 1, cy - h*0.30 + 1), w * 0.13, shd)
	draw_circle(Vector2(cx, cy - h*0.30), w * 0.13, fg)
	draw_rect(Rect2(cx - w*0.09, cy - h*0.35, w*0.18, h*0.06), shd.lightened(0.1))
	draw_rect(Rect2(cx - w*0.07, cy - h*0.34, w*0.14, h*0.04), Color(0.2, 0.9, 1.0, 0.85))
	draw_rect(Rect2(cx - w*0.44 + 1, cy + h*0.05 + 1, w*0.52, h*0.11), shd)
	draw_rect(Rect2(cx - w*0.44, cy + h*0.05, w*0.52, h*0.11), shd.lightened(0.2))

# ── Spellbinder ────────────────────────────────────────────────────────────────

func _draw_spellbinder(cx: float, cy: float, w: float, h: float, fg: Color, shd: Color) -> void:
	draw_circle(Vector2(cx + 2, cy - h*0.10 + 2), w * 0.26, shd)
	draw_circle(Vector2(cx, cy - h*0.10), w * 0.26, fg.darkened(0.1))
	draw_circle(Vector2(cx, cy - h*0.10), w * 0.18, fg)
	draw_circle(Vector2(cx - w*0.06, cy - h*0.15), w * 0.08, Color(1, 1, 1, 0.85))
	draw_rect(Rect2(cx - w*0.035, cy + h*0.14, w*0.07, h*0.32), shd)
	for i in range(3):
		var angle := (float(i) / 3.0) * TAU
		var sp := Vector2(cx + w*0.26 * cos(angle), (cy - h*0.10) + w*0.26*0.5 * sin(angle))
		draw_circle(sp, w * 0.04, Color(0.80, 0.60, 1.0, 0.9))

# ── Runecaller ─────────────────────────────────────────────────────────────────

func _draw_runecaller(cx: float, cy: float, w: float, h: float, fg: Color, _shd: Color) -> void:
	var rune_pos := [
		Vector2(cx, cy - h*0.35),
		Vector2(cx - w*0.22, cy - h*0.06),
		Vector2(cx + w*0.22, cy - h*0.06),
		Vector2(cx, cy + h*0.20),
	]
	for i in range(rune_pos.size()):
		var j := (i + 1) % rune_pos.size()
		draw_line(rune_pos[i], rune_pos[j], fg.darkened(0.25), 1.5)
	for rp in rune_pos:
		var rs := w * 0.10
		draw_polygon(PackedVector2Array([
			rp + Vector2(0, -rs*1.4), rp + Vector2(rs, 0),
			rp + Vector2(0, rs*1.4),  rp + Vector2(-rs, 0),
		]), PackedColorArray([fg, fg, fg, fg]))
		draw_circle(rp, rs * 0.44, Color(0.9, 0.75, 1.0, 0.9))

# ── Arcane Conduit ─────────────────────────────────────────────────────────────

func _draw_arcane_conduit(cx: float, cy: float, w: float, h: float, fg: Color, shd: Color) -> void:
	for i in range(4):
		var r := w * (0.10 + i * 0.065)
		var c := fg.lerp(shd, float(i) / 4.0)
		draw_arc(Vector2(cx, cy - h*0.08), r, 0, TAU, 32, c, 3.5 - i * 0.5)
	draw_circle(Vector2(cx + 1, cy - h*0.08 + 1), w * 0.09, shd)
	draw_circle(Vector2(cx, cy - h*0.08), w * 0.09, fg.lightened(0.4))
	draw_circle(Vector2(cx - w*0.03, cy - h*0.11), w * 0.04, Color(1, 1, 1, 0.9))

# ── Wellspring ─────────────────────────────────────────────────────────────────

func _draw_wellspring(cx: float, cy: float, w: float, h: float, fg: Color, shd: Color) -> void:
	draw_rect(Rect2(cx - w*0.28 + 1, cy + h*0.04 + 1, w*0.56, h*0.30), shd)
	draw_rect(Rect2(cx - w*0.28, cy + h*0.04, w*0.56, h*0.30), fg.darkened(0.2))
	draw_rect(Rect2(cx - w*0.30, cy + h*0.01, w*0.60, h*0.05), fg)
	draw_rect(Rect2(cx - w*0.24, cy + h*0.07, w*0.48, h*0.04), Color(0.5, 0.85, 1.0, 0.9))
	draw_circle(Vector2(cx + 1, cy - h*0.20 + 1), w * 0.20, shd)
	draw_circle(Vector2(cx, cy - h*0.20), w * 0.20, fg)
	draw_circle(Vector2(cx, cy - h*0.20), w * 0.14, Color(0.65, 0.90, 1.0, 0.85))
	draw_circle(Vector2(cx - w*0.06, cy - h*0.25), w * 0.07, Color(1, 1, 1, 0.80))

# ── Viper ──────────────────────────────────────────────────────────────────────

func _draw_viper(cx: float, cy: float, w: float, h: float, fg: Color, shd: Color) -> void:
	var pts: Array[Vector2] = [
		Vector2(cx + w*0.04, cy - h*0.38),
		Vector2(cx + w*0.22, cy - h*0.16),
		Vector2(cx - w*0.14, cy + h*0.04),
		Vector2(cx + w*0.10, cy + h*0.24),
		Vector2(cx - w*0.05, cy + h*0.42),
	]
	for i in range(pts.size() - 1):
		var r := lerpf(12.0, 6.0, float(i) / pts.size())
		draw_line(pts[i] + Vector2(2,2), pts[i+1] + Vector2(2,2), shd, r)
	for i in range(pts.size() - 1):
		var r := lerpf(11.0, 5.0, float(i) / pts.size())
		draw_line(pts[i], pts[i+1], fg, r)
	draw_circle(Vector2(pts[0].x + 2, pts[0].y + 2), w * 0.13, shd)
	draw_circle(pts[0], w * 0.13, fg)
	draw_circle(pts[0], w * 0.07, fg.darkened(0.4))
	draw_circle(pts[0] + Vector2(-w*0.05, -h*0.02), w * 0.025, Color(1, 0.9, 0.1))
	draw_circle(pts[0] + Vector2( w*0.05, -h*0.02), w * 0.025, Color(1, 0.9, 0.1))
	var tip := pts[0] + Vector2(w*0.13, -h*0.03)
	draw_line(pts[0] + Vector2(w*0.10, -h*0.01), tip, Color(0.9, 0.1, 0.1), 2.0)
	draw_line(tip, tip + Vector2(w*0.07, -h*0.04), Color(0.9, 0.1, 0.1), 1.5)
	draw_line(tip, tip + Vector2(w*0.07,  h*0.03), Color(0.9, 0.1, 0.1), 1.5)

# ── Robot (Shielded Bot) ───────────────────────────────────────────────────────

func _draw_robot(cx: float, cy: float, w: float, h: float, fg: Color, shd: Color) -> void:
	draw_rect(Rect2(cx - w*0.18 + 1, cy - h*0.40 + 1, w*0.36, h*0.22), shd)
	draw_rect(Rect2(cx - w*0.18, cy - h*0.40, w*0.36, h*0.22), fg)
	draw_rect(Rect2(cx - w*0.14, cy - h*0.34, w*0.09, h*0.09), shd)
	draw_rect(Rect2(cx - w*0.13, cy - h*0.33, w*0.07, h*0.07), Color(0.2, 0.9, 1.0))
	draw_rect(Rect2(cx + w*0.05, cy - h*0.34, w*0.09, h*0.09), shd)
	draw_rect(Rect2(cx + w*0.06, cy - h*0.33, w*0.07, h*0.07), Color(0.2, 0.9, 1.0))
	draw_rect(Rect2(cx - w*0.24 + 1, cy - h*0.16 + 1, w*0.48, h*0.40), shd)
	draw_rect(Rect2(cx - w*0.24, cy - h*0.16, w*0.48, h*0.40), fg.darkened(0.12))
	draw_rect(Rect2(cx - w*0.24, cy + h*0.02, w*0.48, h*0.025), shd)
	for i in range(3):
		draw_rect(Rect2(cx - w*0.18, cy - h*0.12 + i * h*0.10, w*0.36, h*0.02), shd.lightened(0.15))

# ── Golem (Harvest Golem) ──────────────────────────────────────────────────────

func _draw_golem(cx: float, cy: float, w: float, h: float, fg: Color, shd: Color) -> void:
	var parts := [
		[cx,         cy + h*0.12, w*0.30],
		[cx - w*0.20, cy - h*0.04, w*0.22],
		[cx + w*0.20, cy - h*0.04, w*0.22],
		[cx,         cy - h*0.18, w*0.22],
	]
	for p in parts:
		draw_circle(Vector2(p[0] + 3, p[1] + 3), p[2], shd)
	for p in parts:
		draw_circle(Vector2(p[0], p[1]), p[2], fg.darkened(0.1))
	for p in parts:
		draw_circle(Vector2(p[0] - p[2]*0.25, p[1] - p[2]*0.25), p[2] * 0.30, fg.lightened(0.25))
	draw_circle(Vector2(cx - w*0.08, cy - h*0.20), w * 0.055, Color(0.9, 0.55, 0.10))
	draw_circle(Vector2(cx + w*0.08, cy - h*0.20), w * 0.055, Color(0.9, 0.55, 0.10))
	draw_circle(Vector2(cx - w*0.08, cy - h*0.20), w * 0.028, Color(1, 0.8, 0.2))
	draw_circle(Vector2(cx + w*0.08, cy - h*0.20), w * 0.028, Color(1, 0.8, 0.2))

# ── Scythe (Grave Conductor) ───────────────────────────────────────────────────

func _draw_scythe(cx: float, cy: float, w: float, h: float, fg: Color, shd: Color) -> void:
	draw_line(Vector2(cx + w*0.05, cy + h*0.44), Vector2(cx + w*0.28, cy - h*0.42), shd, 7.0)
	draw_line(Vector2(cx,          cy + h*0.44), Vector2(cx + w*0.22, cy - h*0.42), fg.darkened(0.15), 5.0)
	draw_arc(Vector2(cx + w*0.22, cy - h*0.22), w * 0.30, -PI*0.85, -PI*0.08, 20, shd, 11.0)
	draw_arc(Vector2(cx + w*0.22, cy - h*0.22), w * 0.30, -PI*0.85, -PI*0.08, 20, fg, 7.0)
	draw_arc(Vector2(cx + w*0.22, cy - h*0.22), w * 0.28, -PI*0.80, -PI*0.12, 18, fg.lightened(0.3), 2.0)
	draw_circle(Vector2(cx + w*0.10, cy - h*0.40), w * 0.08, shd)
	draw_circle(Vector2(cx + w*0.10, cy - h*0.40), w * 0.06, fg.lightened(0.1))

# ── Lightning (Surge Master) ───────────────────────────────────────────────────

func _draw_lightning(cx: float, cy: float, w: float, h: float, fg: Color, shd: Color) -> void:
	# Vertices ordered to trace the outer boundary (no self-intersection):
	# top → right-upper-notch → right-lower-notch → bottom → left-lower-notch → left-upper-notch
	draw_polygon(PackedVector2Array([
		Vector2(cx + w*0.14, cy - h*0.42),
		Vector2(cx + w*0.10, cy - h*0.04),
		Vector2(cx + w*0.12, cy + h*0.06),
		Vector2(cx - w*0.14, cy + h*0.42),
		Vector2(cx - w*0.04, cy + h*0.06),
		Vector2(cx - w*0.06, cy - h*0.04),
	]), PackedColorArray([shd, shd, shd, shd, shd, shd]))
	draw_polygon(PackedVector2Array([
		Vector2(cx + w*0.11, cy - h*0.40),
		Vector2(cx + w*0.09, cy - h*0.04),
		Vector2(cx + w*0.10, cy + h*0.05),
		Vector2(cx - w*0.11, cy + h*0.40),
		Vector2(cx - w*0.03, cy + h*0.05),
		Vector2(cx - w*0.05, cy - h*0.04),
	]), PackedColorArray([fg, fg, fg, fg, fg, fg]))
	var ic := Color(1, 1, 0.8, 0.75)
	draw_polygon(PackedVector2Array([
		Vector2(cx + w*0.08, cy - h*0.36),
		Vector2(cx + w*0.06, cy - h*0.05),
		Vector2(cx + w*0.07, cy + h*0.04),
		Vector2(cx - w*0.08, cy + h*0.36),
		Vector2(cx - w*0.01, cy + h*0.04),
		Vector2(cx - w*0.02, cy - h*0.05),
	]), PackedColorArray([ic, ic, ic, ic, ic, ic]))

# ── Amplifier ──────────────────────────────────────────────────────────────────

func _draw_amplifier(cx: float, cy: float, w: float, h: float, fg: Color, shd: Color) -> void:
	var ox := cx - w * 0.20
	for i in range(3):
		var r := w * (0.14 + float(i) * 0.14)
		var lw := 5.0 - float(i) * 0.8
		draw_arc(Vector2(ox + 2, cy + 2), r, -PI * 0.52, PI * 0.52, 18, shd, lw + 1.5)
		draw_arc(Vector2(ox, cy), r, -PI * 0.52, PI * 0.52, 18, fg.lightened(float(i) * 0.12), lw)
	draw_circle(Vector2(ox + 2, cy + 2), w * 0.062, shd)
	draw_circle(Vector2(ox, cy), w * 0.062, Color(1, 1, 1, 0.90))

# ── Arcanist (8-point star) ────────────────────────────────────────────────────

func _draw_arcanist(cx: float, cy: float, w: float, h: float, fg: Color, shd: Color) -> void:
	var r_out := w * 0.34
	var r_in  := w * 0.13
	var pts      := PackedVector2Array()
	var cols     := PackedColorArray()
	var shd_pts  := PackedVector2Array()
	var shd_cols := PackedColorArray()
	for i in range(16):
		var angle := (float(i) / 16.0) * TAU - PI * 0.5
		var r := r_out if i % 2 == 0 else r_in
		pts.append(Vector2(cx + r * cos(angle), cy + r * sin(angle)))
		cols.append(fg if i % 2 == 0 else fg.darkened(0.12))
		shd_pts.append(Vector2(cx + 2 + r * cos(angle), cy + 2 + r * sin(angle)))
		shd_cols.append(shd)
	draw_polygon(shd_pts, shd_cols)
	draw_polygon(pts, cols)
	draw_circle(Vector2(cx + 1, cy + 1), w * 0.07, shd)
	draw_circle(Vector2(cx, cy), w * 0.07, Color(1, 1, 1, 0.85))

# ── Channeler (prism + rays) ───────────────────────────────────────────────────

func _draw_channeler(cx: float, cy: float, w: float, h: float, fg: Color, shd: Color) -> void:
	draw_polygon(PackedVector2Array([
		Vector2(cx - w*0.06 + 2, cy - h*0.38 + 2),
		Vector2(cx + w*0.24 + 2, cy + h*0.28 + 2),
		Vector2(cx - w*0.24 + 2, cy + h*0.28 + 2),
	]), PackedColorArray([shd, shd, shd]))
	draw_polygon(PackedVector2Array([
		Vector2(cx - w*0.06, cy - h*0.38),
		Vector2(cx + w*0.24, cy + h*0.28),
		Vector2(cx - w*0.24, cy + h*0.28),
	]), PackedColorArray([fg, fg.darkened(0.18), fg.darkened(0.09)]))
	draw_polygon(PackedVector2Array([
		Vector2(cx - w*0.04, cy - h*0.28),
		Vector2(cx + w*0.14, cy + h*0.20),
		Vector2(cx - w*0.14, cy + h*0.20),
	]), PackedColorArray([Color(1,1,1,0.35), Color(1,1,1,0.10), Color(1,1,1,0.22)]))
	for i in range(3):
		var angle := -PI * 0.5 + (float(i) - 1.0) * 0.30
		var rs := Vector2(cx - w*0.06, cy - h*0.38)
		var re := rs + Vector2(cos(angle), sin(angle)) * w * 0.24
		draw_line(rs + Vector2(1, 1), re + Vector2(1, 1), shd, 2.5)
		draw_line(rs, re, Color(1, 1, 0.65, 0.82), 1.8)

# ── Echo Caster (two rings) ────────────────────────────────────────────────────

func _draw_echo_caster(cx: float, cy: float, w: float, h: float, fg: Color, shd: Color) -> void:
	draw_arc(Vector2(cx + 2, cy + 2), w * 0.30, 0, TAU, 32, shd, 7)
	draw_arc(Vector2(cx, cy), w * 0.30, 0, TAU, 32, fg, 5)
	draw_arc(Vector2(cx + w*0.10 + 1, cy - h*0.06 + 1), w * 0.20, 0, TAU, 24, shd, 4)
	draw_arc(Vector2(cx + w*0.10, cy - h*0.06), w * 0.20, 0, TAU, 24, fg.lightened(0.30), 3)
	draw_circle(Vector2(cx + 1, cy + 1), w * 0.055, shd)
	draw_circle(Vector2(cx, cy), w * 0.055, Color(1, 1, 1, 0.85))

# ── Hexweaver (infinity loops) ─────────────────────────────────────────────────

func _draw_hexweaver(cx: float, cy: float, w: float, h: float, fg: Color, shd: Color) -> void:
	draw_arc(Vector2(cx - w*0.16 + 2, cy + 2), w * 0.22, 0, TAU, 28, shd, 8)
	draw_arc(Vector2(cx - w*0.16, cy), w * 0.22, 0, TAU, 28, fg.darkened(0.10), 6)
	draw_arc(Vector2(cx + w*0.16 + 2, cy + 2), w * 0.22, 0, TAU, 28, shd, 8)
	draw_arc(Vector2(cx + w*0.16, cy), w * 0.22, 0, TAU, 28, fg, 6)
	draw_circle(Vector2(cx - w*0.16, cy), w * 0.090, fg.lightened(0.28))
	draw_circle(Vector2(cx + w*0.16, cy), w * 0.090, fg.lightened(0.22))

# ── Novice (wand + star) ───────────────────────────────────────────────────────

func _draw_novice(cx: float, cy: float, w: float, h: float, fg: Color, shd: Color) -> void:
	draw_line(Vector2(cx + w*0.14 + 2, cy - h*0.36 + 2), Vector2(cx - w*0.22 + 2, cy + h*0.42 + 2), shd, 7)
	draw_line(Vector2(cx + w*0.14, cy - h*0.36), Vector2(cx - w*0.22, cy + h*0.42), fg.lerp(shd, 0.32), 5)
	var r_out := w * 0.16
	var r_in  := w * 0.065
	var scx   := cx + w * 0.14
	var scy   := cy - h * 0.36
	var spts  := PackedVector2Array()
	var scols := PackedColorArray()
	var spshd := PackedVector2Array()
	var spshdc := PackedColorArray()
	for i in range(10):
		var angle := (float(i) / 10.0) * TAU - PI * 0.5
		var r := r_out if i % 2 == 0 else r_in
		spts.append(Vector2(scx + r * cos(angle), scy + r * sin(angle)))
		scols.append(Color(1, 1, 0.75, 0.95) if i % 2 == 0 else fg)
		spshd.append(Vector2(scx + 2 + r * cos(angle), scy + 2 + r * sin(angle)))
		spshdc.append(shd)
	draw_polygon(spshd, spshdc)
	draw_polygon(spts, scols)

# ── Oracle (crystal ball + eye) ────────────────────────────────────────────────

func _draw_oracle(cx: float, cy: float, w: float, h: float, fg: Color, shd: Color) -> void:
	draw_circle(Vector2(cx + 2, cy - h*0.06 + 2), w * 0.30, shd)
	draw_circle(Vector2(cx, cy - h*0.06), w * 0.30, fg.darkened(0.15))
	draw_circle(Vector2(cx, cy - h*0.06), w * 0.23, fg.lightened(0.08))
	draw_polygon(PackedVector2Array([
		Vector2(cx - w*0.14, cy - h*0.06),
		Vector2(cx, cy - h*0.16),
		Vector2(cx + w*0.14, cy - h*0.06),
		Vector2(cx, cy + h*0.04),
	]), PackedColorArray([shd.darkened(0.2), shd.darkened(0.2), shd.darkened(0.2), shd.darkened(0.2)]))
	draw_circle(Vector2(cx, cy - h*0.06), w * 0.075, shd.darkened(0.25))
	draw_circle(Vector2(cx, cy - h*0.06), w * 0.038, Color(1, 1, 1, 0.90))
	draw_rect(Rect2(cx - w*0.20 + 2, cy + h*0.22 + 2, w*0.40, h*0.08), shd)
	draw_rect(Rect2(cx - w*0.20, cy + h*0.22, w*0.40, h*0.08), fg.darkened(0.20))
	draw_rect(Rect2(cx - w*0.12 + 1, cy + h*0.18 + 1, w*0.24, h*0.06), shd)
	draw_rect(Rect2(cx - w*0.12, cy + h*0.18, w*0.24, h*0.06), fg.darkened(0.10))
	draw_circle(Vector2(cx - w*0.10, cy - h*0.15), w * 0.070, Color(1, 1, 1, 0.38))

# ── Spellwright (quill + rune) ─────────────────────────────────────────────────

func _draw_spellwright(cx: float, cy: float, w: float, h: float, fg: Color, shd: Color) -> void:
	draw_line(Vector2(cx + w*0.24 + 2, cy - h*0.38 + 2), Vector2(cx - w*0.24 + 2, cy + h*0.30 + 2), shd, 3)
	draw_line(Vector2(cx + w*0.24, cy - h*0.38), Vector2(cx - w*0.24, cy + h*0.30), fg.lightened(0.22), 2)
	for i in range(4):
		var t := float(i) / 3.0
		var bx := cx + w*0.24 - t * w*0.36
		var by := cy - h*0.38 + t * h*0.52
		draw_line(Vector2(bx + 1, by + 1), Vector2(bx + w*0.12 + 1, by - h*0.06 + 1), shd, 2.0)
		draw_line(Vector2(bx, by), Vector2(bx + w*0.12, by - h*0.06), fg.darkened(0.10), 1.5)
	draw_polygon(PackedVector2Array([
		Vector2(cx - w*0.24, cy + h*0.30),
		Vector2(cx - w*0.16, cy + h*0.20),
		Vector2(cx - w*0.18, cy + h*0.38),
	]), PackedColorArray([fg.lightened(0.10), fg, fg]))
	draw_arc(Vector2(cx + w*0.12, cy + h*0.10), w * 0.12, PI * 1.2, PI * 2.4, 12, shd, 2.5)
	draw_arc(Vector2(cx + w*0.12, cy + h*0.10), w * 0.12, PI * 1.2, PI * 2.4, 12, Color(0.7, 0.9, 1, 0.82), 1.8)
	draw_arc(Vector2(cx + w*0.24, cy + h*0.18), w * 0.08, -PI * 0.3, PI * 0.8, 10, shd, 2.5)
	draw_arc(Vector2(cx + w*0.24, cy + h*0.18), w * 0.08, -PI * 0.3, PI * 0.8, 10, Color(0.7, 0.9, 1, 0.82), 1.8)

# ── Default ────────────────────────────────────────────────────────────────────

func _draw_default(cx: float, cy: float, w: float, h: float, fg: Color, shd: Color) -> void:
	draw_circle(Vector2(cx + 2, cy + 2), w * 0.26, shd)
	draw_circle(Vector2(cx, cy), w * 0.26, fg)
	draw_circle(Vector2(cx - w*0.08, cy - h*0.08), w * 0.10, fg.lightened(0.4))

# ── Goblin Peon (face) ─────────────────────────────────────────────────────────

func _draw_goblin_peon(cx: float, cy: float, w: float, h: float, fg: Color, shd: Color) -> void:
	draw_circle(Vector2(cx + 2, cy + 2), w * 0.28, shd)
	draw_circle(Vector2(cx, cy), w * 0.28, fg)
	draw_polygon(PackedVector2Array([
		Vector2(cx - w*0.20, cy - h*0.06), Vector2(cx - w*0.34, cy - h*0.34), Vector2(cx - w*0.09, cy - h*0.22),
	]), PackedColorArray([fg, fg, fg]))
	draw_polygon(PackedVector2Array([
		Vector2(cx + w*0.20, cy - h*0.06), Vector2(cx + w*0.34, cy - h*0.34), Vector2(cx + w*0.09, cy - h*0.22),
	]), PackedColorArray([fg, fg, fg]))
	draw_circle(Vector2(cx - w*0.10, cy - h*0.03), w * 0.055, shd)
	draw_circle(Vector2(cx + w*0.10, cy - h*0.03), w * 0.055, shd)
	draw_circle(Vector2(cx - w*0.09, cy - h*0.04), w * 0.030, Color(1.0, 0.9, 0.1))
	draw_circle(Vector2(cx + w*0.09, cy - h*0.04), w * 0.030, Color(1.0, 0.9, 0.1))
	draw_arc(Vector2(cx, cy + h*0.09), w * 0.13, 0.25, PI - 0.25, 10, shd, 2.5)

# ── Sprint (Mob Runt) ──────────────────────────────────────────────────────────

func _draw_sprint(cx: float, cy: float, w: float, h: float, fg: Color, shd: Color) -> void:
	for i in range(3):
		var oy := (i - 1) * h * 0.14
		draw_line(Vector2(cx - w*0.42 + 2, cy + oy + 2), Vector2(cx - w*0.10 + 2, cy + oy + 2), shd, 3.0)
		draw_line(Vector2(cx - w*0.42, cy + oy), Vector2(cx - w*0.10, cy + oy), fg.darkened(0.18), 2.5)
	draw_circle(Vector2(cx + w*0.08 + 2, cy - h*0.12 + 2), w * 0.13, shd)
	draw_circle(Vector2(cx + w*0.08, cy - h*0.14), w * 0.13, fg)
	draw_line(Vector2(cx + w*0.08 + 2, cy - h*0.04 + 2), Vector2(cx + w*0.38 + 2, cy + h*0.32 + 2), shd, 7)
	draw_line(Vector2(cx + w*0.08, cy - h*0.04), Vector2(cx + w*0.38, cy + h*0.32), fg, 5)
	draw_line(Vector2(cx + w*0.08 + 2, cy - h*0.04 + 2), Vector2(cx + w*0.14 + 2, cy + h*0.40 + 2), shd, 7)
	draw_line(Vector2(cx + w*0.08, cy - h*0.04), Vector2(cx + w*0.14, cy + h*0.40), fg.darkened(0.1), 5)

# ── Dagger (Sneak) ─────────────────────────────────────────────────────────────

func _draw_dagger(cx: float, cy: float, w: float, h: float, fg: Color, shd: Color) -> void:
	var bw := w * 0.065
	draw_line(Vector2(cx - w*0.24 + 2, cy + h*0.32 + 2), Vector2(cx + w*0.20 + 2, cy - h*0.38 + 2), shd, bw * 2.3)
	draw_line(Vector2(cx - w*0.24, cy + h*0.32), Vector2(cx + w*0.20, cy - h*0.38), fg, bw * 2.0)
	draw_polygon(PackedVector2Array([
		Vector2(cx + w*0.20, cy - h*0.38), Vector2(cx + w*0.12, cy - h*0.30), Vector2(cx + w*0.16, cy - h*0.24),
	]), PackedColorArray([fg.lightened(0.3), fg, fg]))
	draw_line(Vector2(cx - w*0.06 + 1, cy + h*0.10 + 1), Vector2(cx + w*0.12 + 1, cy - h*0.08 + 1), shd, bw * 3.2)
	draw_line(Vector2(cx - w*0.06, cy + h*0.10), Vector2(cx + w*0.12, cy - h*0.08), fg.darkened(0.15), bw * 2.6)
	draw_line(Vector2(cx - w*0.18 + 1, cy + h*0.24 + 1), Vector2(cx - w*0.06 + 1, cy + h*0.10 + 1), shd, bw * 2.6)
	draw_line(Vector2(cx - w*0.18, cy + h*0.24), Vector2(cx - w*0.06, cy + h*0.10), fg.lerp(shd, 0.45), bw * 2.0)

# ── Paw print (Pack Leader) ────────────────────────────────────────────────────

func _draw_paw(cx: float, cy: float, w: float, h: float, fg: Color, shd: Color) -> void:
	draw_circle(Vector2(cx + 2, cy + h*0.14 + 2), w * 0.22, shd)
	draw_circle(Vector2(cx, cy + h*0.14), w * 0.22, fg.darkened(0.08))
	var toes := [
		Vector2(cx - w*0.20, cy - h*0.04),
		Vector2(cx - w*0.07, cy - h*0.16),
		Vector2(cx + w*0.07, cy - h*0.16),
		Vector2(cx + w*0.20, cy - h*0.04),
	]
	for t in toes:
		draw_circle(t + Vector2(2, 2), w * 0.090, shd)
		draw_circle(t, w * 0.090, fg)

# ── Scrap Bomb (Scrap Bomber) ──────────────────────────────────────────────────

func _draw_scrap_bomb(cx: float, cy: float, w: float, h: float, fg: Color, shd: Color) -> void:
	var bcy := cy + h * 0.06
	for i in range(7):
		var angle := (float(i) / 7.0) * TAU
		var sp := Vector2(cx + w*0.25 * cos(angle), bcy + w*0.25 * sin(angle))
		var ep := Vector2(cx + w*0.40 * cos(angle), bcy + w*0.40 * sin(angle))
		draw_line(sp + Vector2(2, 2), ep + Vector2(2, 2), shd, 3.5)
		draw_line(sp, ep, fg.darkened(0.15), 2.5)
	draw_circle(Vector2(cx + 3, bcy + 3), w * 0.26, shd)
	draw_circle(Vector2(cx, bcy), w * 0.26, fg.darkened(0.1))
	draw_circle(Vector2(cx, bcy), w * 0.20, fg)
	draw_circle(Vector2(cx - w*0.07, bcy - h*0.07), w * 0.07, fg.lightened(0.32))
	draw_line(Vector2(cx + w*0.18 + 2, bcy - h*0.18 + 2), Vector2(cx + w*0.28 + 2, bcy - h*0.32 + 2), shd, 3.5)
	draw_line(Vector2(cx + w*0.18, bcy - h*0.18), Vector2(cx + w*0.28, bcy - h*0.32), fg.darkened(0.28), 2.5)
	draw_circle(Vector2(cx + w*0.28, bcy - h*0.32), w * 0.042, Color(1, 0.85, 0.1))

# ── Cauldron (Brood Witch) ─────────────────────────────────────────────────────

func _draw_cauldron(cx: float, cy: float, w: float, h: float, fg: Color, shd: Color) -> void:
	draw_circle(Vector2(cx + 2, cy + h*0.14 + 2), w * 0.30, shd)
	draw_circle(Vector2(cx, cy + h*0.14), w * 0.30, fg.darkened(0.18))
	draw_rect(Rect2(cx - w*0.35 + 2, cy - h*0.06 + 2, w*0.70, h*0.06), shd)
	draw_rect(Rect2(cx - w*0.35, cy - h*0.06, w*0.70, h*0.06), fg)
	draw_line(Vector2(cx - w*0.20 + 1, cy + h*0.38 + 1), Vector2(cx - w*0.24 + 1, cy + h*0.47 + 1), shd, 5)
	draw_line(Vector2(cx - w*0.19, cy + h*0.38), Vector2(cx - w*0.23, cy + h*0.47), fg.darkened(0.22), 3.5)
	draw_line(Vector2(cx + w*0.20 + 1, cy + h*0.38 + 1), Vector2(cx + w*0.24 + 1, cy + h*0.47 + 1), shd, 5)
	draw_line(Vector2(cx + w*0.19, cy + h*0.38), Vector2(cx + w*0.23, cy + h*0.47), fg.darkened(0.22), 3.5)
	draw_circle(Vector2(cx - w*0.10 + 1, cy - h*0.16 + 1), w * 0.050, shd)
	draw_circle(Vector2(cx - w*0.10, cy - h*0.16), w * 0.050, fg.lightened(0.22))
	draw_circle(Vector2(cx + w*0.08 + 1, cy - h*0.26 + 1), w * 0.036, shd)
	draw_circle(Vector2(cx + w*0.08, cy - h*0.26), w * 0.036, fg.lightened(0.30))
	draw_circle(Vector2(cx + w*0.20 + 1, cy - h*0.13 + 1), w * 0.028, shd)
	draw_circle(Vector2(cx + w*0.20, cy - h*0.13), w * 0.028, fg.lightened(0.28))

# ── Axe (Warchief) ─────────────────────────────────────────────────────────────

func _draw_axe(cx: float, cy: float, w: float, h: float, fg: Color, shd: Color) -> void:
	draw_line(Vector2(cx - w*0.10 + 2, cy + h*0.44 + 2), Vector2(cx + w*0.14 + 2, cy - h*0.40 + 2), shd, 7)
	draw_line(Vector2(cx - w*0.10, cy + h*0.44), Vector2(cx + w*0.14, cy - h*0.40), fg.lerp(shd, 0.42), 5)
	var bcx := cx + w * 0.12
	var bcy := cy - h * 0.18
	draw_arc(Vector2(bcx + 2, bcy + 2), w * 0.28, -PI * 0.80, PI * 0.28, 20, shd, 16)
	draw_arc(Vector2(bcx, bcy), w * 0.28, -PI * 0.80, PI * 0.28, 20, fg.darkened(0.08), 12)
	draw_arc(Vector2(bcx, bcy), w * 0.26, -PI * 0.75, PI * 0.22, 18, fg.lightened(0.18), 3.0)

# ── Chain (Litter Lord) ────────────────────────────────────────────────────────

func _draw_chain(cx: float, cy: float, w: float, h: float, fg: Color, shd: Color) -> void:
	var lw := 6.0
	draw_arc(Vector2(cx - w*0.16 + 2, cy + 2), w * 0.18, 0, TAU, 24, shd, lw + 2)
	draw_arc(Vector2(cx - w*0.16, cy), w * 0.18, 0, TAU, 24, fg.darkened(0.12), lw)
	draw_arc(Vector2(cx + w*0.16 + 2, cy + 2), w * 0.18, 0, TAU, 24, shd, lw + 2)
	draw_arc(Vector2(cx + w*0.16, cy), w * 0.18, 0, TAU, 24, fg, lw)
	draw_line(Vector2(cx - w*0.02, cy - 1), Vector2(cx + w*0.02, cy - 1), fg.darkened(0.05), lw * 0.5)

# ── Fist (Rabble Riser) ────────────────────────────────────────────────────────

func _draw_fist(cx: float, cy: float, w: float, h: float, fg: Color, shd: Color) -> void:
	var pts := PackedVector2Array([
		Vector2(cx - w*0.22, cy - h*0.08), Vector2(cx - w*0.28, cy + h*0.04),
		Vector2(cx - w*0.28, cy + h*0.20), Vector2(cx - w*0.18, cy + h*0.28),
		Vector2(cx + w*0.18, cy + h*0.28), Vector2(cx + w*0.28, cy + h*0.20),
		Vector2(cx + w*0.28, cy + h*0.04), Vector2(cx + w*0.22, cy - h*0.08),
	])
	var shd_pts := PackedVector2Array()
	for p in pts:
		shd_pts.append(p + Vector2(2, 2))
	draw_polygon(shd_pts, PackedColorArray([shd, shd, shd, shd, shd, shd, shd, shd]))
	draw_polygon(pts, PackedColorArray([fg, fg, fg, fg, fg, fg, fg, fg]))
	for i in range(3):
		var kx := cx - w*0.10 + i * w*0.10
		draw_line(Vector2(kx, cy - h*0.08), Vector2(kx, cy + h*0.00), shd, 1.5)
	draw_rect(Rect2(cx - w*0.22 + 2, cy + h*0.26 + 2, w*0.44, h*0.14), shd)
	draw_rect(Rect2(cx - w*0.22, cy + h*0.26, w*0.44, h*0.14), fg.darkened(0.08))
	draw_circle(Vector2(cx - w*0.30 + 2, cy + h*0.06 + 2), w * 0.090, shd)
	draw_circle(Vector2(cx - w*0.30, cy + h*0.06), w * 0.090, fg.darkened(0.04))

# ── Whip (Taskmaster) ─────────────────────────────────────────────────────────

func _draw_taskmaster(cx: float, cy: float, w: float, h: float, fg: Color, shd: Color) -> void:
	draw_line(Vector2(cx - w*0.14 + 2, cy + h*0.38 + 2), Vector2(cx + w*0.10 + 2, cy + h*0.10 + 2), shd, 7)
	draw_line(Vector2(cx - w*0.14, cy + h*0.38), Vector2(cx + w*0.10, cy + h*0.10), fg.lerp(shd, 0.4), 5)
	draw_arc(Vector2(cx + w*0.10 + 2, cy - h*0.14 + 2), w * 0.26, PI * 0.3, PI, 18, shd, 4)
	draw_arc(Vector2(cx + w*0.10, cy - h*0.14), w * 0.26, PI * 0.3, PI, 18, fg.darkened(0.1), 3)
	draw_line(Vector2(cx - w*0.16 + 1, cy - h*0.14 + 1), Vector2(cx - w*0.36 + 1, cy - h*0.32 + 1), shd, 3)
	draw_line(Vector2(cx - w*0.16, cy - h*0.14), Vector2(cx - w*0.36, cy - h*0.32), fg.darkened(0.05), 2)
	draw_line(Vector2(cx - w*0.36 + 1, cy - h*0.32 + 1), Vector2(cx - w*0.26 + 1, cy - h*0.42 + 1), shd, 2)
	draw_line(Vector2(cx - w*0.36, cy - h*0.32), Vector2(cx - w*0.26, cy - h*0.42), Color(1, 1, 0.6, 0.9), 1.5)

# ── Vortex (Chaos Caller) ──────────────────────────────────────────────────────

func _draw_vortex(cx: float, cy: float, w: float, h: float, fg: Color, shd: Color) -> void:
	var radii := [w*0.38, w*0.28, w*0.19, w*0.11]
	var starts := [PI * 0.5, PI * 1.0, PI * 1.5, PI * 0.2]
	var ends   := [PI * 2.2, PI * 2.7, PI * 3.2, PI * 1.5]
	for i in range(radii.size()):
		var t := float(i) / float(radii.size() - 1)
		var c := fg.lerp(fg.lightened(0.35), t)
		draw_arc(Vector2(cx + 2, cy + 2), radii[i], starts[i], ends[i], 20, shd, 5)
		draw_arc(Vector2(cx, cy), radii[i], starts[i], ends[i], 20, c, 4)
	draw_circle(Vector2(cx + 1, cy + 1), w * 0.058, shd)
	draw_circle(Vector2(cx, cy), w * 0.058, fg.lightened(0.42))

# ── Crown (Bomb King) ──────────────────────────────────────────────────────────

func _draw_crown(cx: float, cy: float, w: float, h: float, fg: Color, shd: Color) -> void:
	draw_rect(Rect2(cx - w*0.36 + 2, cy + h*0.12 + 2, w*0.72, h*0.22), shd)
	draw_rect(Rect2(cx - w*0.36, cy + h*0.12, w*0.72, h*0.22), fg.darkened(0.10))
	var peak_y := cy - h * 0.28
	var tris := [
		[cx - w*0.36, cy + h*0.12, cx - w*0.22, peak_y,          cx - w*0.08, cy + h*0.12],
		[cx - w*0.08, cy + h*0.12, cx,           peak_y - h*0.08, cx + w*0.08, cy + h*0.12],
		[cx + w*0.08, cy + h*0.12, cx + w*0.22,  peak_y,          cx + w*0.36, cy + h*0.12],
	]
	for tri in tris:
		draw_polygon(PackedVector2Array([
			Vector2(tri[0]+2, tri[1]+2), Vector2(tri[2]+2, tri[3]+2), Vector2(tri[4]+2, tri[5]+2),
		]), PackedColorArray([shd, shd, shd]))
		draw_polygon(PackedVector2Array([
			Vector2(tri[0], tri[1]), Vector2(tri[2], tri[3]), Vector2(tri[4], tri[5]),
		]), PackedColorArray([fg, fg, fg]))
	draw_circle(Vector2(cx + 2, cy + h*0.22 + 2), w * 0.056, shd)
	draw_circle(Vector2(cx, cy + h*0.22), w * 0.056, Color(1, 0.30, 0.30, 0.95))
	for sx in [-w*0.22, w*0.22]:
		draw_circle(Vector2(cx + sx + 2, cy + h*0.22 + 2), w * 0.040, shd)
		draw_circle(Vector2(cx + sx, cy + h*0.22), w * 0.040, Color(0.30, 0.55, 1, 0.95))

# ── Flame (Rage Brand) ─────────────────────────────────────────────────────────

func _draw_flame(cx: float, cy: float, w: float, h: float, fg: Color, shd: Color) -> void:
	draw_polygon(PackedVector2Array([
		Vector2(cx + 2, cy - h*0.42 + 2), Vector2(cx + w*0.28 + 2, cy - h*0.06 + 2),
		Vector2(cx + w*0.20 + 2, cy + h*0.32 + 2), Vector2(cx - w*0.20 + 2, cy + h*0.32 + 2),
		Vector2(cx - w*0.28 + 2, cy - h*0.06 + 2),
	]), PackedColorArray([shd, shd, shd, shd, shd]))
	draw_polygon(PackedVector2Array([
		Vector2(cx, cy - h*0.42), Vector2(cx + w*0.28, cy - h*0.06),
		Vector2(cx + w*0.20, cy + h*0.32), Vector2(cx - w*0.20, cy + h*0.32),
		Vector2(cx - w*0.28, cy - h*0.06),
	]), PackedColorArray([Color(1,0.55,0.05), Color(1,0.55,0.05), Color(1,0.55,0.05), Color(1,0.55,0.05), Color(1,0.55,0.05)]))
	draw_polygon(PackedVector2Array([
		Vector2(cx, cy - h*0.34), Vector2(cx + w*0.16, cy + h*0.06),
		Vector2(cx + w*0.10, cy + h*0.30), Vector2(cx - w*0.10, cy + h*0.30),
		Vector2(cx - w*0.16, cy + h*0.06),
	]), PackedColorArray([Color(1,0.85,0.2), Color(1,0.85,0.2), Color(1,0.85,0.2), Color(1,0.85,0.2), Color(1,0.85,0.2)]))
	draw_polygon(PackedVector2Array([
		Vector2(cx, cy - h*0.22), Vector2(cx + w*0.08, cy + h*0.14), Vector2(cx - w*0.08, cy + h*0.14),
	]), PackedColorArray([Color(1,1,0.8,0.9), Color(1,1,0.8,0.9), Color(1,1,0.8,0.9)]))

# ── Scales (Reckoner) ──────────────────────────────────────────────────────────

func _draw_scales(cx: float, cy: float, w: float, h: float, fg: Color, shd: Color) -> void:
	draw_line(Vector2(cx + 2, cy - h*0.36 + 2), Vector2(cx + 2, cy + h*0.34 + 2), shd, 5)
	draw_line(Vector2(cx, cy - h*0.36), Vector2(cx, cy + h*0.34), fg.darkened(0.20), 3)
	draw_rect(Rect2(cx - w*0.22 + 2, cy + h*0.28 + 2, w*0.44, h*0.08), shd)
	draw_rect(Rect2(cx - w*0.22, cy + h*0.28, w*0.44, h*0.08), fg.darkened(0.10))
	draw_line(Vector2(cx - w*0.32 + 2, cy - h*0.24 + 2), Vector2(cx + w*0.32 + 2, cy - h*0.24 + 2), shd, 5)
	draw_line(Vector2(cx - w*0.32, cy - h*0.24), Vector2(cx + w*0.32, cy - h*0.24), fg, 3)
	draw_line(Vector2(cx - w*0.28 + 1, cy - h*0.24 + 1), Vector2(cx - w*0.28 + 1, cy - h*0.06 + 1), shd, 2)
	draw_line(Vector2(cx - w*0.28, cy - h*0.24), Vector2(cx - w*0.28, cy - h*0.06), fg.darkened(0.10), 1.5)
	draw_line(Vector2(cx + w*0.28 + 1, cy - h*0.24 + 1), Vector2(cx + w*0.28 + 1, cy + h*0.06 + 1), shd, 2)
	draw_line(Vector2(cx + w*0.28, cy - h*0.24), Vector2(cx + w*0.28, cy + h*0.06), fg.darkened(0.10), 1.5)
	draw_arc(Vector2(cx - w*0.28 + 2, cy - h*0.06 + 2), w * 0.14, 0, PI, 14, shd, 5)
	draw_arc(Vector2(cx - w*0.28, cy - h*0.06), w * 0.14, 0, PI, 14, fg, 4)
	draw_arc(Vector2(cx + w*0.28 + 2, cy + h*0.06 + 2), w * 0.14, 0, PI, 14, shd, 5)
	draw_arc(Vector2(cx + w*0.28, cy + h*0.06), w * 0.14, 0, PI, 14, fg, 4)

# ── Skull (Witch Doctor) ───────────────────────────────────────────────────────

func _draw_skull(cx: float, cy: float, w: float, h: float, fg: Color, shd: Color) -> void:
	draw_circle(Vector2(cx + 2, cy - h*0.06 + 2), w * 0.28, shd)
	draw_circle(Vector2(cx, cy - h*0.06), w * 0.28, fg)
	draw_rect(Rect2(cx - w*0.18 + 2, cy + h*0.16 + 2, w*0.36, h*0.13), shd)
	draw_rect(Rect2(cx - w*0.18, cy + h*0.16, w*0.36, h*0.13), fg.darkened(0.08))
	draw_circle(Vector2(cx - w*0.11 + 1, cy - h*0.09 + 1), w * 0.082, shd)
	draw_circle(Vector2(cx - w*0.11, cy - h*0.09), w * 0.082, shd.darkened(0.55))
	draw_circle(Vector2(cx + w*0.11 + 1, cy - h*0.09 + 1), w * 0.082, shd)
	draw_circle(Vector2(cx + w*0.11, cy - h*0.09), w * 0.082, shd.darkened(0.55))
	draw_circle(Vector2(cx + 1, cy + h*0.04 + 1), w * 0.038, shd)
	draw_circle(Vector2(cx, cy + h*0.04), w * 0.038, shd.darkened(0.55))
	for i in range(4):
		var tx := cx - w*0.12 + float(i) * w*0.08
		draw_rect(Rect2(tx + 1, cy + h*0.18 + 1, w*0.050, h*0.09), shd)
		draw_rect(Rect2(tx, cy + h*0.18, w*0.050, h*0.09), fg.lightened(0.32))

# ── Claw (Grub Grabber) ────────────────────────────────────────────────────────

func _draw_claw(cx: float, cy: float, w: float, h: float, fg: Color, shd: Color) -> void:
	draw_rect(Rect2(cx - w*0.28 + 2, cy - h*0.40 + 2, w*0.56, h*0.13), shd)
	draw_rect(Rect2(cx - w*0.28, cy - h*0.40, w*0.56, h*0.13), fg.darkened(0.06))
	var claw_roots: Array[float] = [cx - w*0.18, cx, cx + w*0.18]
	for i in range(claw_roots.size()):
		var ox := claw_roots[i]
		var curve := (i - 1) * w * 0.08
		draw_line(Vector2(ox + 2, cy - h*0.28 + 2), Vector2(ox + curve + 2, cy + h*0.10 + 2), shd, 8)
		draw_line(Vector2(ox, cy - h*0.28), Vector2(ox + curve, cy + h*0.10), fg, 6)
		draw_arc(Vector2(ox + curve + w*0.11 + 2, cy + h*0.10 + 2), w * 0.13, PI * 0.6, PI * 1.2, 12, shd, 8)
		draw_arc(Vector2(ox + curve + w*0.11, cy + h*0.10), w * 0.13, PI * 0.6, PI * 1.2, 12, fg.darkened(0.06), 6)

# ── Wraith (ghost) ─────────────────────────────────────────────────────────────

func _draw_wraith(cx: float, cy: float, w: float, h: float, fg: Color, shd: Color) -> void:
	draw_circle(Vector2(cx + 2, cy - h*0.10 + 2), w * 0.24, shd)
	draw_circle(Vector2(cx, cy - h*0.10), w * 0.24, fg)
	draw_polygon(PackedVector2Array([
		Vector2(cx - w*0.24, cy + h*0.06),
		Vector2(cx - w*0.24, cy + h*0.42),
		Vector2(cx - w*0.12, cy + h*0.30),
		Vector2(cx, cy + h*0.42),
		Vector2(cx + w*0.12, cy + h*0.30),
		Vector2(cx + w*0.24, cy + h*0.42),
		Vector2(cx + w*0.24, cy + h*0.06),
	]), PackedColorArray([fg, fg, fg, fg, fg, fg, fg]))
	draw_circle(Vector2(cx - w*0.09, cy - h*0.14), w * 0.055, shd.darkened(0.5))
	draw_circle(Vector2(cx + w*0.09, cy - h*0.14), w * 0.055, shd.darkened(0.5))

# ── Pale Shroud (veil) ─────────────────────────────────────────────────────────

func _draw_pale_shroud(cx: float, cy: float, w: float, h: float, fg: Color, shd: Color) -> void:
	draw_rect(Rect2(cx - w*0.28 + 2, cy - h*0.42 + 2, w*0.56, h*0.72), shd)
	draw_rect(Rect2(cx - w*0.28, cy - h*0.42, w*0.56, h*0.72), fg.darkened(0.10))
	for i in range(5):
		var sx := cx - w*0.20 + float(i) * w*0.10
		draw_line(Vector2(sx, cy + h*0.28), Vector2(sx + (i - 2) * w*0.06, cy + h*0.44), fg.lightened(0.15), 2.0)
	draw_rect(Rect2(cx - w*0.28, cy - h*0.42, w*0.56, h*0.06), fg)
	draw_circle(Vector2(cx - w*0.08, cy - h*0.18), w * 0.060, shd.darkened(0.5))
	draw_circle(Vector2(cx + w*0.08, cy - h*0.18), w * 0.060, shd.darkened(0.5))
	draw_arc(Vector2(cx, cy - h*0.04), w * 0.10, 0.2, PI - 0.2, 10, shd.darkened(0.4), 2.0)

# ── Dread Knell (bell) ────────────────────────────────────────────────────────

func _draw_dread_knell(cx: float, cy: float, w: float, h: float, fg: Color, shd: Color) -> void:
	draw_polygon(PackedVector2Array([
		Vector2(cx - w*0.06 + 2, cy - h*0.38 + 2),
		Vector2(cx + w*0.06 + 2, cy - h*0.38 + 2),
		Vector2(cx + w*0.34 + 2, cy + h*0.24 + 2),
		Vector2(cx - w*0.34 + 2, cy + h*0.24 + 2),
	]), PackedColorArray([shd, shd, shd, shd]))
	draw_polygon(PackedVector2Array([
		Vector2(cx - w*0.06, cy - h*0.38),
		Vector2(cx + w*0.06, cy - h*0.38),
		Vector2(cx + w*0.34, cy + h*0.24),
		Vector2(cx - w*0.34, cy + h*0.24),
	]), PackedColorArray([fg, fg, fg.darkened(0.12), fg.darkened(0.12)]))
	draw_rect(Rect2(cx - w*0.36 + 2, cy + h*0.22 + 2, w*0.72, h*0.07), shd)
	draw_rect(Rect2(cx - w*0.36, cy + h*0.22, w*0.72, h*0.07), fg)
	draw_circle(Vector2(cx + 1, cy + h*0.36 + 1), w * 0.065, shd)
	draw_circle(Vector2(cx, cy + h*0.36), w * 0.065, fg.darkened(0.15))
	draw_line(Vector2(cx + 1, cy + h*0.28 + 1), Vector2(cx + 1, cy + h*0.36 + 1), shd, 2.5)
	draw_line(Vector2(cx, cy + h*0.28), Vector2(cx, cy + h*0.36), fg.darkened(0.2), 2.0)
	for i in range(2):
		var side := -1.0 if i == 0 else 1.0
		draw_arc(Vector2(cx + side * w*0.50, cy + h*0.06), w * 0.16, -PI*0.45, PI*0.45, 10, fg.darkened(0.25), 1.5)

# ── Grave Stalker (rising clawed hand) ────────────────────────────────────────

func _draw_grave_stalker(cx: float, cy: float, w: float, h: float, fg: Color, shd: Color) -> void:
	draw_rect(Rect2(cx - w*0.36 + 2, cy + h*0.28 + 2, w*0.72, h*0.18), shd)
	draw_rect(Rect2(cx - w*0.36, cy + h*0.28, w*0.72, h*0.18), fg.darkened(0.25))
	var finger_offsets: Array[float] = [-w*0.20, -w*0.07, w*0.07, w*0.20]
	var finger_tops: Array[float] = [-h*0.38, -h*0.46, -h*0.46, -h*0.34]
	for i in range(4):
		draw_line(Vector2(cx + finger_offsets[i] + 2, cy + h*0.28 + 2),
			Vector2(cx + finger_offsets[i] + 2, cy + finger_tops[i] + 2), shd, 9)
		draw_line(Vector2(cx + finger_offsets[i], cy + h*0.28),
			Vector2(cx + finger_offsets[i], cy + finger_tops[i]), fg, 7)
		draw_arc(Vector2(cx + finger_offsets[i] + w*0.10 + 2, cy + finger_tops[i] + 2),
			w * 0.10, -PI*0.9, PI*0.1, 10, shd, 9)
		draw_arc(Vector2(cx + finger_offsets[i] + w*0.10, cy + finger_tops[i]),
			w * 0.10, -PI*0.9, PI*0.1, 10, fg.darkened(0.05), 7)

# ── Void Wraith (swirling void) ───────────────────────────────────────────────

func _draw_void_wraith(cx: float, cy: float, w: float, h: float, fg: Color, shd: Color) -> void:
	draw_circle(Vector2(cx + 2, cy + 2), w * 0.36, shd)
	draw_circle(Vector2(cx, cy), w * 0.36, fg.darkened(0.30))
	var arms := 5
	for i in range(arms):
		var a0 := float(i) / arms * TAU
		var a1 := a0 + TAU / (arms * 2.2)
		draw_arc(Vector2(cx + 1, cy + 1), w * 0.24, a0, a1, 12, shd, 6)
		draw_arc(Vector2(cx, cy), w * 0.24, a0, a1, 12, fg, 4)
	draw_circle(Vector2(cx + 1, cy + 1), w * 0.09, shd)
	draw_circle(Vector2(cx, cy), w * 0.09, Color(0.06, 0.02, 0.12))

# ── Pale Reaper (hooded reaper) ───────────────────────────────────────────────

func _draw_pale_reaper(cx: float, cy: float, w: float, h: float, fg: Color, shd: Color) -> void:
	draw_line(Vector2(cx - w*0.14 + 2, cy + h*0.44 + 2), Vector2(cx + w*0.08 + 2, cy - h*0.38 + 2), shd, 7)
	draw_line(Vector2(cx - w*0.14, cy + h*0.44), Vector2(cx + w*0.08, cy - h*0.38), fg.lerp(shd, 0.30), 5)
	draw_arc(Vector2(cx + w*0.08 + 2, cy - h*0.20 + 2), w * 0.32, -PI*0.88, -PI*0.06, 22, shd, 12)
	draw_arc(Vector2(cx + w*0.08, cy - h*0.20), w * 0.32, -PI*0.88, -PI*0.06, 22, fg, 8)
	draw_arc(Vector2(cx + w*0.08, cy - h*0.20), w * 0.30, -PI*0.82, -PI*0.10, 20, fg.lightened(0.28), 2.0)
	draw_circle(Vector2(cx + w*0.02 + 1, cy - h*0.38 + 1), w * 0.075, shd)
	draw_circle(Vector2(cx + w*0.02, cy - h*0.38), w * 0.075, fg.lightened(0.12))
	draw_polygon(PackedVector2Array([
		Vector2(cx - w*0.36, cy - h*0.12), Vector2(cx - w*0.12, cy - h*0.38),
		Vector2(cx + w*0.12, cy - h*0.38), Vector2(cx - w*0.12, cy + h*0.06),
	]), PackedColorArray([fg.darkened(0.28), fg.darkened(0.20), fg.darkened(0.20), fg.darkened(0.28)]))

# ── Dread Seer (eye in triangle) ──────────────────────────────────────────────

func _draw_dread_seer(cx: float, cy: float, w: float, h: float, fg: Color, shd: Color) -> void:
	draw_polygon(PackedVector2Array([
		Vector2(cx + 2, cy - h*0.38 + 2), Vector2(cx + w*0.38 + 2, cy + h*0.28 + 2), Vector2(cx - w*0.38 + 2, cy + h*0.28 + 2),
	]), PackedColorArray([shd, shd, shd]))
	draw_polygon(PackedVector2Array([
		Vector2(cx, cy - h*0.38), Vector2(cx + w*0.38, cy + h*0.28), Vector2(cx - w*0.38, cy + h*0.28),
	]), PackedColorArray([fg, fg.darkened(0.10), fg.darkened(0.10)]))
	draw_polygon(PackedVector2Array([
		Vector2(cx - w*0.18, cy - h*0.04), Vector2(cx, cy - h*0.22),
		Vector2(cx + w*0.18, cy - h*0.04), Vector2(cx, cy + h*0.14),
	]), PackedColorArray([fg.darkened(0.35), fg.darkened(0.35), fg.darkened(0.35), fg.darkened(0.35)]))
	draw_circle(Vector2(cx + 1, cy - h*0.05 + 1), w * 0.09, shd)
	draw_circle(Vector2(cx, cy - h*0.05), w * 0.09, Color(0.55, 0.20, 0.80, 0.95))
	draw_circle(Vector2(cx, cy - h*0.05), w * 0.045, Color(0.08, 0.02, 0.16))
	draw_circle(Vector2(cx - w*0.03, cy - h*0.07), w * 0.020, Color(1, 1, 1, 0.80))

# ── Doom Herald (hourglass) ───────────────────────────────────────────────────

func _draw_doom_herald(cx: float, cy: float, w: float, h: float, fg: Color, shd: Color) -> void:
	draw_polygon(PackedVector2Array([
		Vector2(cx - w*0.30 + 2, cy - h*0.40 + 2), Vector2(cx + w*0.30 + 2, cy - h*0.40 + 2),
		Vector2(cx + w*0.06 + 2, cy + 2), Vector2(cx - w*0.06 + 2, cy + 2),
	]), PackedColorArray([shd, shd, shd, shd]))
	draw_polygon(PackedVector2Array([
		Vector2(cx - w*0.30, cy - h*0.40), Vector2(cx + w*0.30, cy - h*0.40),
		Vector2(cx + w*0.06, cy), Vector2(cx - w*0.06, cy),
	]), PackedColorArray([fg, fg, fg.darkened(0.12), fg.darkened(0.12)]))
	draw_polygon(PackedVector2Array([
		Vector2(cx - w*0.06 + 2, cy + 2), Vector2(cx + w*0.06 + 2, cy + 2),
		Vector2(cx + w*0.30 + 2, cy + h*0.40 + 2), Vector2(cx - w*0.30 + 2, cy + h*0.40 + 2),
	]), PackedColorArray([shd, shd, shd, shd]))
	draw_polygon(PackedVector2Array([
		Vector2(cx - w*0.06, cy), Vector2(cx + w*0.06, cy),
		Vector2(cx + w*0.30, cy + h*0.40), Vector2(cx - w*0.30, cy + h*0.40),
	]), PackedColorArray([fg.darkened(0.12), fg.darkened(0.12), fg, fg]))
	draw_rect(Rect2(cx - w*0.32 + 2, cy - h*0.43 + 2, w*0.64, h*0.06), shd)
	draw_rect(Rect2(cx - w*0.32, cy - h*0.43, w*0.64, h*0.06), fg)
	draw_rect(Rect2(cx - w*0.32 + 2, cy + h*0.37 + 2, w*0.64, h*0.06), shd)
	draw_rect(Rect2(cx - w*0.32, cy + h*0.37, w*0.64, h*0.06), fg)
	draw_circle(Vector2(cx + 1, cy - h*0.14 + 1), w * 0.050, shd)
	draw_circle(Vector2(cx, cy - h*0.14), w * 0.050, Color(0.90, 0.60, 0.10, 0.90))

# ── Shade Stalker (sprinting shadow with blade) ───────────────────────────────

func _draw_shade_stalker(cx: float, cy: float, w: float, h: float, fg: Color, shd: Color) -> void:
	draw_circle(Vector2(cx - w*0.04 + 2, cy - h*0.32 + 2), w * 0.11, shd)
	draw_circle(Vector2(cx - w*0.04, cy - h*0.32), w * 0.11, fg)
	draw_line(Vector2(cx - w*0.04 + 2, cy - h*0.22 + 2), Vector2(cx + w*0.08 + 2, cy + h*0.10 + 2), shd, 9)
	draw_line(Vector2(cx - w*0.04, cy - h*0.22), Vector2(cx + w*0.08, cy + h*0.10), fg, 7)
	draw_line(Vector2(cx + w*0.08 + 2, cy + h*0.10 + 2), Vector2(cx - w*0.06 + 2, cy + h*0.38 + 2), shd, 7)
	draw_line(Vector2(cx + w*0.08, cy + h*0.10), Vector2(cx - w*0.06, cy + h*0.38), fg.darkened(0.10), 5)
	draw_line(Vector2(cx + w*0.08 + 2, cy + h*0.10 + 2), Vector2(cx + w*0.32 + 2, cy + h*0.30 + 2), shd, 7)
	draw_line(Vector2(cx + w*0.08, cy + h*0.10), Vector2(cx + w*0.32, cy + h*0.30), fg.darkened(0.10), 5)
	draw_line(Vector2(cx + w*0.20 + 2, cy - h*0.30 + 2), Vector2(cx - w*0.24 + 2, cy + h*0.24 + 2), shd, 4)
	draw_line(Vector2(cx + w*0.20, cy - h*0.30), Vector2(cx - w*0.24, cy + h*0.24), fg.lightened(0.22), 3)
	draw_polygon(PackedVector2Array([
		Vector2(cx + w*0.20, cy - h*0.30), Vector2(cx + w*0.12, cy - h*0.22), Vector2(cx + w*0.16, cy - h*0.16),
	]), PackedColorArray([fg.lightened(0.3), fg, fg]))

# ── Wail Specter (wailing ghost) ──────────────────────────────────────────────

func _draw_wail_specter(cx: float, cy: float, w: float, h: float, fg: Color, shd: Color) -> void:
	draw_circle(Vector2(cx + 2, cy - h*0.18 + 2), w * 0.26, shd)
	draw_circle(Vector2(cx, cy - h*0.18), w * 0.26, fg)
	draw_polygon(PackedVector2Array([
		Vector2(cx - w*0.26, cy - h*0.02),
		Vector2(cx - w*0.26, cy + h*0.42),
		Vector2(cx - w*0.13, cy + h*0.28),
		Vector2(cx, cy + h*0.42),
		Vector2(cx + w*0.13, cy + h*0.28),
		Vector2(cx + w*0.26, cy + h*0.42),
		Vector2(cx + w*0.26, cy - h*0.02),
	]), PackedColorArray([fg, fg, fg, fg, fg, fg, fg]))
	draw_circle(Vector2(cx - w*0.10, cy - h*0.22), w * 0.055, shd.darkened(0.5))
	draw_circle(Vector2(cx + w*0.10, cy - h*0.22), w * 0.055, shd.darkened(0.5))
	draw_arc(Vector2(cx, cy - h*0.08), w * 0.12, 0.18, PI - 0.18, 12, shd.darkened(0.5), 3.0)
	for i in range(3):
		var sx := cx - w*0.32 + float(i) * w*0.28
		var ey := cy - h*0.18 - float(i % 2) * h*0.08
		draw_line(Vector2(sx, cy - h*0.18), Vector2(sx + w*0.18, ey), fg.darkened(0.30), 1.5)

# ── Dread Lord (spiked throne crown) ─────────────────────────────────────────

func _draw_dread_lord(cx: float, cy: float, w: float, h: float, fg: Color, shd: Color) -> void:
	draw_rect(Rect2(cx - w*0.34 + 2, cy + h*0.04 + 2, w*0.68, h*0.24), shd)
	draw_rect(Rect2(cx - w*0.34, cy + h*0.04, w*0.68, h*0.24), fg.darkened(0.12))
	var spikes := [
		[cx - w*0.26, cy + h*0.04, cx - w*0.26, cy - h*0.38],
		[cx - w*0.08, cy + h*0.04, cx - w*0.08, cy - h*0.46],
		[cx + w*0.08, cy + h*0.04, cx + w*0.08, cy - h*0.46],
		[cx + w*0.26, cy + h*0.04, cx + w*0.26, cy - h*0.38],
	]
	for sp in spikes:
		draw_line(Vector2(sp[0] + 2, sp[1] + 2), Vector2(sp[2] + 2, sp[3] + 2), shd, 9)
		draw_line(Vector2(sp[0], sp[1]), Vector2(sp[2], sp[3]), fg, 7)
		draw_polygon(PackedVector2Array([
			Vector2(sp[2], sp[3]), Vector2(sp[0] - w*0.04, sp[1]),
			Vector2(sp[0] + w*0.04, sp[1]),
		]), PackedColorArray([fg.lightened(0.20), fg, fg]))
	draw_rect(Rect2(cx - w*0.34 + 2, cy + h*0.26 + 2, w*0.68, h*0.06), shd)
	draw_rect(Rect2(cx - w*0.34, cy + h*0.26, w*0.68, h*0.06), fg)
	draw_circle(Vector2(cx + 1, cy + h*0.16 + 1), w * 0.065, shd)
	draw_circle(Vector2(cx, cy + h*0.16), w * 0.065, Color(0.75, 0.10, 0.85, 0.95))

# ── Grave Collector (three skulls) ────────────────────────────────────────────

func _draw_grave_collector(cx: float, cy: float, w: float, h: float, fg: Color, shd: Color) -> void:
	var positions := [
		Vector2(cx - w*0.20, cy - h*0.06),
		Vector2(cx + w*0.20, cy - h*0.06),
		Vector2(cx, cy + h*0.20),
	]
	for pos in positions:
		draw_circle(pos + Vector2(2, 2), w * 0.17, shd)
		draw_circle(pos, w * 0.17, fg.darkened(0.06))
		draw_rect(Rect2(pos.x - w*0.10 + 1, pos.y + h*0.10 + 1, w*0.20, h*0.07), shd)
		draw_rect(Rect2(pos.x - w*0.10, pos.y + h*0.10, w*0.20, h*0.07), fg.darkened(0.08))
		draw_circle(pos + Vector2(-w*0.06, -h*0.04), w * 0.044, shd.darkened(0.55))
		draw_circle(pos + Vector2(w*0.06, -h*0.04), w * 0.044, shd.darkened(0.55))
	for i in range(3):
		var j := (i + 1) % 3
		draw_line(positions[i] + Vector2(1, 1), positions[j] + Vector2(1, 1), shd, 1.5)
		draw_line(positions[i], positions[j], fg.darkened(0.30), 1.0)

# ── Soul Harvester (glowing orb with tendrils) ────────────────────────────────

func _draw_soul_harvester(cx: float, cy: float, w: float, h: float, fg: Color, shd: Color) -> void:
	var tendrils := 6
	for i in range(tendrils):
		var angle := float(i) / tendrils * TAU
		var ex := cx + w*0.42 * cos(angle)
		var ey := cy + w*0.42 * sin(angle)
		draw_line(Vector2(cx + 1, cy + 1), Vector2(ex + 1, ey + 1), shd, 3)
		draw_line(Vector2(cx, cy), Vector2(ex, ey), fg.darkened(0.30), 2)
		draw_circle(Vector2(ex + 1, ey + 1), w * 0.052, shd)
		draw_circle(Vector2(ex, ey), w * 0.052, fg.lightened(0.18))
	draw_circle(Vector2(cx + 2, cy + 2), w * 0.22, shd)
	draw_circle(Vector2(cx, cy), w * 0.22, fg.darkened(0.08))
	draw_circle(Vector2(cx, cy), w * 0.15, fg.lightened(0.14))
	draw_circle(Vector2(cx - w*0.06, cy - h*0.06), w * 0.065, Color(1, 1, 1, 0.75))

# ── Rift Caller (jagged rift) ─────────────────────────────────────────────────

func _draw_rift_caller(cx: float, cy: float, w: float, h: float, fg: Color, shd: Color) -> void:
	var pts := PackedVector2Array([
		Vector2(cx - w*0.06, cy - h*0.44),
		Vector2(cx + w*0.12, cy - h*0.18),
		Vector2(cx - w*0.08, cy - h*0.08),
		Vector2(cx + w*0.14, cy + h*0.12),
		Vector2(cx - w*0.04, cy + h*0.22),
		Vector2(cx + w*0.08, cy + h*0.44),
	])
	for i in range(pts.size() - 1):
		draw_line(pts[i] + Vector2(2, 2), pts[i+1] + Vector2(2, 2), shd, 5)
	for i in range(pts.size() - 1):
		draw_line(pts[i], pts[i+1], fg, 3)
	for i in range(1, pts.size() - 1):
		var lw := 4.0 - float(i) * 0.5
		var ep := pts[i] + Vector2(-w*0.18 - float(i)*w*0.03, 0)
		draw_line(pts[i] + Vector2(1, 1), ep + Vector2(1, 1), shd, lw + 1)
		draw_line(pts[i], ep, fg.darkened(0.22), lw)
		var ep2 := pts[i] + Vector2(w*0.18 + float(i)*w*0.03, 0)
		draw_line(pts[i] + Vector2(1, 1), ep2 + Vector2(1, 1), shd, lw + 1)
		draw_line(pts[i], ep2, fg.darkened(0.22), lw)

# ── Death Sovereign (imperial crown + skull) ──────────────────────────────────

func _draw_death_sovereign(cx: float, cy: float, w: float, h: float, fg: Color, shd: Color) -> void:
	draw_rect(Rect2(cx - w*0.36 + 2, cy + h*0.02 + 2, w*0.72, h*0.28), shd)
	draw_rect(Rect2(cx - w*0.36, cy + h*0.02, w*0.72, h*0.28), fg.darkened(0.15))
	var peaks := [
		[cx - w*0.36, cy + h*0.02, cx - w*0.22, cy - h*0.36, cx - w*0.08, cy + h*0.02],
		[cx - w*0.08, cy + h*0.02, cx, cy - h*0.44,          cx + w*0.08, cy + h*0.02],
		[cx + w*0.08, cy + h*0.02, cx + w*0.22, cy - h*0.36, cx + w*0.36, cy + h*0.02],
	]
	for pk in peaks:
		draw_polygon(PackedVector2Array([
			Vector2(pk[0]+2, pk[1]+2), Vector2(pk[2]+2, pk[3]+2), Vector2(pk[4]+2, pk[5]+2),
		]), PackedColorArray([shd, shd, shd]))
		draw_polygon(PackedVector2Array([
			Vector2(pk[0], pk[1]), Vector2(pk[2], pk[3]), Vector2(pk[4], pk[5]),
		]), PackedColorArray([fg, fg, fg]))
	draw_rect(Rect2(cx - w*0.36 + 2, cy + h*0.28 + 2, w*0.72, h*0.06), shd)
	draw_rect(Rect2(cx - w*0.36, cy + h*0.28, w*0.72, h*0.06), fg)
	draw_circle(Vector2(cx + 2, cy + h*0.16 + 2), w * 0.080, shd)
	draw_circle(Vector2(cx, cy + h*0.16), w * 0.080, fg.darkened(0.10))
	draw_circle(Vector2(cx - w*0.06, cy + h*0.12), w * 0.028, shd.darkened(0.55))
	draw_circle(Vector2(cx + w*0.06, cy + h*0.12), w * 0.028, shd.darkened(0.55))
	draw_arc(Vector2(cx, cy + h*0.22), w * 0.042, 0.15, PI - 0.15, 8, shd.darkened(0.45), 2.0)
	for sx in [-w*0.22, w*0.22]:
		draw_circle(Vector2(cx + sx + 2, cy + h*0.16 + 2), w * 0.052, shd)
		draw_circle(Vector2(cx + sx, cy + h*0.16), w * 0.052, Color(0.90, 0.15, 0.15, 0.95))

# ── Grave Pact (clasped hands over cracked ground) ────────────────────────────

func _draw_grave_pact(cx: float, cy: float, w: float, h: float, fg: Color, shd: Color) -> void:
	for i in range(2):
		var side := -1.0 if i == 0 else 1.0
		var hx := cx + side * w * 0.14
		draw_rect(Rect2(hx - w*0.12 + 2, cy - h*0.12 + 2, w*0.24, h*0.28), shd)
		draw_rect(Rect2(hx - w*0.12, cy - h*0.12, w*0.24, h*0.28), fg.darkened(0.10))
		for j in range(3):
			var fy := cy - h*0.18 + float(j) * h*0.10
			draw_rect(Rect2(hx - w*0.12 + 2, fy + 2, w*0.24, h*0.06), shd)
			draw_rect(Rect2(hx - w*0.12, fy, w*0.24, h*0.06), fg.darkened(0.04 + j * 0.04))
	draw_rect(Rect2(cx - w*0.28 + 2, cy + h*0.16 + 2, w*0.56, h*0.06), shd)
	draw_rect(Rect2(cx - w*0.28, cy + h*0.16, w*0.56, h*0.06), fg)
	for i in range(3):
		var kx := cx - w*0.18 + float(i) * w*0.18
		var depth := h * (0.10 + float(i % 2) * 0.08)
		draw_line(Vector2(kx + 1, cy + h*0.22 + 1), Vector2(kx + w*0.04 + 1, cy + h*0.22 + depth + 1), shd, 2)
		draw_line(Vector2(kx, cy + h*0.22), Vector2(kx + w*0.04, cy + h*0.22 + depth), fg.darkened(0.25), 1.5)

# ── Shadow token (translucent wisp) ───────────────────────────────────────────

func _draw_shadow_token(cx: float, cy: float, w: float, h: float, fg: Color, shd: Color) -> void:
	draw_circle(Vector2(cx + 2, cy - h*0.06 + 2), w * 0.20, shd)
	draw_circle(Vector2(cx, cy - h*0.06), w * 0.20, fg.darkened(0.15))
	draw_polygon(PackedVector2Array([
		Vector2(cx - w*0.20, cy + h*0.08),
		Vector2(cx - w*0.20, cy + h*0.36),
		Vector2(cx - w*0.10, cy + h*0.24),
		Vector2(cx, cy + h*0.36),
		Vector2(cx + w*0.10, cy + h*0.24),
		Vector2(cx + w*0.20, cy + h*0.36),
		Vector2(cx + w*0.20, cy + h*0.08),
	]), PackedColorArray([fg, fg, fg, fg, fg, fg, fg]))
	draw_circle(Vector2(cx - w*0.07, cy - h*0.10), w * 0.040, shd.darkened(0.45))
	draw_circle(Vector2(cx + w*0.07, cy - h*0.10), w * 0.040, shd.darkened(0.45))

# ── Duelist (crossed swords) ─────────────────────────────────────────────────

func _draw_duelist(cx: float, cy: float, w: float, h: float, fg: Color, shd: Color) -> void:
	draw_line(Vector2(cx - w*0.22 + 2, cy - h*0.28 + 2), Vector2(cx + w*0.22 + 2, cy + h*0.28 + 2), shd, w*0.09)
	draw_line(Vector2(cx + w*0.22 + 2, cy - h*0.28 + 2), Vector2(cx - w*0.22 + 2, cy + h*0.28 + 2), shd, w*0.09)
	draw_line(Vector2(cx - w*0.22, cy - h*0.28), Vector2(cx + w*0.22, cy + h*0.28), fg, w*0.09)
	draw_line(Vector2(cx + w*0.22, cy - h*0.28), Vector2(cx - w*0.22, cy + h*0.28), fg, w*0.09)
	draw_circle(Vector2(cx + 2, cy + 2), w * 0.08, shd)
	draw_circle(Vector2(cx, cy), w * 0.08, fg.darkened(0.30))

# ── Warlord (crown) ──────────────────────────────────────────────────────────

func _draw_warlord(cx: float, cy: float, w: float, h: float, fg: Color, shd: Color) -> void:
	draw_rect(Rect2(cx - w*0.32 + 2, cy + h*0.08 + 2, w*0.64, h*0.20), shd)
	draw_rect(Rect2(cx - w*0.32, cy + h*0.08, w*0.64, h*0.20), fg)
	for i in range(3):
		var px := cx - w*0.22 + float(i) * w*0.22
		draw_rect(Rect2(px - w*0.08 + 2, cy - h*0.14 + 2, w*0.16, h*0.24), shd)
		draw_rect(Rect2(px - w*0.08, cy - h*0.14, w*0.16, h*0.24), fg)
		draw_polygon(PackedVector2Array([
			Vector2(px, cy - h*0.26), Vector2(px - w*0.08, cy - h*0.14), Vector2(px + w*0.08, cy - h*0.14)
		]), PackedColorArray([fg, fg, fg]))

# ── Quartermaster (chest) ────────────────────────────────────────────────────

func _draw_quartermaster(cx: float, cy: float, w: float, h: float, fg: Color, shd: Color) -> void:
	draw_rect(Rect2(cx - w*0.30 + 2, cy - h*0.08 + 2, w*0.60, h*0.30), shd)
	draw_rect(Rect2(cx - w*0.30, cy - h*0.08, w*0.60, h*0.30), fg)
	draw_rect(Rect2(cx - w*0.32 + 2, cy - h*0.20 + 2, w*0.64, h*0.14), shd)
	draw_rect(Rect2(cx - w*0.32, cy - h*0.20, w*0.64, h*0.14), fg.lightened(0.12))
	draw_circle(Vector2(cx + 2, cy + h*0.06 + 2), w * 0.07, shd)
	draw_circle(Vector2(cx, cy + h*0.06), w * 0.07, fg.darkened(0.40))

# ── Acolyte (candle + flame) ─────────────────────────────────────────────────

func _draw_acolyte(cx: float, cy: float, w: float, h: float, fg: Color, shd: Color) -> void:
	draw_rect(Rect2(cx - w*0.10 + 2, cy + h*0.02 + 2, w*0.20, h*0.30), shd)
	draw_rect(Rect2(cx - w*0.10, cy + h*0.02, w*0.20, h*0.30), fg.darkened(0.20))
	draw_polygon(PackedVector2Array([
		Vector2(cx, cy - h*0.22), Vector2(cx - w*0.10, cy + h*0.02), Vector2(cx + w*0.10, cy + h*0.02),
	]), PackedColorArray([Color(1.0, 0.90, 0.40), Color(1.0, 0.45, 0.10), Color(1.0, 0.45, 0.10)]))

# ── Familiar (cat head) ──────────────────────────────────────────────────────

func _draw_familiar(cx: float, cy: float, w: float, h: float, fg: Color, shd: Color) -> void:
	draw_circle(Vector2(cx + 2, cy + h*0.06 + 2), w * 0.26, shd)
	draw_circle(Vector2(cx, cy + h*0.06), w * 0.26, fg)
	draw_polygon(PackedVector2Array([
		Vector2(cx - w*0.24, cy - h*0.14), Vector2(cx - w*0.10, cy - h*0.06), Vector2(cx - w*0.28, cy - h*0.06)
	]), PackedColorArray([fg, fg, fg]))
	draw_polygon(PackedVector2Array([
		Vector2(cx + w*0.24, cy - h*0.14), Vector2(cx + w*0.28, cy - h*0.06), Vector2(cx + w*0.10, cy - h*0.06)
	]), PackedColorArray([fg, fg, fg]))
	draw_circle(Vector2(cx - w*0.09, cy + h*0.04), w * 0.04, shd.darkened(0.65))
	draw_circle(Vector2(cx + w*0.09, cy + h*0.04), w * 0.04, shd.darkened(0.65))

# ── Coin Sage (coin) ─────────────────────────────────────────────────────────

func _draw_coin_sage(cx: float, cy: float, w: float, h: float, fg: Color, shd: Color) -> void:
	draw_circle(Vector2(cx + 2, cy + 2), w * 0.30, shd)
	draw_circle(Vector2(cx, cy), w * 0.30, fg)
	draw_circle(Vector2(cx, cy), w * 0.18, fg.darkened(0.22))
	draw_circle(Vector2(cx - w*0.12, cy - h*0.12), w * 0.06, fg.lightened(0.42))

# ── Harrower (thorned staff) ─────────────────────────────────────────────────

func _draw_harrower(cx: float, cy: float, w: float, h: float, fg: Color, shd: Color) -> void:
	draw_line(Vector2(cx + 2, cy - h*0.36 + 2), Vector2(cx + 2, cy + h*0.36 + 2), shd, w*0.08)
	draw_line(Vector2(cx, cy - h*0.36), Vector2(cx, cy + h*0.36), fg, w*0.08)
	for i in range(3):
		var ty := cy - h*0.20 + float(i) * h*0.18
		draw_line(Vector2(cx + 1, ty + 1), Vector2(cx - w*0.24 + 1, ty - h*0.08 + 1), shd, 2.0)
		draw_line(Vector2(cx + 1, ty + 1), Vector2(cx + w*0.24 + 1, ty - h*0.08 + 1), shd, 2.0)
		draw_line(Vector2(cx, ty), Vector2(cx - w*0.24, ty - h*0.08), fg, 2.0)
		draw_line(Vector2(cx, ty), Vector2(cx + w*0.24, ty - h*0.08), fg, 2.0)

# ── Warchanter (drum) ────────────────────────────────────────────────────────

func _draw_warchanter(cx: float, cy: float, w: float, h: float, fg: Color, shd: Color) -> void:
	draw_rect(Rect2(cx - w*0.26 + 2, cy - h*0.12 + 2, w*0.52, h*0.28), shd)
	draw_rect(Rect2(cx - w*0.26, cy - h*0.12, w*0.52, h*0.28), fg.darkened(0.15))
	draw_rect(Rect2(cx - w*0.28 + 2, cy - h*0.16 + 2, w*0.56, h*0.08), shd)
	draw_rect(Rect2(cx - w*0.28, cy - h*0.16, w*0.56, h*0.08), fg)
	draw_rect(Rect2(cx - w*0.28 + 2, cy + h*0.14 + 2, w*0.56, h*0.08), shd)
	draw_rect(Rect2(cx - w*0.28, cy + h*0.14, w*0.56, h*0.08), fg)
	draw_line(Vector2(cx + w*0.22 + 2, cy - h*0.32 + 2), Vector2(cx + w*0.38 + 2, cy - h*0.10 + 2), shd, w*0.07)
	draw_line(Vector2(cx + w*0.22, cy - h*0.32), Vector2(cx + w*0.38, cy - h*0.10), fg.lightened(0.10), w*0.07)

# ── Warden (orb staff) ───────────────────────────────────────────────────────

func _draw_warden(cx: float, cy: float, w: float, h: float, fg: Color, shd: Color) -> void:
	draw_line(Vector2(cx + 2, cy - h*0.10 + 2), Vector2(cx + 2, cy + h*0.38 + 2), shd, w*0.08)
	draw_line(Vector2(cx, cy - h*0.10), Vector2(cx, cy + h*0.38), fg, w*0.08)
	draw_circle(Vector2(cx + 2, cy - h*0.26 + 2), w * 0.20, shd)
	draw_circle(Vector2(cx, cy - h*0.26), w * 0.20, fg)
	draw_circle(Vector2(cx - w*0.06, cy - h*0.30), w * 0.07, fg.lightened(0.36))

# ── Runic Scribe (scroll) ────────────────────────────────────────────────────

func _draw_runic_scribe(cx: float, cy: float, w: float, h: float, fg: Color, shd: Color) -> void:
	draw_rect(Rect2(cx - w*0.26 + 2, cy - h*0.26 + 2, w*0.52, h*0.52), shd)
	draw_rect(Rect2(cx - w*0.26, cy - h*0.26, w*0.52, h*0.52), fg.darkened(0.22))
	draw_rect(Rect2(cx - w*0.30 + 2, cy - h*0.30 + 2, w*0.60, h*0.10), shd)
	draw_rect(Rect2(cx - w*0.30, cy - h*0.30, w*0.60, h*0.10), fg)
	draw_rect(Rect2(cx - w*0.30 + 2, cy + h*0.20 + 2, w*0.60, h*0.10), shd)
	draw_rect(Rect2(cx - w*0.30, cy + h*0.20, w*0.60, h*0.10), fg)
	for i in range(3):
		var ly := cy - h*0.14 + float(i) * h*0.14
		draw_line(Vector2(cx - w*0.18 + 1, ly + 1), Vector2(cx + w*0.18 + 1, ly + 1), shd.darkened(0.15), 1.5)
		draw_line(Vector2(cx - w*0.18, ly), Vector2(cx + w*0.18, ly), shd.darkened(0.65), 1.5)

# ── Elf Scout (leaf arrow) ───────────────────────────────────────────────────

func _draw_elf_scout(cx: float, cy: float, w: float, h: float, fg: Color, shd: Color) -> void:
	draw_line(Vector2(cx + 2, cy - h*0.22 + 2), Vector2(cx + 2, cy + h*0.36 + 2), shd, w*0.07)
	draw_line(Vector2(cx, cy - h*0.22), Vector2(cx, cy + h*0.36), fg, w*0.07)
	draw_polygon(PackedVector2Array([
		Vector2(cx, cy - h*0.40), Vector2(cx - w*0.20, cy - h*0.16),
		Vector2(cx, cy - h*0.24), Vector2(cx + w*0.20, cy - h*0.16),
	]), PackedColorArray([fg, fg, fg, fg]))
	draw_line(Vector2(cx + 1, cy + h*0.24 + 1), Vector2(cx - w*0.10 + 1, cy + h*0.34 + 1), shd, 1.5)
	draw_line(Vector2(cx + 1, cy + h*0.24 + 1), Vector2(cx + w*0.10 + 1, cy + h*0.34 + 1), shd, 1.5)
	draw_line(Vector2(cx, cy + h*0.24), Vector2(cx - w*0.10, cy + h*0.34), fg, 1.5)
	draw_line(Vector2(cx, cy + h*0.24), Vector2(cx + w*0.10, cy + h*0.34), fg, 1.5)

# ── Thornguard (shield + top spike) ─────────────────────────────────────────

func _draw_thornguard(cx: float, cy: float, w: float, h: float, fg: Color, shd: Color) -> void:
	draw_polygon(PackedVector2Array([
		Vector2(cx + 2, cy + h*0.30 + 2), Vector2(cx - w*0.28 + 2, cy - h*0.04 + 2),
		Vector2(cx - w*0.28 + 2, cy - h*0.22 + 2), Vector2(cx + 2, cy - h*0.30 + 2),
		Vector2(cx + w*0.28 + 2, cy - h*0.22 + 2), Vector2(cx + w*0.28 + 2, cy - h*0.04 + 2),
	]), PackedColorArray([shd, shd, shd, shd, shd, shd]))
	draw_polygon(PackedVector2Array([
		Vector2(cx, cy + h*0.30), Vector2(cx - w*0.28, cy - h*0.04),
		Vector2(cx - w*0.28, cy - h*0.22), Vector2(cx, cy - h*0.30),
		Vector2(cx + w*0.28, cy - h*0.22), Vector2(cx + w*0.28, cy - h*0.04),
	]), PackedColorArray([fg, fg, fg, fg, fg, fg]))
	draw_polygon(PackedVector2Array([
		Vector2(cx, cy - h*0.42), Vector2(cx - w*0.08, cy - h*0.30), Vector2(cx + w*0.08, cy - h*0.30)
	]), PackedColorArray([fg, fg, fg]))

# ── Duskblade (curved saber) ─────────────────────────────────────────────────

func _draw_duskblade(cx: float, cy: float, w: float, h: float, fg: Color, shd: Color) -> void:
	draw_arc(Vector2(cx + w*0.14 + 2, cy + 2), w * 0.42, -PI * 0.85, PI * 0.15, 16, shd, w * 0.09)
	draw_arc(Vector2(cx + w*0.14, cy), w * 0.42, -PI * 0.85, PI * 0.15, 16, fg, w * 0.09)
	draw_line(Vector2(cx - w*0.12 + 2, cy + h*0.18 + 2), Vector2(cx + w*0.12 + 2, cy + h*0.18 + 2), shd, w*0.09)
	draw_line(Vector2(cx - w*0.12, cy + h*0.18), Vector2(cx + w*0.12, cy + h*0.18), fg.darkened(0.10), w*0.09)

# ── Spiritbark (glowing tree trunk) ─────────────────────────────────────────

func _draw_spiritbark(cx: float, cy: float, w: float, h: float, fg: Color, shd: Color) -> void:
	draw_rect(Rect2(cx - w*0.10 + 2, cy - h*0.28 + 2, w*0.20, h*0.56), shd)
	draw_rect(Rect2(cx - w*0.10, cy - h*0.28, w*0.20, h*0.56), fg.darkened(0.28))
	draw_line(Vector2(cx + 1, cy - h*0.14 + 1), Vector2(cx - w*0.26 + 1, cy - h*0.30 + 1), shd, w*0.07)
	draw_line(Vector2(cx + 1, cy - h*0.04 + 1), Vector2(cx + w*0.26 + 1, cy - h*0.20 + 1), shd, w*0.07)
	draw_line(Vector2(cx, cy - h*0.14), Vector2(cx - w*0.26, cy - h*0.30), fg.darkened(0.28), w*0.07)
	draw_line(Vector2(cx, cy - h*0.04), Vector2(cx + w*0.26, cy - h*0.20), fg.darkened(0.28), w*0.07)
	draw_circle(Vector2(cx + 2, cy - h*0.08 + 2), w * 0.15, shd)
	draw_circle(Vector2(cx, cy - h*0.08), w * 0.15, fg.lightened(0.28))

# ── Verdant Archer (bow + arrow) ─────────────────────────────────────────────

func _draw_verdant_archer(cx: float, cy: float, w: float, h: float, fg: Color, shd: Color) -> void:
	draw_arc(Vector2(cx - w*0.06 + 2, cy + 2), w * 0.34, -PI * 0.60, PI * 0.60, 14, shd, w*0.08)
	draw_arc(Vector2(cx - w*0.06, cy), w * 0.34, -PI * 0.60, PI * 0.60, 14, fg, w*0.08)
	draw_line(Vector2(cx + w*0.16 + 2, cy - h*0.30 + 2), Vector2(cx + w*0.16 + 2, cy + h*0.30 + 2), shd, w*0.05)
	draw_line(Vector2(cx + w*0.16, cy - h*0.30), Vector2(cx + w*0.16, cy + h*0.30), fg, w*0.05)
	draw_polygon(PackedVector2Array([
		Vector2(cx + w*0.16, cy - h*0.38), Vector2(cx + w*0.08, cy - h*0.28), Vector2(cx + w*0.24, cy - h*0.28)
	]), PackedColorArray([fg, fg, fg]))

# ── Moonsong (crescent arc + stars) ─────────────────────────────────────────

func _draw_moonsong(cx: float, cy: float, w: float, h: float, fg: Color, shd: Color) -> void:
	draw_arc(Vector2(cx + 2, cy + 2), w * 0.30, -PI * 0.75, PI * 0.75, 18, shd, w * 0.12)
	draw_arc(Vector2(cx, cy), w * 0.30, -PI * 0.75, PI * 0.75, 18, fg, w * 0.12)
	for sd in [Vector2(-w*0.16, -h*0.20), Vector2(w*0.20, -h*0.14), Vector2(w*0.10, h*0.22)]:
		draw_circle(Vector2(cx + sd.x + 1, cy + sd.y + 1), w * 0.030, shd)
		draw_circle(Vector2(cx + sd.x, cy + sd.y), w * 0.030, fg.lightened(0.32))

# ── Fernweave (fern frond) ───────────────────────────────────────────────────

func _draw_fernweave(cx: float, cy: float, w: float, h: float, fg: Color, shd: Color) -> void:
	draw_line(Vector2(cx + 2, cy - h*0.36 + 2), Vector2(cx - w*0.04 + 2, cy + h*0.38 + 2), shd, w*0.07)
	draw_line(Vector2(cx, cy - h*0.36), Vector2(cx - w*0.04, cy + h*0.38), fg, w*0.07)
	for i in range(4):
		var ly := cy - h*0.20 + float(i) * h*0.16
		var side := 1.0 if i % 2 == 0 else -1.0
		draw_line(Vector2(cx + 1, ly + 1), Vector2(cx + side * w*0.24 + 1, ly - h*0.08 + 1), shd, w*0.06)
		draw_line(Vector2(cx, ly), Vector2(cx + side * w*0.24, ly - h*0.08), fg, w*0.06)

# ── Soul Tender (heart) ──────────────────────────────────────────────────────

func _draw_soul_tender(cx: float, cy: float, w: float, h: float, fg: Color, shd: Color) -> void:
	draw_circle(Vector2(cx - w*0.12 + 2, cy - h*0.06 + 2), w * 0.18, shd)
	draw_circle(Vector2(cx + w*0.12 + 2, cy - h*0.06 + 2), w * 0.18, shd)
	draw_polygon(PackedVector2Array([
		Vector2(cx + 2, cy + h*0.28 + 2), Vector2(cx - w*0.28 + 2, cy - h*0.06 + 2), Vector2(cx + w*0.28 + 2, cy - h*0.06 + 2)
	]), PackedColorArray([shd, shd, shd]))
	draw_circle(Vector2(cx - w*0.12, cy - h*0.06), w * 0.18, fg)
	draw_circle(Vector2(cx + w*0.12, cy - h*0.06), w * 0.18, fg)
	draw_polygon(PackedVector2Array([
		Vector2(cx, cy + h*0.28), Vector2(cx - w*0.28, cy - h*0.06), Vector2(cx + w*0.28, cy - h*0.06)
	]), PackedColorArray([fg, fg, fg]))

# ── Thornborn (spike fan) ────────────────────────────────────────────────────

func _draw_thornborn(cx: float, cy: float, w: float, h: float, fg: Color, shd: Color) -> void:
	var base_y := cy + h * 0.22
	var tips := [Vector2(-w*0.28, -h*0.30), Vector2(-w*0.14, -h*0.40), Vector2(0.0, -h*0.44),
				 Vector2(w*0.14, -h*0.38), Vector2(w*0.28, -h*0.28)]
	for tip in tips:
		draw_line(Vector2(cx + 1, base_y + 1), Vector2(cx + tip.x + 1, cy + tip.y + 1), shd, w*0.08)
		draw_line(Vector2(cx, base_y), Vector2(cx + tip.x, cy + tip.y), fg, w*0.08)

# ── Dreamhunter (dreamcatcher) ───────────────────────────────────────────────

func _draw_dreamhunter(cx: float, cy: float, w: float, h: float, fg: Color, shd: Color) -> void:
	var cc := Vector2(cx, cy - h*0.06)
	draw_arc(cc + Vector2(2, 2), w * 0.26, 0, TAU, 20, shd, w*0.06)
	draw_arc(cc, w * 0.26, 0, TAU, 20, fg, w*0.06)
	for i in range(4):
		var a := float(i) * PI * 0.5
		var r := w * 0.26
		draw_line(cc + Vector2(cos(a) * r + 1, sin(a) * r + 1), cc + Vector2(-cos(a) * r + 1, -sin(a) * r + 1), shd, 1.0)
		draw_line(cc + Vector2(cos(a) * r, sin(a) * r), cc + Vector2(-cos(a) * r, -sin(a) * r), fg.darkened(0.30), 1.0)
	for fx in [-w*0.10, 0.0, w*0.10]:
		draw_line(Vector2(cx + fx + 1, cy + h*0.22 + 1), Vector2(cx + fx + 1, cy + h*0.38 + 1), shd, w*0.05)
		draw_line(Vector2(cx + fx, cy + h*0.22), Vector2(cx + fx, cy + h*0.38), fg, w*0.05)

# ── Pale Warden (pale shield) ────────────────────────────────────────────────

func _draw_pale_warden(cx: float, cy: float, w: float, h: float, fg: Color, shd: Color) -> void:
	var light := fg.lightened(0.32)
	draw_polygon(PackedVector2Array([
		Vector2(cx + 2, cy + h*0.34 + 2), Vector2(cx - w*0.28 + 2, cy - h*0.04 + 2),
		Vector2(cx - w*0.28 + 2, cy - h*0.24 + 2), Vector2(cx + 2, cy - h*0.32 + 2),
		Vector2(cx + w*0.28 + 2, cy - h*0.24 + 2), Vector2(cx + w*0.28 + 2, cy - h*0.04 + 2),
	]), PackedColorArray([shd, shd, shd, shd, shd, shd]))
	draw_polygon(PackedVector2Array([
		Vector2(cx, cy + h*0.34), Vector2(cx - w*0.28, cy - h*0.04),
		Vector2(cx - w*0.28, cy - h*0.24), Vector2(cx, cy - h*0.32),
		Vector2(cx + w*0.28, cy - h*0.24), Vector2(cx + w*0.28, cy - h*0.04),
	]), PackedColorArray([light, light, light, light, light, light]))
	draw_polygon(PackedVector2Array([
		Vector2(cx, cy + h*0.22), Vector2(cx - w*0.16, cy - h*0.02),
		Vector2(cx - w*0.16, cy - h*0.16), Vector2(cx, cy - h*0.22),
		Vector2(cx + w*0.16, cy - h*0.16), Vector2(cx + w*0.16, cy - h*0.02),
	]), PackedColorArray([fg, fg, fg, fg, fg, fg]))

# ── Ashveil (wavy veil) ──────────────────────────────────────────────────────

func _draw_ashveil(cx: float, cy: float, w: float, h: float, fg: Color, shd: Color) -> void:
	for i in range(5):
		var ly := cy - h*0.24 + float(i) * h*0.12
		var wc := Color(fg.r, fg.g, fg.b, 0.45 + 0.10 * float(i))
		for p in range(5):
			var x0 := cx - w*0.30 + float(p) * w*0.15
			var x1 := x0 + w*0.15
			var yo := h*0.04 * (1.0 if p % 2 == 0 else -1.0)
			draw_line(Vector2(x0 + 1, ly + yo + 1), Vector2(x1 + 1, ly - yo + 1), shd.darkened(0.20), 2.0)
			draw_line(Vector2(x0, ly + yo), Vector2(x1, ly - yo), wc, 2.0)

# ── Root Caller (branching roots) ────────────────────────────────────────────

func _draw_root_caller(cx: float, cy: float, w: float, h: float, fg: Color, shd: Color) -> void:
	draw_line(Vector2(cx + 2, cy - h*0.34 + 2), Vector2(cx + 2, cy + h*0.04 + 2), shd, w*0.08)
	draw_line(Vector2(cx, cy - h*0.34), Vector2(cx, cy + h*0.04), fg, w*0.08)
	var origins := [Vector2(-w*0.08, h*0.06), Vector2(w*0.08, h*0.06), Vector2(-w*0.04, h*0.18), Vector2(w*0.04, h*0.18)]
	var roots := [Vector2(-w*0.28, h*0.30), Vector2(w*0.28, h*0.30), Vector2(-w*0.18, h*0.40), Vector2(w*0.18, h*0.40)]
	for i in range(4):
		draw_line(Vector2(cx + origins[i].x + 1, cy + origins[i].y + 1), Vector2(cx + roots[i].x + 1, cy + roots[i].y + 1), shd, w*0.07)
		draw_line(Vector2(cx + origins[i].x, cy + origins[i].y), Vector2(cx + roots[i].x, cy + roots[i].y), fg, w*0.07)

# ── The Dreamer (closed eye) ─────────────────────────────────────────────────

func _draw_the_dreamer(cx: float, cy: float, w: float, h: float, fg: Color, shd: Color) -> void:
	draw_arc(Vector2(cx + 2, cy + 2), w * 0.28, PI, TAU, 14, shd, w*0.08)
	draw_arc(Vector2(cx, cy), w * 0.28, PI, TAU, 14, fg, w*0.08)
	draw_line(Vector2(cx - w*0.28 + 2, cy + 2), Vector2(cx + w*0.28 + 2, cy + 2), shd, w*0.07)
	draw_line(Vector2(cx - w*0.28, cy), Vector2(cx + w*0.28, cy), fg, w*0.07)
	for i in range(5):
		var lx := cx - w*0.20 + float(i) * w*0.10
		draw_line(Vector2(lx + 1, cy - w*0.04 + 1), Vector2(lx + 1, cy - w*0.14 + 1), shd, 1.5)
		draw_line(Vector2(lx, cy - w*0.04), Vector2(lx, cy - w*0.14), fg.darkened(0.08), 1.5)
	for sd in [Vector2(-w*0.14, -h*0.22), Vector2(w*0.18, -h*0.18)]:
		draw_circle(Vector2(cx + sd.x + 1, cy + sd.y + 1), w * 0.028, shd)
		draw_circle(Vector2(cx + sd.x, cy + sd.y), w * 0.028, fg.lightened(0.42))

# ── Ancient Grove (layered canopy tree) ──────────────────────────────────────

func _draw_ancient_grove(cx: float, cy: float, w: float, h: float, fg: Color, shd: Color) -> void:
	draw_rect(Rect2(cx - w*0.10 + 2, cy + h*0.08 + 2, w*0.20, h*0.30), shd)
	draw_rect(Rect2(cx - w*0.10, cy + h*0.08, w*0.20, h*0.30), fg.darkened(0.30))
	draw_circle(Vector2(cx + 2, cy - h*0.12 + 2), w * 0.28, shd)
	draw_circle(Vector2(cx, cy - h*0.12), w * 0.28, fg)
	draw_circle(Vector2(cx - w*0.10 + 2, cy - h*0.22 + 2), w * 0.20, shd)
	draw_circle(Vector2(cx - w*0.10, cy - h*0.22), w * 0.20, fg)
	draw_circle(Vector2(cx + w*0.10 + 2, cy - h*0.18 + 2), w * 0.18, shd)
	draw_circle(Vector2(cx + w*0.10, cy - h*0.18), w * 0.18, fg)

# ── Tether (chain link pair) ─────────────────────────────────────────────────

func _draw_tether(cx: float, cy: float, w: float, h: float, fg: Color, shd: Color) -> void:
	draw_arc(Vector2(cx + 2, cy - h*0.12 + 2), w * 0.20, 0, TAU, 16, shd, w*0.09)
	draw_arc(Vector2(cx + 2, cy + h*0.12 + 2), w * 0.20, 0, TAU, 16, shd, w*0.09)
	draw_arc(Vector2(cx, cy - h*0.12), w * 0.20, 0, TAU, 16, fg, w*0.09)
	draw_arc(Vector2(cx, cy + h*0.12), w * 0.20, 0, TAU, 16, fg, w*0.09)
	draw_rect(Rect2(cx - w*0.10 + 2, cy - h*0.06 + 2, w*0.20, h*0.12), shd)
	draw_rect(Rect2(cx - w*0.10, cy - h*0.06, w*0.20, h*0.12), fg)

# ── Seeker (magnifying glass) ────────────────────────────────────────────────

func _draw_seeker(cx: float, cy: float, w: float, h: float, fg: Color, shd: Color) -> void:
	draw_arc(Vector2(cx - w*0.06 + 2, cy - h*0.06 + 2), w * 0.22, 0, TAU, 18, shd, w*0.09)
	draw_arc(Vector2(cx - w*0.06, cy - h*0.06), w * 0.22, 0, TAU, 18, fg, w*0.09)
	draw_line(Vector2(cx + w*0.10 + 2, cy + h*0.10 + 2), Vector2(cx + w*0.28 + 2, cy + h*0.32 + 2), shd, w*0.10)
	draw_line(Vector2(cx + w*0.10, cy + h*0.10), Vector2(cx + w*0.28, cy + h*0.32), fg.darkened(0.10), w*0.10)

# ── Pact Kin (two linked rings) ──────────────────────────────────────────────

func _draw_pact_kin(cx: float, cy: float, w: float, h: float, fg: Color, shd: Color) -> void:
	draw_arc(Vector2(cx - w*0.12 + 2, cy + 2), w * 0.20, 0, TAU, 18, shd, w*0.08)
	draw_arc(Vector2(cx + w*0.12 + 2, cy + 2), w * 0.20, 0, TAU, 18, shd, w*0.08)
	draw_arc(Vector2(cx - w*0.12, cy), w * 0.20, 0, TAU, 18, fg, w*0.08)
	draw_arc(Vector2(cx + w*0.12, cy), w * 0.20, 0, TAU, 18, fg, w*0.08)

# ── Fury Kin (ring + inner flame) ────────────────────────────────────────────

func _draw_fury_kin(cx: float, cy: float, w: float, h: float, fg: Color, shd: Color) -> void:
	draw_arc(Vector2(cx + 2, cy + 2), w * 0.28, 0, TAU, 20, shd, w*0.08)
	draw_arc(Vector2(cx, cy), w * 0.28, 0, TAU, 20, fg, w*0.08)
	draw_polygon(PackedVector2Array([
		Vector2(cx, cy - h*0.20), Vector2(cx - w*0.12, cy + h*0.04),
		Vector2(cx - w*0.05, cy - h*0.04), Vector2(cx, cy + h*0.14),
		Vector2(cx + w*0.05, cy - h*0.04), Vector2(cx + w*0.12, cy + h*0.04),
	]), PackedColorArray([Color(1.0,0.85,0.25), Color(1.0,0.30,0.10), Color(1.0,0.60,0.10), Color(1.0,0.30,0.10), Color(1.0,0.60,0.10), Color(1.0,0.30,0.10)]))

# ── Weave Kin (diagonal lattice) ─────────────────────────────────────────────

func _draw_weave_kin(cx: float, cy: float, w: float, h: float, fg: Color, shd: Color) -> void:
	for i in range(4):
		var ox := -w*0.28 + float(i) * w*0.19
		draw_line(Vector2(cx + ox + 1, cy - h*0.34 + 1), Vector2(cx + ox + w*0.38 + 1, cy + h*0.34 + 1), shd, w*0.07)
		draw_line(Vector2(cx + ox, cy - h*0.34), Vector2(cx + ox + w*0.38, cy + h*0.34), fg, w*0.07)
	for i in range(4):
		var ox := w*0.28 - float(i) * w*0.19
		draw_line(Vector2(cx + ox + 1, cy - h*0.34 + 1), Vector2(cx + ox - w*0.38 + 1, cy + h*0.34 + 1), shd, w*0.07)
		draw_line(Vector2(cx + ox, cy - h*0.34), Vector2(cx + ox - w*0.38, cy + h*0.34), fg, w*0.07)

# ── Oath Binder (thick ring) ─────────────────────────────────────────────────

func _draw_oath_binder(cx: float, cy: float, w: float, h: float, fg: Color, shd: Color) -> void:
	draw_circle(Vector2(cx + 2, cy + 2), w * 0.30, shd)
	draw_circle(Vector2(cx, cy), w * 0.30, fg)
	draw_circle(Vector2(cx, cy), w * 0.16, _race_color())

# ── Bond Warden (shield + chain link) ────────────────────────────────────────

func _draw_bond_warden(cx: float, cy: float, w: float, h: float, fg: Color, shd: Color) -> void:
	draw_polygon(PackedVector2Array([
		Vector2(cx + 2, cy + h*0.12 + 2), Vector2(cx - w*0.26 + 2, cy - h*0.10 + 2),
		Vector2(cx - w*0.26 + 2, cy - h*0.28 + 2), Vector2(cx + 2, cy - h*0.34 + 2),
		Vector2(cx + w*0.26 + 2, cy - h*0.28 + 2), Vector2(cx + w*0.26 + 2, cy - h*0.10 + 2),
	]), PackedColorArray([shd, shd, shd, shd, shd, shd]))
	draw_polygon(PackedVector2Array([
		Vector2(cx, cy + h*0.12), Vector2(cx - w*0.26, cy - h*0.10),
		Vector2(cx - w*0.26, cy - h*0.28), Vector2(cx, cy - h*0.34),
		Vector2(cx + w*0.26, cy - h*0.28), Vector2(cx + w*0.26, cy - h*0.10),
	]), PackedColorArray([fg, fg, fg, fg, fg, fg]))
	draw_arc(Vector2(cx + 2, cy + h*0.26 + 2), w * 0.12, 0, TAU, 12, shd, w*0.07)
	draw_arc(Vector2(cx, cy + h*0.26), w * 0.12, 0, TAU, 12, fg, w*0.07)

# ── Martyr Kin (cross) ───────────────────────────────────────────────────────

func _draw_martyr_kin(cx: float, cy: float, w: float, h: float, fg: Color, shd: Color) -> void:
	draw_rect(Rect2(cx - w*0.08 + 2, cy - h*0.36 + 2, w*0.16, h*0.72), shd)
	draw_rect(Rect2(cx - w*0.30 + 2, cy - h*0.12 + 2, w*0.60, h*0.16), shd)
	draw_rect(Rect2(cx - w*0.08, cy - h*0.36, w*0.16, h*0.72), fg)
	draw_rect(Rect2(cx - w*0.30, cy - h*0.12, w*0.60, h*0.16), fg)

# ── Rite Herald (curved horn) ────────────────────────────────────────────────

func _draw_rite_herald(cx: float, cy: float, w: float, h: float, fg: Color, shd: Color) -> void:
	draw_polygon(PackedVector2Array([
		Vector2(cx - w*0.30 + 2, cy + h*0.04 + 2), Vector2(cx - w*0.30 + 2, cy - h*0.04 + 2),
		Vector2(cx + w*0.22 + 2, cy - h*0.18 + 2), Vector2(cx + w*0.22 + 2, cy + h*0.18 + 2),
	]), PackedColorArray([shd, shd, shd, shd]))
	draw_polygon(PackedVector2Array([
		Vector2(cx - w*0.30, cy + h*0.04), Vector2(cx - w*0.30, cy - h*0.04),
		Vector2(cx + w*0.22, cy - h*0.18), Vector2(cx + w*0.22, cy + h*0.18),
	]), PackedColorArray([fg, fg, fg, fg]))
	draw_arc(Vector2(cx + w*0.22 + 2, cy + 2), w * 0.18, -PI * 0.60, PI * 0.60, 10, shd, w*0.09)
	draw_arc(Vector2(cx + w*0.22, cy), w * 0.18, -PI * 0.60, PI * 0.60, 10, fg, w*0.09)

# ── Vow Guard (shield + star) ────────────────────────────────────────────────

func _draw_vow_guard(cx: float, cy: float, w: float, h: float, fg: Color, shd: Color) -> void:
	draw_polygon(PackedVector2Array([
		Vector2(cx + 2, cy + h*0.30 + 2), Vector2(cx - w*0.28 + 2, cy - h*0.06 + 2),
		Vector2(cx - w*0.28 + 2, cy - h*0.28 + 2), Vector2(cx + 2, cy - h*0.36 + 2),
		Vector2(cx + w*0.28 + 2, cy - h*0.28 + 2), Vector2(cx + w*0.28 + 2, cy - h*0.06 + 2),
	]), PackedColorArray([shd, shd, shd, shd, shd, shd]))
	draw_polygon(PackedVector2Array([
		Vector2(cx, cy + h*0.30), Vector2(cx - w*0.28, cy - h*0.06),
		Vector2(cx - w*0.28, cy - h*0.28), Vector2(cx, cy - h*0.36),
		Vector2(cx + w*0.28, cy - h*0.28), Vector2(cx + w*0.28, cy - h*0.06),
	]), PackedColorArray([fg, fg, fg, fg, fg, fg]))
	var sr := w * 0.10
	var si := w * 0.05
	var star_pts := PackedVector2Array()
	for i in range(10):
		var a := float(i) * PI / 5.0 - PI * 0.5
		var r := sr if i % 2 == 0 else si
		star_pts.append(Vector2(cx + cos(a) * r, cy - h*0.04 + sin(a) * r))
	var _star_clr := PackedColorArray(); _star_clr.resize(10); _star_clr.fill(shd.darkened(0.55))
	draw_polygon(star_pts, _star_clr)

# ── Bond Shatter (broken ring) ───────────────────────────────────────────────

func _draw_bond_shatter(cx: float, cy: float, w: float, h: float, fg: Color, shd: Color) -> void:
	draw_arc(Vector2(cx + 2, cy + 2), w * 0.26, PI * 0.22, PI * 1.78, 16, shd, w*0.09)
	draw_arc(Vector2(cx, cy), w * 0.26, PI * 0.22, PI * 1.78, 16, fg, w*0.09)
	draw_line(Vector2(cx - w*0.06 + 2, cy - h*0.24 + 2), Vector2(cx + w*0.06 + 2, cy - h*0.38 + 2), shd, 2.5)
	draw_line(Vector2(cx + w*0.06 + 2, cy - h*0.20 + 2), Vector2(cx - w*0.06 + 2, cy - h*0.36 + 2), shd, 2.5)
	draw_line(Vector2(cx - w*0.06, cy - h*0.24), Vector2(cx + w*0.06, cy - h*0.38), fg, 2.5)
	draw_line(Vector2(cx + w*0.06, cy - h*0.20), Vector2(cx - w*0.06, cy - h*0.36), fg, 2.5)

# ── Rite Sage (tall pointed hat) ─────────────────────────────────────────────

func _draw_rite_sage(cx: float, cy: float, w: float, h: float, fg: Color, shd: Color) -> void:
	draw_rect(Rect2(cx - w*0.32 + 2, cy + h*0.12 + 2, w*0.64, h*0.10), shd)
	draw_rect(Rect2(cx - w*0.32, cy + h*0.12, w*0.64, h*0.10), fg)
	draw_polygon(PackedVector2Array([
		Vector2(cx + 2, cy - h*0.36 + 2), Vector2(cx - w*0.16 + 2, cy + h*0.12 + 2), Vector2(cx + w*0.16 + 2, cy + h*0.12 + 2)
	]), PackedColorArray([shd, shd, shd]))
	draw_polygon(PackedVector2Array([
		Vector2(cx, cy - h*0.36), Vector2(cx - w*0.16, cy + h*0.12), Vector2(cx + w*0.16, cy + h*0.12)
	]), PackedColorArray([fg, fg, fg]))
	draw_rect(Rect2(cx - w*0.10 + 2, cy - h*0.04 + 2, w*0.20, h*0.08), shd)
	draw_rect(Rect2(cx - w*0.10, cy - h*0.04, w*0.20, h*0.08), fg.darkened(0.30))

# ── Soul Tether (orb + dotted chain) ─────────────────────────────────────────

func _draw_soul_tether(cx: float, cy: float, w: float, h: float, fg: Color, shd: Color) -> void:
	draw_circle(Vector2(cx + 2, cy - h*0.14 + 2), w * 0.22, shd)
	draw_circle(Vector2(cx, cy - h*0.14), w * 0.22, fg)
	draw_circle(Vector2(cx - w*0.06, cy - h*0.18), w * 0.07, fg.lightened(0.40))
	for i in range(4):
		var dy := cy + h*0.14 + float(i) * h*0.10
		draw_circle(Vector2(cx + 2, dy + 2), w * 0.04, shd)
		draw_circle(Vector2(cx, dy), w * 0.04, fg.darkened(0.10))

# ── Chain Hunter (hook + chain) ──────────────────────────────────────────────

func _draw_chain_hunter(cx: float, cy: float, w: float, h: float, fg: Color, shd: Color) -> void:
	for i in range(4):
		var dy := cy - h*0.08 + float(i) * h*0.12
		draw_arc(Vector2(cx - w*0.14 + 2, dy + 2), w * 0.08, 0, TAU, 10, shd, w*0.06)
		draw_arc(Vector2(cx - w*0.14, dy), w * 0.08, 0, TAU, 10, fg, w*0.06)
	draw_arc(Vector2(cx + w*0.14 + 2, cy - h*0.16 + 2), w * 0.16, -PI * 0.5, PI * 0.5, 10, shd, w*0.08)
	draw_arc(Vector2(cx + w*0.14, cy - h*0.16), w * 0.16, -PI * 0.5, PI * 0.5, 10, fg, w*0.08)
	draw_line(Vector2(cx + w*0.14 + 2, cy + h*0.00 + 2), Vector2(cx + w*0.06 + 2, cy + h*0.08 + 2), shd, w*0.08)
	draw_line(Vector2(cx + w*0.14, cy), Vector2(cx + w*0.06, cy + h*0.08), fg, w*0.08)

# ── Grief Kin (teardrop) ─────────────────────────────────────────────────────

func _draw_grief_kin(cx: float, cy: float, w: float, h: float, fg: Color, shd: Color) -> void:
	draw_circle(Vector2(cx + 2, cy + h*0.14 + 2), w * 0.22, shd)
	draw_circle(Vector2(cx, cy + h*0.14), w * 0.22, fg)
	draw_polygon(PackedVector2Array([
		Vector2(cx + 2, cy - h*0.28 + 2), Vector2(cx - w*0.22 + 2, cy + h*0.14 + 2), Vector2(cx + w*0.22 + 2, cy + h*0.14 + 2)
	]), PackedColorArray([shd, shd, shd]))
	draw_polygon(PackedVector2Array([
		Vector2(cx, cy - h*0.28), Vector2(cx - w*0.22, cy + h*0.14), Vector2(cx + w*0.22, cy + h*0.14)
	]), PackedColorArray([fg, fg, fg]))

# ── Rite Spawner (ritual circle) ─────────────────────────────────────────────

func _draw_rite_spawner(cx: float, cy: float, w: float, h: float, fg: Color, shd: Color) -> void:
	draw_arc(Vector2(cx + 2, cy + 2), w * 0.28, 0, TAU, 20, shd, w*0.07)
	draw_arc(Vector2(cx, cy), w * 0.28, 0, TAU, 20, fg, w*0.07)
	draw_arc(Vector2(cx + 2, cy + 2), w * 0.16, 0, TAU, 16, shd, w*0.05)
	draw_arc(Vector2(cx, cy), w * 0.16, 0, TAU, 16, fg, w*0.05)
	for i in range(4):
		var a := float(i) * PI * 0.5
		draw_line(Vector2(cx + cos(a) * w*0.30 + 1, cy + sin(a) * w*0.30 + 1), Vector2(cx + cos(a) * w*0.38 + 1, cy + sin(a) * w*0.38 + 1), shd, 2.5)
		draw_line(Vector2(cx + cos(a) * w*0.30, cy + sin(a) * w*0.30), Vector2(cx + cos(a) * w*0.38, cy + sin(a) * w*0.38), fg, 2.5)

# ── Covenantling (ring + center dot) ─────────────────────────────────────────

func _draw_covenantling(cx: float, cy: float, w: float, h: float, fg: Color, shd: Color) -> void:
	draw_arc(Vector2(cx + 2, cy + 2), w * 0.28, 0, TAU, 20, shd, w*0.07)
	draw_arc(Vector2(cx, cy), w * 0.28, 0, TAU, 20, fg, w*0.07)
	draw_circle(Vector2(cx + 2, cy + 2), w * 0.08, shd)
	draw_circle(Vector2(cx, cy), w * 0.08, fg.darkened(0.20))

# ── Winder (zigzag spring) ───────────────────────────────────────────────────

func _draw_winder(cx: float, cy: float, w: float, h: float, fg: Color, shd: Color) -> void:
	var steps := 8
	var pts := PackedVector2Array()
	var pts_s := PackedVector2Array()
	for i in range(steps + 1):
		var t := float(i) / float(steps)
		var px := cx + (w*0.28 if i % 2 == 0 else -w*0.28)
		var py := cy - h*0.36 + t * h*0.72
		pts.append(Vector2(px, py))
		pts_s.append(Vector2(px + 2, py + 2))
	for i in range(steps):
		draw_line(pts_s[i], pts_s[i + 1], shd, w*0.09)
		draw_line(pts[i], pts[i + 1], fg, w*0.09)

# ── Sporekeeper (mushroom + floating spores) ─────────────────────────────────

func _draw_sporekeeper(cx: float, cy: float, w: float, h: float, fg: Color, shd: Color) -> void:
	draw_rect(Rect2(cx - w*0.10 + 2, cy + h*0.06 + 2, w*0.20, h*0.28), shd)
	draw_rect(Rect2(cx - w*0.10, cy + h*0.06, w*0.20, h*0.28), fg.darkened(0.15))
	draw_polygon(PackedVector2Array([
		Vector2(cx + 2, cy - h*0.28 + 2), Vector2(cx - w*0.34 + 2, cy + h*0.08 + 2), Vector2(cx + w*0.34 + 2, cy + h*0.08 + 2),
	]), PackedColorArray([shd, shd, shd]))
	draw_polygon(PackedVector2Array([
		Vector2(cx, cy - h*0.28), Vector2(cx - w*0.34, cy + h*0.08), Vector2(cx + w*0.34, cy + h*0.08),
	]), PackedColorArray([fg, fg, fg]))
	for sd in [Vector2(-w*0.30, -h*0.12), Vector2(w*0.32, -h*0.08), Vector2(-w*0.12, -h*0.36), Vector2(w*0.18, -h*0.32)]:
		draw_circle(Vector2(cx + sd.x + 1, cy + sd.y + 1), w * 0.030, shd)
		draw_circle(Vector2(cx + sd.x, cy + sd.y), w * 0.030, fg.lightened(0.22))

# ── Parasite (orb + tendrils) ────────────────────────────────────────────────

func _draw_parasite(cx: float, cy: float, w: float, h: float, fg: Color, shd: Color) -> void:
	draw_circle(Vector2(cx + 2, cy + 2), w * 0.16, shd)
	draw_circle(Vector2(cx, cy), w * 0.16, fg)
	for i in range(6):
		var a := float(i) * TAU / 6.0
		var tx := cx + cos(a) * w * 0.32
		var ty := cy + sin(a) * h * 0.32
		draw_line(Vector2(cx + 1, cy + 1), Vector2(tx + 1, ty + 1), shd, w*0.06)
		draw_line(Vector2(cx, cy), Vector2(tx, ty), fg.darkened(0.15), w*0.06)
		draw_circle(Vector2(tx + 1, ty + 1), w * 0.030, shd)
		draw_circle(Vector2(tx, ty), w * 0.030, fg.lightened(0.10))

# ── Sporeling (small mushroom) ───────────────────────────────────────────────

func _draw_sporeling(cx: float, cy: float, w: float, h: float, fg: Color, shd: Color) -> void:
	draw_rect(Rect2(cx - w*0.08 + 2, cy + h*0.10 + 2, w*0.16, h*0.22), shd)
	draw_rect(Rect2(cx - w*0.08, cy + h*0.10, w*0.16, h*0.22), fg.darkened(0.15))
	draw_polygon(PackedVector2Array([
		Vector2(cx + 2, cy - h*0.18 + 2), Vector2(cx - w*0.22 + 2, cy + h*0.12 + 2), Vector2(cx + w*0.22 + 2, cy + h*0.12 + 2),
	]), PackedColorArray([shd, shd, shd]))
	draw_polygon(PackedVector2Array([
		Vector2(cx, cy - h*0.18), Vector2(cx - w*0.22, cy + h*0.12), Vector2(cx + w*0.22, cy + h*0.12),
	]), PackedColorArray([fg, fg, fg]))

# ── Myco Cap (wide flat mushroom) ────────────────────────────────────────────

func _draw_myco_cap(cx: float, cy: float, w: float, h: float, fg: Color, shd: Color) -> void:
	draw_rect(Rect2(cx - w*0.08 + 2, cy + h*0.04 + 2, w*0.16, h*0.28), shd)
	draw_rect(Rect2(cx - w*0.08, cy + h*0.04, w*0.16, h*0.28), fg.darkened(0.15))
	draw_polygon(PackedVector2Array([
		Vector2(cx + 2, cy - h*0.14 + 2), Vector2(cx - w*0.42 + 2, cy + h*0.06 + 2), Vector2(cx + w*0.42 + 2, cy + h*0.06 + 2),
	]), PackedColorArray([shd, shd, shd]))
	draw_polygon(PackedVector2Array([
		Vector2(cx, cy - h*0.14), Vector2(cx - w*0.42, cy + h*0.06), Vector2(cx + w*0.42, cy + h*0.06),
	]), PackedColorArray([fg, fg, fg]))
	draw_polygon(PackedVector2Array([
		Vector2(cx, cy - h*0.06), Vector2(cx - w*0.42, cy + h*0.06), Vector2(cx + w*0.42, cy + h*0.06),
	]), PackedColorArray([fg.darkened(0.12), fg.darkened(0.12), fg.darkened(0.12)]))

# ── Bloom (flower) ───────────────────────────────────────────────────────────

func _draw_bloom(cx: float, cy: float, w: float, h: float, fg: Color, shd: Color) -> void:
	for i in range(6):
		var a := float(i) * TAU / 6.0
		var px := cx + cos(a) * w * 0.22
		var py := cy + sin(a) * h * 0.22
		draw_circle(Vector2(px + 1, py + 1), w * 0.12, shd)
		draw_circle(Vector2(px, py), w * 0.12, fg.darkened(0.08))
	draw_circle(Vector2(cx + 2, cy + 2), w * 0.12, shd)
	draw_circle(Vector2(cx, cy), w * 0.12, fg.lightened(0.30))

# ── Spore Vent (vent slats + rising spores) ──────────────────────────────────

func _draw_spore_vent(cx: float, cy: float, w: float, h: float, fg: Color, shd: Color) -> void:
	draw_rect(Rect2(cx - w*0.28 + 2, cy - h*0.02 + 2, w*0.56, h*0.30), shd)
	draw_rect(Rect2(cx - w*0.28, cy - h*0.02, w*0.56, h*0.30), fg.darkened(0.25))
	for i in range(3):
		var sy := cy + h*0.06 + float(i) * h*0.08
		draw_rect(Rect2(cx - w*0.24 + 2, sy + 2, w*0.48, h*0.04), shd)
		draw_rect(Rect2(cx - w*0.24, sy, w*0.48, h*0.04), fg)
	for sd in [Vector2(-w*0.14, -h*0.24), Vector2(0.0, -h*0.30), Vector2(w*0.14, -h*0.22)]:
		draw_circle(Vector2(cx + sd.x + 1, cy + sd.y + 1), w * 0.028, shd)
		draw_circle(Vector2(cx + sd.x, cy + sd.y), w * 0.028, fg.lightened(0.20))

# ── Mycelium (node network) ──────────────────────────────────────────────────

func _draw_mycelium(cx: float, cy: float, w: float, h: float, fg: Color, shd: Color) -> void:
	var nodes := [Vector2(0.0, 0.0), Vector2(-w*0.24, -h*0.18), Vector2(w*0.22, -h*0.14),
				  Vector2(-w*0.18, h*0.22), Vector2(w*0.20, h*0.20), Vector2(-w*0.04, -h*0.36)]
	var edges := [[0,1],[0,2],[0,3],[0,4],[1,5],[1,3],[2,4]]
	for e in edges:
		var a: Vector2 = nodes[e[0]]
		var b: Vector2 = nodes[e[1]]
		draw_line(Vector2(cx + a.x + 1, cy + a.y + 1), Vector2(cx + b.x + 1, cy + b.y + 1), shd, w*0.05)
		draw_line(Vector2(cx + a.x, cy + a.y), Vector2(cx + b.x, cy + b.y), fg.darkened(0.20), w*0.05)
	for n in nodes:
		draw_circle(Vector2(cx + n.x + 1, cy + n.y + 1), w * 0.045, shd)
		draw_circle(Vector2(cx + n.x, cy + n.y), w * 0.045, fg)

# ── Decomposer (overlapping decay circles) ───────────────────────────────────

func _draw_decomposer(cx: float, cy: float, w: float, h: float, fg: Color, shd: Color) -> void:
	for cd in [Vector2(-w*0.14, h*0.04), Vector2(w*0.14, h*0.04), Vector2(0.0, -h*0.10)]:
		draw_circle(Vector2(cx + cd.x + 2, cy + cd.y + 2), w * 0.22, shd)
		draw_circle(Vector2(cx + cd.x, cy + cd.y), w * 0.22, fg.darkened(0.10 + 0.05 * float(fg.r)))
	draw_circle(Vector2(cx + 2, cy + h*0.14 + 2), w * 0.14, shd)
	draw_circle(Vector2(cx, cy + h*0.14), w * 0.14, fg.darkened(0.30))

# ── Hyphae (branching threads) ───────────────────────────────────────────────

func _draw_hyphae(cx: float, cy: float, w: float, h: float, fg: Color, shd: Color) -> void:
	var branches := [
		[Vector2(0.0, h*0.20), Vector2(-w*0.20, -h*0.10)],
		[Vector2(0.0, h*0.20), Vector2(w*0.18, -h*0.12)],
		[Vector2(-w*0.20, -h*0.10), Vector2(-w*0.32, -h*0.30)],
		[Vector2(-w*0.20, -h*0.10), Vector2(-w*0.06, -h*0.32)],
		[Vector2(w*0.18, -h*0.12), Vector2(w*0.30, -h*0.28)],
		[Vector2(w*0.18, -h*0.12), Vector2(w*0.06, -h*0.34)],
	]
	for b in branches:
		draw_line(Vector2(cx + b[0].x + 1, cy + b[0].y + 1), Vector2(cx + b[1].x + 1, cy + b[1].y + 1), shd, w*0.06)
		draw_line(Vector2(cx + b[0].x, cy + b[0].y), Vector2(cx + b[1].x, cy + b[1].y), fg, w*0.06)

# ── Sporefront (large front-facing mushroom) ──────────────────────────────────

func _draw_sporefront(cx: float, cy: float, w: float, h: float, fg: Color, shd: Color) -> void:
	draw_rect(Rect2(cx - w*0.12 + 2, cy + h*0.04 + 2, w*0.24, h*0.32), shd)
	draw_rect(Rect2(cx - w*0.12, cy + h*0.04, w*0.24, h*0.32), fg.darkened(0.15))
	draw_polygon(PackedVector2Array([
		Vector2(cx + 2, cy - h*0.34 + 2), Vector2(cx - w*0.40 + 2, cy + h*0.06 + 2), Vector2(cx + w*0.40 + 2, cy + h*0.06 + 2),
	]), PackedColorArray([shd, shd, shd]))
	draw_polygon(PackedVector2Array([
		Vector2(cx, cy - h*0.34), Vector2(cx - w*0.40, cy + h*0.06), Vector2(cx + w*0.40, cy + h*0.06),
	]), PackedColorArray([fg, fg, fg]))
	for sd in [Vector2(-w*0.18, -h*0.08), Vector2(0.0, -h*0.14), Vector2(w*0.18, -h*0.08)]:
		draw_circle(Vector2(cx + sd.x, cy + sd.y), w * 0.036, fg.darkened(0.25))

# ── Spore Hoarder (bulging sack) ─────────────────────────────────────────────

func _draw_spore_hoarder(cx: float, cy: float, w: float, h: float, fg: Color, shd: Color) -> void:
	draw_circle(Vector2(cx + 2, cy + h*0.10 + 2), w * 0.30, shd)
	draw_circle(Vector2(cx, cy + h*0.10), w * 0.30, fg)
	draw_rect(Rect2(cx - w*0.12 + 2, cy - h*0.22 + 2, w*0.24, h*0.14), shd)
	draw_rect(Rect2(cx - w*0.12, cy - h*0.22, w*0.24, h*0.14), fg.darkened(0.20))
	draw_rect(Rect2(cx - w*0.08 + 2, cy - h*0.28 + 2, w*0.16, h*0.08), shd)
	draw_rect(Rect2(cx - w*0.08, cy - h*0.28, w*0.16, h*0.08), fg.darkened(0.40))
	for sd in [Vector2(-w*0.14, h*0.08), Vector2(w*0.14, h*0.04), Vector2(0.0, h*0.22)]:
		draw_circle(Vector2(cx + sd.x, cy + sd.y), w * 0.030, fg.darkened(0.30))

# ── Sporeguard (mushroom-cap shield) ─────────────────────────────────────────

func _draw_sporeguard(cx: float, cy: float, w: float, h: float, fg: Color, shd: Color) -> void:
	draw_polygon(PackedVector2Array([
		Vector2(cx + 2, cy + h*0.30 + 2), Vector2(cx - w*0.28 + 2, cy - h*0.04 + 2),
		Vector2(cx - w*0.28 + 2, cy - h*0.22 + 2), Vector2(cx + 2, cy - h*0.30 + 2),
		Vector2(cx + w*0.28 + 2, cy - h*0.22 + 2), Vector2(cx + w*0.28 + 2, cy - h*0.04 + 2),
	]), PackedColorArray([shd, shd, shd, shd, shd, shd]))
	draw_polygon(PackedVector2Array([
		Vector2(cx, cy + h*0.30), Vector2(cx - w*0.28, cy - h*0.04),
		Vector2(cx - w*0.28, cy - h*0.22), Vector2(cx, cy - h*0.30),
		Vector2(cx + w*0.28, cy - h*0.22), Vector2(cx + w*0.28, cy - h*0.04),
	]), PackedColorArray([fg, fg, fg, fg, fg, fg]))
	draw_polygon(PackedVector2Array([
		Vector2(cx + 2, cy - h*0.42 + 2), Vector2(cx - w*0.16 + 2, cy - h*0.28 + 2), Vector2(cx + w*0.16 + 2, cy - h*0.28 + 2),
	]), PackedColorArray([shd, shd, shd]))
	draw_polygon(PackedVector2Array([
		Vector2(cx, cy - h*0.42), Vector2(cx - w*0.16, cy - h*0.28), Vector2(cx + w*0.16, cy - h*0.28),
	]), PackedColorArray([fg, fg, fg]))

# ── Myco Sage (mushroom-hat wizard) ──────────────────────────────────────────

func _draw_myco_sage(cx: float, cy: float, w: float, h: float, fg: Color, shd: Color) -> void:
	draw_circle(Vector2(cx + 2, cy + h*0.12 + 2), w * 0.20, shd)
	draw_circle(Vector2(cx, cy + h*0.12), w * 0.20, fg.darkened(0.10))
	draw_circle(Vector2(cx - w*0.06, cy + h*0.08), w * 0.06, shd.darkened(0.55))
	draw_circle(Vector2(cx + w*0.06, cy + h*0.08), w * 0.06, shd.darkened(0.55))
	draw_polygon(PackedVector2Array([
		Vector2(cx + 2, cy - h*0.28 + 2), Vector2(cx - w*0.26 + 2, cy - h*0.02 + 2), Vector2(cx + w*0.26 + 2, cy - h*0.02 + 2),
	]), PackedColorArray([shd, shd, shd]))
	draw_polygon(PackedVector2Array([
		Vector2(cx, cy - h*0.28), Vector2(cx - w*0.26, cy - h*0.02), Vector2(cx + w*0.26, cy - h*0.02),
	]), PackedColorArray([fg, fg, fg]))
	draw_rect(Rect2(cx - w*0.30 + 2, cy - h*0.06 + 2, w*0.60, h*0.08), shd)
	draw_rect(Rect2(cx - w*0.30, cy - h*0.06, w*0.60, h*0.08), fg.lightened(0.10))

# ── Cultivator (spade/shovel) ────────────────────────────────────────────────

func _draw_cultivator(cx: float, cy: float, w: float, h: float, fg: Color, shd: Color) -> void:
	draw_line(Vector2(cx + w*0.06 + 2, cy - h*0.10 + 2), Vector2(cx + w*0.06 + 2, cy + h*0.38 + 2), shd, w*0.08)
	draw_line(Vector2(cx + w*0.06, cy - h*0.10), Vector2(cx + w*0.06, cy + h*0.38), fg, w*0.08)
	draw_polygon(PackedVector2Array([
		Vector2(cx + w*0.06 + 2, cy - h*0.10 + 2), Vector2(cx - w*0.18 + 2, cy - h*0.10 + 2),
		Vector2(cx - w*0.18 + 2, cy - h*0.38 + 2), Vector2(cx + w*0.18 + 2, cy - h*0.38 + 2),
		Vector2(cx + w*0.18 + 2, cy - h*0.10 + 2),
	]), PackedColorArray([shd, shd, shd, shd, shd]))
	draw_polygon(PackedVector2Array([
		Vector2(cx + w*0.06, cy - h*0.10), Vector2(cx - w*0.18, cy - h*0.10),
		Vector2(cx - w*0.18, cy - h*0.38), Vector2(cx + w*0.18, cy - h*0.38),
		Vector2(cx + w*0.18, cy - h*0.10),
	]), PackedColorArray([fg, fg, fg, fg, fg]))
	draw_polygon(PackedVector2Array([
		Vector2(cx + 2, cy - h*0.38 + 2), Vector2(cx - w*0.18 + 2, cy - h*0.10 + 2), Vector2(cx + w*0.18 + 2, cy - h*0.10 + 2)
	]), PackedColorArray([shd, shd, shd]))
	draw_polygon(PackedVector2Array([
		Vector2(cx, cy - h*0.46), Vector2(cx - w*0.18, cy - h*0.38), Vector2(cx + w*0.18, cy - h*0.38)
	]), PackedColorArray([fg, fg, fg]))

# ── Spore Sovereign (crowned mushroom) ───────────────────────────────────────

func _draw_spore_sovereign(cx: float, cy: float, w: float, h: float, fg: Color, shd: Color) -> void:
	draw_rect(Rect2(cx - w*0.10 + 2, cy + h*0.04 + 2, w*0.20, h*0.30), shd)
	draw_rect(Rect2(cx - w*0.10, cy + h*0.04, w*0.20, h*0.30), fg.darkened(0.15))
	draw_polygon(PackedVector2Array([
		Vector2(cx + 2, cy - h*0.22 + 2), Vector2(cx - w*0.36 + 2, cy + h*0.06 + 2), Vector2(cx + w*0.36 + 2, cy + h*0.06 + 2),
	]), PackedColorArray([shd, shd, shd]))
	draw_polygon(PackedVector2Array([
		Vector2(cx, cy - h*0.22), Vector2(cx - w*0.36, cy + h*0.06), Vector2(cx + w*0.36, cy + h*0.06),
	]), PackedColorArray([fg, fg, fg]))
	for i in range(3):
		var px := cx - w*0.18 + float(i) * w*0.18
		draw_polygon(PackedVector2Array([
			Vector2(px + 2, cy - h*0.36 + 2), Vector2(px - w*0.07 + 2, cy - h*0.22 + 2), Vector2(px + w*0.07 + 2, cy - h*0.22 + 2)
		]), PackedColorArray([shd, shd, shd]))
		draw_polygon(PackedVector2Array([
			Vector2(px, cy - h*0.36), Vector2(px - w*0.07, cy - h*0.22), Vector2(px + w*0.07, cy - h*0.22)
		]), PackedColorArray([fg, fg, fg]))

# ── Fungal Ascendant (mushroom in light rays) ────────────────────────────────

func _draw_fungal_ascendant(cx: float, cy: float, w: float, h: float, fg: Color, shd: Color) -> void:
	for i in range(8):
		var a := float(i) * TAU / 8.0
		draw_line(Vector2(cx + cos(a) * w*0.16 + 1, cy + sin(a) * h*0.16 + 1), Vector2(cx + cos(a) * w*0.42 + 1, cy + sin(a) * h*0.42 + 1), shd, w*0.05)
		draw_line(Vector2(cx + cos(a) * w*0.16, cy + sin(a) * h*0.16), Vector2(cx + cos(a) * w*0.42, cy + sin(a) * h*0.42), fg.lightened(0.20), w*0.05)
	draw_rect(Rect2(cx - w*0.08 + 2, cy + h*0.06 + 2, w*0.16, h*0.22), shd)
	draw_rect(Rect2(cx - w*0.08, cy + h*0.06, w*0.16, h*0.22), fg.darkened(0.15))
	draw_polygon(PackedVector2Array([
		Vector2(cx + 2, cy - h*0.20 + 2), Vector2(cx - w*0.28 + 2, cy + h*0.08 + 2), Vector2(cx + w*0.28 + 2, cy + h*0.08 + 2),
	]), PackedColorArray([shd, shd, shd]))
	draw_polygon(PackedVector2Array([
		Vector2(cx, cy - h*0.20), Vector2(cx - w*0.28, cy + h*0.08), Vector2(cx + w*0.28, cy + h*0.08),
	]), PackedColorArray([fg, fg, fg]))
