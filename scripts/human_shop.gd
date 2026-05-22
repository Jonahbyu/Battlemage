class_name HumanShop
extends Control

signal weapon_bought(wtype: int)
signal weapon_upgraded()
signal weapon_sold()
signal weapon_swapped()
signal closed()

var weapon_templates: Dictionary = {}
var weapon_discount_mult: float = 1.0
var pending_weapon_discount: int = 0

var _cards: Array = []
var _target_card: UnitCard = null
var _gold: int = 0
var _gold_label: Label = null
var _unit_list_vbox: VBoxContainer = null
var _details_vbox: VBoxContainer = null


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	z_index = 80
	visible = false
	_build_ui()


func open(cards: Array, initial_card: UnitCard, gold: int) -> void:
	_cards = cards
	_target_card = initial_card
	_gold = gold
	_refresh()
	visible = true


func refresh(gold: int) -> void:
	if visible:
		_gold = gold
		_refresh()


func get_target_card() -> UnitCard:
	return _target_card


func close() -> void:
	visible = false
	closed.emit()


# ── UI construction ───────────────────────────────────────────────────────────

func _build_ui() -> void:
	var dim := ColorRect.new()
	dim.color = Color(0, 0, 0, 0.65)
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	dim.mouse_filter = Control.MOUSE_FILTER_PASS
	add_child(dim)

	var panel := Panel.new()
	var ps := StyleBoxFlat.new()
	ps.bg_color = Color(0.12, 0.10, 0.08, 0.98)
	ps.set_corner_radius_all(10)
	ps.set_border_width_all(2)
	ps.border_color = Color(0.65, 0.50, 0.25, 1.0)
	panel.add_theme_stylebox_override("panel", ps)
	panel.set_anchors_preset(Control.PRESET_FULL_RECT)
	panel.offset_left = 40
	panel.offset_top = 30
	panel.offset_right = -40
	panel.offset_bottom = -30
	add_child(panel)

	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	for side in ["margin_left", "margin_right", "margin_top", "margin_bottom"]:
		margin.add_theme_constant_override(side, 20)
	panel.add_child(margin)

	var outer := VBoxContainer.new()
	outer.add_theme_constant_override("separation", 14)
	margin.add_child(outer)

	# Header
	var header := HBoxContainer.new()
	header.add_theme_constant_override("separation", 12)
	outer.add_child(header)

	var title := Label.new()
	title.text = "Armory"
	title.add_theme_font_size_override("font_size", 22)
	title.add_theme_color_override("font_color", Color(1.0, 0.85, 0.50))
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(title)

	_gold_label = Label.new()
	_gold_label.add_theme_font_size_override("font_size", 15)
	_gold_label.add_theme_color_override("font_color", Color(1.0, 0.85, 0.20))
	header.add_child(_gold_label)

	var close_btn := Button.new()
	close_btn.text = "Close"
	close_btn.custom_minimum_size = Vector2(70, 30)
	close_btn.pressed.connect(close)
	header.add_child(close_btn)

	outer.add_child(HSeparator.new())

	# Two-column body
	var body := HBoxContainer.new()
	body.add_theme_constant_override("separation", 20)
	body.size_flags_vertical = Control.SIZE_EXPAND_FILL
	outer.add_child(body)

	# Left: unit list
	var left := _make_inner_panel()
	left.custom_minimum_size = Vector2(240, 0)
	left.size_flags_vertical = Control.SIZE_EXPAND_FILL
	body.add_child(left)

	var lm := MarginContainer.new()
	lm.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	for side in ["margin_left", "margin_right", "margin_top", "margin_bottom"]:
		lm.add_theme_constant_override(side, 14)
	left.add_child(lm)

	var scroll_left := ScrollContainer.new()
	scroll_left.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll_left.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	lm.add_child(scroll_left)

	_unit_list_vbox = VBoxContainer.new()
	_unit_list_vbox.add_theme_constant_override("separation", 6)
	_unit_list_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll_left.add_child(_unit_list_vbox)

	# Right: weapon details
	var right := _make_inner_panel()
	right.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	right.size_flags_vertical = Control.SIZE_EXPAND_FILL
	body.add_child(right)

	var rm := MarginContainer.new()
	rm.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	for side in ["margin_left", "margin_right", "margin_top", "margin_bottom"]:
		rm.add_theme_constant_override(side, 14)
	right.add_child(rm)

	var scroll_right := ScrollContainer.new()
	scroll_right.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll_right.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	rm.add_child(scroll_right)

	_details_vbox = VBoxContainer.new()
	_details_vbox.add_theme_constant_override("separation", 8)
	_details_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll_right.add_child(_details_vbox)


func _make_inner_panel() -> Panel:
	var p := Panel.new()
	var s := StyleBoxFlat.new()
	s.bg_color = Color(0.09, 0.08, 0.06, 1.0)
	s.set_corner_radius_all(6)
	s.set_border_width_all(1)
	s.border_color = Color(0.50, 0.40, 0.20, 0.7)
	p.add_theme_stylebox_override("panel", s)
	return p


