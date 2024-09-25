class_name DebugEffect
extends Effect

func act(actor_id: String, cur_level: LevelBase) -> void:
  print("DebugEffect: ", cur_level.get_by_id(actor_id))