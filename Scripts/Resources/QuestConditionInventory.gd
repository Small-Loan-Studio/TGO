## Allows quests to have completion conditions based on inventory state.
## Inventory ID is the name of the container, e.g. 'Devin' for the PC.
class_name QuestConditionInventory
extends QuestCondition

const HAS_CHECK = "has"
const HAS_NOT_CHECK = "does not have"

## Which container should we check for an item
@export var inventory_id: String

## Are we checking that the container has or is missing an item
@export_enum(HAS_CHECK, HAS_NOT_CHECK) var check: String = HAS_CHECK

## What item are we looking for in the inventory.
@export var target_item: Item


func _ready() -> void:
	type = Enums.QuestConditionType.INVENTORY


func eval() -> bool:
	var inv := Driver.instance().inventory_mgr.get_inventory(inventory_id)
	match check:
		HAS_CHECK:
			return inv.has_item(target_item)
		HAS_NOT_CHECK:
			return !inv.has_item(target_item)

	printerr("Unexpected check type: ", check)
	return false
