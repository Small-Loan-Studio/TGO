class_name EquipmentCondition
extends TriggerCondition

@export var check_item: Item
@export_enum("equipped", "unequipped") var check_type: String = "equipped"
@export_enum("left", "right", "any") var slot_requirement: String = "any"


func evaluate(actor_id: String) -> bool:
	var maybe_actor := Driver.instance().get_current_level().get_by_id(actor_id)
	if maybe_actor == null || !(maybe_actor is Character):
		printerr("Failed to find actor with id: %s" % [actor_id])
		return false

	var actor := maybe_actor as Character

	match check_type:
		"equipped":
			return _equipped(actor)
		"unequiped":
			return _unequipped(actor)

	return false


func _equipped(actor: Character) -> bool:
	var item: Item = null
	match slot_requirement:
		"left":
			item = actor.in_slot(Enums.GearSlot.LEFT)
		"right":
			item = actor.in_slot(Enums.GearSlot.RIGHT)
		"any":
			return actor.is_equipped(check_item)

	return item != null && item.id == check_item.id


func _unequipped(actor: Character) -> bool:
	var item: Item = null
	match slot_requirement:
		"left":
			item = actor.in_slot(Enums.GearSlot.LEFT)
		"right":
			item = actor.in_slot(Enums.GearSlot.RIGHT)
		"any":
			return !actor.is_equipped(check_item)

	return item == null || item.id != check_item.id
