@tool
class_name InventoryAddItemEffect
extends Effect

## What should be added
@export var item: Item

## How many should be added
@export var add_quantity: int = 1

## If specified, this will override the actor's id as the inventory to add
## the item to
@export var inventory_override: String


func _init() -> void:
	super._init()
	_expose_result_chains = true


# ## Effect execution continues down this path if item addition was successful
# @export var success_chain: Array[Effect]

# ## Effect execution continues down this path if item addition was not successful
# @export var failure_chain: Array[Effect]

func act(actor_id: String, cur_level: LevelBase) -> Variant:
	var inv_id := actor_id
	if inventory_override != "":
		inv_id = inventory_override

	var inv := Driver.instance().inventory_mgr.get_inventory(inv_id)
	if !inv.has_room_by_item(item, add_quantity):
		inv.insert_item(item, add_quantity)
		return _run_next(success_chain, actor_id, cur_level)

	return _run_next(failure_chain, actor_id, cur_level)


func terminal_callback(ctx: Variant) -> void:
	_run_next_callbacks(ctx)
