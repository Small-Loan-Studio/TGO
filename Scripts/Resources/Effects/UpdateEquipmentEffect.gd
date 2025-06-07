@tool
## Change equipment for a character -- if the character does not have the
## item in their inventory this will fail.
class_name UpdateEquipmentEffect
extends Effect

## What slot are we changing; if "any" and:
##   unequiping -> we will unequip all items
##   equiping -> we will equip the item in the first available slot
@export_enum("left", "right", "any") var slot: String = "any"

## When equippeng a new item should we replace an existing item in that
## slot
@export var unequip_previous: bool = true

## What item is being added/removed; if not set only unequip will be attempted
@export var item: Item

@export_enum("equip", "unequip") var action: String = "equip"


func _init() -> void:
	super._init()
	_expose_result_chains = true


func act(actor_id: String, cur_level: LevelBase) -> Variant:
	var maybe_actor := cur_level.get_by_id(actor_id)
	if maybe_actor == null || !(maybe_actor is Character):
		printerr("Failed to find actor with id: %s" % [actor_id])
		return false

	var actor: Character = maybe_actor as Character

	var result: bool = false

	if action == "equip":
		result = equip(actor, item, slot)
	elif action == "unequip":
		result = unequip(actor, item, slot)

	if result:
		return _run_success(actor_id, cur_level)
	return _run_failure(actor_id, cur_level)


func terminal_callback(arg: Variant) -> void:
	_run_next_callbacks(arg)


func equip(actor: Character, tgt: Item, tgt_slot: String) -> bool:
	if tgt == null:
		return false

	var use_slot := Enums.GearSlot.RIGHT
	if tgt_slot == "any":
		for cur_slot: Enums.GearSlot in Enums.GearSlot.values():
			if actor.in_slot(cur_slot) == null:
				use_slot = cur_slot
				break
	else:
		use_slot = Enums.gear_slot_from_str(tgt_slot)

	if actor.in_slot(use_slot) != null:
		actor.unequip(use_slot)
	return actor.equip(use_slot, tgt)


func unequip(actor: Character, tgt: Item, tgt_slot: String) -> bool:
	if tgt_slot == "any":
		for cur_slot: Enums.GearSlot in Enums.GearSlot.values():
			var cur_item := actor.in_slot(cur_slot)
			if cur_item != null && (tgt == null || cur_item.id == tgt.id):
				actor.unequip(cur_slot)
		return true

	actor.unequip(Enums.gear_slot_from_str(tgt_slot))
	return true