# ── Refresh ───────────────────────────────────────────────────────────────────

func _refresh() -> void:
	if _gold_label != null:
		_gold_label.text = "Gold: %d" % _gold
	_refresh_unit_list()
	_refresh_details()


func _refresh_unit_list() -> void:
	for c in _unit_list_vbox.get_children():
		c.queue_free()

	var section_lbl := Label.new()
	section_lbl.text = "Humans"
	section_lbl.add_theme_font_size_override("font_size", 15)
	section_lbl.add_theme_color_override("font_color", Color(1.0, 0.85, 0.50))
	_unit_list_vbox.add_child(section_lbl)
	_unit_list_vbox.add_child(HSeparator.new())

	if _cards.is_empty():
		var empty_lbl := Label.new()
		empty_lbl.text = "No humans on board"
		empty_lbl.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5))
		_unit_list_vbox.add_child(empty_lbl)
		return

	for card: UnitCard in _cards:
		if not is_instance_valid(card):
			continue
		var btn := Button.new()
		btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		btn.alignment = HORIZONTAL_ALIGNMENT_LEFT

		var w := card.equipped_weapon
		var weapon_name := "%s Lv.%d" % [w.display_name, w.level] if w != null else "No weapon"
		btn.text = "%s\n%s" % [card.data.display_name, weapon_name]

		if card == _target_card:
			var sel := StyleBoxFlat.new()
			sel.bg_color = Color(0.25, 0.20, 0.10, 1.0)
			sel.set_corner_radius_all(4)
			btn.add_theme_stylebox_override("normal", sel)

		var target := card
		btn.pressed.connect(func():
			_target_card = target
			_refresh())
		_unit_list_vbox.add_child(btn)


