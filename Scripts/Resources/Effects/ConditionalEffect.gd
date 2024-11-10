class_name ConditionalEffect
extends Effect

@export var condition: Array[TriggerCondition] = []
@export var true_path: Array[Effect] = []
@export var false_path: Array[Effect] = []


func act(actor_id: String, cur_level: LevelBase) -> void:
	for c in condition:
		if !c.evaluate(actor_id):
			_trigger(false_path, actor_id, cur_level)
			return

	_trigger(true_path, actor_id, cur_level)


func _trigger(effect_chain: Array[Effect], actor_id: String, cur_level: LevelBase) -> void:
	for e in effect_chain:
		e.act(actor_id, cur_level)
