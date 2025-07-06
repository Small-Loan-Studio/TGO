class_name ForceEffectId
extends Effect

@export var override_id: String

@export var wrapped_effects: Array[Effect] = []


func act(_actor_id: String, cur_level: LevelBase) -> Variant:
	return await _run_next(wrapped_effects, override_id, cur_level)


func terminal_callback(ctx: Variant) -> void:
	_run_next_callbacks(ctx)
