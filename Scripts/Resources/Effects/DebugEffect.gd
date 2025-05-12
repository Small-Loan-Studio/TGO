class_name DebugEffect
extends Effect


func act(actor_id: String, cur_level: LevelBase) -> Variant:
	print("DebugEffect: ", cur_level.get_by_id(actor_id))
	return null