func _refresh_details() -> void:
	for c in _details_vbox.get_children():
		c.queue_free()

	if _target_card == null or not is_instance_valid(_target_card):
		return

	var card := _target_card
	var w := card.equipped_weapon

	var unit_lbl := Label.new()
	unit_lbl.text = card.data.display_name
	unit_lbl.add_theme_font_size_override("font_size", 15)
	unit_lbl.add_theme_color_override("font_color", Color(1.0, 0.85, 0.50))
	_details_vbox.add_child(unit_lbl)
	_details_vbox.add_child(HSeparator.new())

	# ── Equipped weapon ──────────────────────────────────────────────────────
	var equip_hdr := Label.new()
	equip_hdr.text = "Equipped Weapon"
	equip_hdr.add_theme_font_size_override("font_size", 14)
	equip_hdr.add_theme_color_override("font_color", Color(1.0, 0.85, 0.50))
	_details_vbox.add_child(equip_hdr)
	_details_vbox.add_child(HSeparator.new())

	if w == null:
		var no_w := Label.new()
		no_w.text = "No weapon equipped"
		no_w.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5))
		_details_vbox.add_child(no_w)
		_details_vbox.add_child(HSeparator.new())
	else:
		# Upgrade row
		var upg_row := HBoxContainer.new()
		upg_row.add_theme_constant_override("separation", 12)
		_details_vbox.add_child(upg_row)

		var upg_info := VBoxContainer.new()
		upg_info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		upg_row.add_child(upg_info)

		var w_name := Label.new()
		w_name.text = "%s  Lv.%d" % [w.display_name, w.level]
		w_name.add_theme_font_size_override("font_size", 14)
		upg_info.add_child(w_name)

		var w_stat := Label.new()
		match w.weapon_type:
			WeaponData.WeaponType.MACHINE_GUN:
				w_stat.text = "%d shots × %d dmg = %d total" % [
					w.get_total_shots(), w.get_total_damage(),
					w.get_total_shots() * w.get_total_damage()]
			WeaponData.WeaponType.SHOTGUN:
				w_stat.text = "%d primary  +  %d splash" % [w.get_total_damage(), w.get_splash_damage()]
			_:
				w_stat.text = "%d damage" % w.get_total_damage()
		w_stat.add_theme_font_size_override("font_size", 11)
		w_stat.add_theme_color_override("font_color", Color(0.70, 0.65, 0.50))
		upg_info.add_child(w_stat)

		var upgrade_cost := _calc_upgrade_cost(w)
		var upg_desc := Label.new()
		upg_desc.text = "Upgrade to Lv.%d" % (w.level + 1)
		upg_desc.add_theme_font_size_override("font_size", 11)
		upg_desc.add_theme_color_override("font_color", Color(0.65, 0.60, 0.45))
		upg_info.add_child(upg_desc)

		var upg_btn := Button.new()
		upg_btn.text = "Buy\n%dg" % upgrade_cost
		upg_btn.custom_minimum_size = Vector2(72, 52)
		upg_btn.disabled = _gold < upgrade_cost
		upg_btn.pressed.connect(func(): weapon_upgraded.emit())
		upg_row.add_child(upg_btn)

		_details_vbox.add_child(HSeparator.new())

		# Sell row
		var sell_row := HBoxContainer.new()
		sell_row.add_theme_constant_override("separation", 12)
		_details_vbox.add_child(sell_row)

		var sell_info := VBoxContainer.new()
		sell_info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		sell_row.add_child(sell_info)

		var sell_lbl := Label.new()
		sell_lbl.text = "Sell Equipped"
		sell_lbl.add_theme_font_size_override("font_size", 14)
		sell_info.add_child(sell_lbl)

		var sell_desc := Label.new()
		sell_desc.text = "Returns %dg" % w.get_sell_value()
		sell_desc.add_theme_font_size_override("font_size", 11)
		sell_desc.add_theme_color_override("font_color", Color(0.65, 0.60, 0.45))
		sell_info.add_child(sell_desc)

		var sell_btn := Button.new()
		sell_btn.text = "Sell\n%dg" % w.get_sell_value()
		sell_btn.custom_minimum_size = Vector2(72, 52)
		sell_btn.pressed.connect(func(): weapon_sold.emit())
		sell_row.add_child(sell_btn)

		_details_vbox.add_child(HSeparator.new())

		# Backpack row
		if card.backpack_weapon != null:
			var bw := card.backpack_weapon
			var bp_row := HBoxContainer.new()
			bp_row.add_theme_constant_override("separation", 12)
			_details_vbox.add_child(bp_row)

			var bp_info := VBoxContainer.new()
			bp_info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			bp_row.add_child(bp_info)

			var bp_name := Label.new()
			bp_name.text = "Backpack: %s Lv.%d" % [bw.display_name, bw.level]
			bp_name.add_theme_font_size_override("font_size", 14)
			bp_info.add_child(bp_name)

			var bp_desc := Label.new()
			bp_desc.text = "Sell value: %dg" % bw.get_sell_value()
			bp_desc.add_theme_font_size_override("font_size", 11)
			bp_desc.add_theme_color_override("font_color", Color(0.65, 0.60, 0.45))
			bp_info.add_child(bp_desc)

			var swap_btn := Button.new()
			swap_btn.text = "Swap\nPrimary"
			swap_btn.custom_minimum_size = Vector2(72, 52)
			swap_btn.pressed.connect(func(): weapon_swapped.emit())
			bp_row.add_child(swap_btn)

			_details_vbox.add_child(HSeparator.new())
		else:
			var bp_lbl := Label.new()
			bp_lbl.text = "Backpack: empty"
			bp_lbl.add_theme_font_size_override("font_size", 12)
			bp_lbl.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5))
			_details_vbox.add_child(bp_lbl)
			_details_vbox.add_child(HSeparator.new())

	# ── Buy new weapon ───────────────────────────────────────────────────────
	var buy_hdr := Label.new()
	buy_hdr.text = "Buy Weapon"
	buy_hdr.add_theme_font_size_override("font_size", 14)
	buy_hdr.add_theme_color_override("font_color", Color(1.0, 0.85, 0.50))
	_details_vbox.add_child(buy_hdr)
	_details_vbox.add_child(HSeparator.new())

	var slots_full := card.equipped_weapon != null and card.backpack_weapon != null

	for wtype in [WeaponData.WeaponType.PISTOL, WeaponData.WeaponType.SHOTGUN,
			WeaponData.WeaponType.SNIPER, WeaponData.WeaponType.MACHINE_GUN]:
		var template: WeaponData = weapon_templates.get(wtype, null)
		if template == null:
			continue
		var buy_price := _calc_buy_price(template)

		var buy_row := HBoxContainer.new()
		buy_row.add_theme_constant_override("separation", 12)
		_details_vbox.add_child(buy_row)

		var buy_info := VBoxContainer.new()
		buy_info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		buy_row.add_child(buy_info)

		var buy_name := Label.new()
		buy_name.text = template.display_name
		buy_name.add_theme_font_size_override("font_size", 14)
		buy_info.add_child(buy_name)

		var buy_desc := Label.new()
		buy_desc.text = "Now: %dg" % template.buy_price
		buy_desc.add_theme_font_size_override("font_size", 11)
		buy_desc.add_theme_color_override("font_color", Color(0.65, 0.60, 0.45))
		buy_info.add_child(buy_desc)

		var buy_btn := Button.new()
		buy_btn.text = "Buy\n%dg" % buy_price
		buy_btn.custom_minimum_size = Vector2(72, 52)
		buy_btn.disabled = slots_full or _gold < buy_price
		var captured: int = wtype
		buy_btn.pressed.connect(func(): weapon_bought.emit(captured))
		buy_row.add_child(buy_btn)

		_details_vbox.add_child(HSeparator.new())


# ── Cost helpers ──────────────────────────────────────────────────────────────

func _calc_upgrade_cost(w: WeaponData) -> int:
	return max(1, ceili(w.get_upgrade_cost() * weapon_discount_mult) - pending_weapon_discount)


func _calc_buy_price(template: WeaponData) -> int:
	return max(0, ceili(template.buy_price * weapon_discount_mult) - pending_weapon_discount)
