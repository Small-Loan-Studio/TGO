class_name InvertCondition
extends TriggerCondition

@export var condition: TriggerCondition


func evaluate(actor_id: String) -> bool:
	if condition != null:
		return !condition.evaluate(actor_id)
	printerr("Attempting to invert null condition")
	return false
