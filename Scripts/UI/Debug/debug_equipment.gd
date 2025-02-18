class_name DebugEquipment
extends Control


@onready var _left_option: OptionButton = $Grid/LeftOption
@onready var _right_option: OptionButton = $Grid/RightOption

func update_available() -> void:
	_populate(_left_option)
	_populate(_right_option)


func _equip_change(_idx: int, slot: String) -> void:
	var btn := _get_button(slot)
	var selected_id := btn.get_item_text(btn.get_selected_id())
	print("selected_id: ", selected_id)
	if selected_id == "<empty>":
		Driver.instance().player.unequip(_get_slot(slot))
		return

	var inv := Driver.instance().inventory_mgr.get_inventory(Utils.PLAYER_ID)
	var inv_stack: Array[ItemStack] = inv.get_items().filter(
		func(i: ItemStack) -> bool: return i.item.id == selected_id)
	print("inv_stack: ", inv_stack)
	if len(inv_stack) < 1:
		return

	print("calling equip")
	Driver.instance().player.equip(_get_slot(slot), inv_stack[0].item)


func _populate(btn: OptionButton) -> void:
	var inv := Driver.instance().inventory_mgr.get_inventory(
		Driver.instance().player.id)
	var items := inv.get_items()
	var gear := items.filter(
		func(i: ItemStack)->bool:
			return i.item.type == Enums.ItemType.EQUIPPABLE
			).map(
				func(i: ItemStack)->String: return i.item.id)

	btn.clear()
	var idx := 0
	btn.add_item("<empty>", idx)

	var idToValue := {}

	for gear_id: String in gear:
		idx += 1
		btn.add_item(gear_id, idx)
		idToValue[gear_id] = idx

	if btn == _left_option:
		var cur: Item = Driver.instance().player._equipment.get(Enums.GearSlot.LEFT)
		if cur != null:
			btn.select(idToValue[cur.id])


func _get_button(slot: String) -> OptionButton:
	slot = slot.to_lower()
	if slot == "left":
		return _left_option
	if slot == "right":
		return _right_option
	printerr("Invalid slot %s" % [slot])
	return null

func _get_slot(slot: String) -> Enums.GearSlot:
	slot = slot.to_lower()
	if slot == "left":
		return Enums.GearSlot.LEFT
	if slot == "right":
		return Enums.GearSlot.RIGHT
	assert("Invalid slot %s" % [slot])
	return Enums.GearSlot.RIGHT