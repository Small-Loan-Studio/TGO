class_name DebugEffect
extends Effect

func act(_actor: Character, _cur_level: LevelBase) -> void:
  print("1. DebugEffect: ", _cur_level.get_by_id("devin"))