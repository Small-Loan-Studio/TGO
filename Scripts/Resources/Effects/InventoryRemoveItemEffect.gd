@tool
class_name InventoryRemoveItemEffect
extends Effect

## What item should be removed
@export var item: Item

## How many of the item should be removed
@export var remove_quantity: int = 1

## If specified, this will override the actor's id as the inventory to remove
## the item from
@export var inventory_override: String


func _init() -> void:
	super._init()
	_expose_result_chains = true


func act(actor_id: String, cur_level: LevelBase) -> Variant:
	var inv_id := actor_id
	if inventory_override != "":
		inv_id = inventory_override

	var inv := Driver.instance().inventory_mgr.get_inventory(inv_id)
	if inv.has_item(item, remove_quantity):
		if inv.remove(item, remove_quantity):
			return await _run_success(actor_id, cur_level)

	return await _run_failure(actor_id, cur_level)


func terminal_callback(ctx: Variant) -> void:
	_run_next_callbacks(ctx)
