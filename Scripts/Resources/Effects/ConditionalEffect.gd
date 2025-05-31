class_name ConditionalEffect
extends Effect

@export var condition: Array[TriggerCondition] = []


func _init() -> void:
	super._init()
	_expose_result_chains = true


func act(actor_id: String, cur_level: LevelBase) -> Variant:
	for c in condition:
		if !c.evaluate(actor_id):
			return _run_next(failure_chain, actor_id, cur_level)

	return _run_next(success_chain, actor_id, cur_level)


func terminal_callback(ctx: Variant) -> void:
	_run_next_callbacks(ctx)
