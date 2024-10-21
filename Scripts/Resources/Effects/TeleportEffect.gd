class_name TeleportEffect
extends Effect

## A Node2D that is the desired destination
@export var dest_path: NodePath


func act(actor_id: String, cur_level: LevelBase) -> void:
	var refined_path := str(dest_path)
	var idx := refined_path.find(TGOControlDock.MARKERS_SECTION_NAME + "/")
	if idx == -1:
		printerr("Unable to find markers section in ", dest_path)
		return

	refined_path = refined_path.substr(idx)
	var dest_node := cur_level.get_node(refined_path) as Node2D
	if dest_node == null:
		printerr("Unable to find teleport target ", refined_path)
		return

	var actor := cur_level.get_by_id(actor_id)
	if actor != null:
		actor.global_position = dest_node.global_position
