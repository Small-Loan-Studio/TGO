class_name ConditionalEffect
extends Effect

@export var condition: Array[TriggerCondition] = []
@export var true_path: Array[Effect] = []
@export var false_path: Array[Effect] = []


func act(actor_id: String, cur_level: LevelBase) -> Variant:
	for c in condition:
		if !c.evaluate(actor_id):
			return _trigger(false_path, actor_id, cur_level)

	return _trigger(true_path, actor_id, cur_level)


func _trigger(effect_chain: Array[Effect], actor_id: String, cur_level: LevelBase) -> Variant:
	var callbacks: Array[Variant] = []

	for e in effect_chain:
		var ctx: Variant = e.act(actor_id, cur_level)
		if ctx != null:
			callbacks.push_back([e, ctx])

	if callbacks.size() == 0:
		return null

	return callbacks


func terminal_callback(ctx: Variant) -> void:
	for elePair: Variant in ctx as Array[Variant]:
		var ele: Effect = elePair[0]
		var arg: Variant = elePair[1]
		ele.terminal_callback(arg)
