class_name ToggleDoorEffect
extends Effect

@export var door_id: String
@export_enum("open", "close", "toggle") var door_action: String = "toggle"

func act(actor_id: String, cur_level: LevelBase) -> Variant:
	var door: DoorRegion = null
	for door_options: Node2D in cur_level.get_tree().get_nodes_in_group(Utils.GroupNames.Doors):
		if door_options.region_id == door_id:
			door = door_options as DoorRegion
			break

	if door == null:
		printerr("Attempting to toggle door state for unloaded door: %s" % [door_id])
		return null

	door = door as DoorRegion
	if TriggerCondition.evaluate_all(door.unlocked, actor_id):
		match door_action:
			"open":
				door.open()
			"close":
				door.close()
			"toggle":
				door.toggle()
	return null
