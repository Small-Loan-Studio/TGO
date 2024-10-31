## Adds an item from the world into the actor's inventory. The world item
## will be destroyed.
class_name ItemPickupEffect
extends Effect

## The destination path to the node that represents an item
@export var dest_path: NodePath

## The item that will be added if picked up
@export var item: ItemStack


func act(actor_id: String, _level: LevelBase) -> void:
	var inv_manager: InventoryManager = Driver.instance().inventory_mgr
	var item_node := parent.get_node(dest_path) as Node2D

	var inventory: Inventory = inv_manager.get_inventory(actor_id)
	if inventory.insert(item):
		item_node.queue_free()
