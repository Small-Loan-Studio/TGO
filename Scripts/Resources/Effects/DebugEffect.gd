class_name DebugEffect
extends Effect

@export var message: String = "debug message"


func act(actor_id: String, cur_level: LevelBase) -> Variant:
	print("[DebugEffect] actor: %s, %s" % [actor_id, cur_level.get_by_id(actor_id)])
	print("[DebugEffect] %s" % [message])
	return null


static func mk_effect(msg: String) -> DebugEffect:
	var de := DebugEffect.new()
	de.message = msg
	return de
