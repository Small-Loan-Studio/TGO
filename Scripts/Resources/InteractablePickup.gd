class_name InteractablePickup
extends InteractableAction

## The destination path to the node that represents an item
@export var dest_path: NodePath

## The item that will be added if picked up
@export var item: Item

func act(_actor: Character) -> void:
	print("Actor InteractablePickup")
	var dest_node := parent.get_node(dest_path) as Node2D
	## NOTE: Unsure of how we are going to setup inventory to work, assuming a node at Base Devin for now
	var inventory: Inventory = _actor.get_node("Inventory")
	inventory.insert(item)
	dest_node.queue_free()


