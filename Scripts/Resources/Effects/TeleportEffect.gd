class_name TeleportEffect
extends Effect

## A Node2D that is the desired destination
@export var dest_path: NodePath


func act(actor_id: String, cur_level: LevelBase) -> void:
	var dest_node := parent.get_node(dest_path) as Node2D
	var actor := cur_level.get_by_id(actor_id)
	if actor != null:
		actor.global_position = dest_node.global_position
