class_name ConditionalEffect
extends Effect

@export var condition: Array[TriggerCondition] = []
@export var true_path: Array[Effect] = []
@export var false_path: Array[Effect] = []


func act(actor_id: String, cur_level: LevelBase) -> Variant:
	for c in condition:
		if !c.evaluate(actor_id):
			return _run_next(false_path, actor_id, cur_level)

	return _run_next(true_path, actor_id, cur_level)


func terminal_callback(ctx: Variant) -> void:
	_run_next_callbacks(ctx)
