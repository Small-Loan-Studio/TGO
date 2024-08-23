class_name InteractablePickup
extends InteractableAction

## The destination path to the node that represents an item
@export var dest_path: NodePath

## The item that will be added if picked up
@export var item: ItemStack

func act(_actor: Character, level: LevelBase) -> void:
	print("Actor InteractablePickup")
	# No idea how we are going to wire this up, but I will use this hack for now
	var inv_manager: InventoryManager = parent.get_node("/root/Driver/InventoryManager")
	var item_node := parent.get_node(dest_path) as Node2D

	var inventory: Inventory = inv_manager.get_inventory("Devin")
	if inventory.insert(item):
		item_node.queue_free()
		print(inventory.items)



