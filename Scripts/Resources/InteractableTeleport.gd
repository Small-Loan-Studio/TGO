class_name InteractableTeleport
extends InteractableAction

## A Node2D that is the desired destination
@export var dest_path: NodePath


func act(actor: Character) -> void:
	var dest_node := parent.get_node(dest_path) as Node2D
	actor.global_position = dest_node.global_position
