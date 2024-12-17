class_name OrCondition
extends TriggerCondition

@export var clauses: Array[TriggerCondition]


func evaluate(actor_id: String) -> bool:
	if len(clauses) == 0:
		return true

	var i := 0
	for c in clauses:
		if c.evaluate(actor_id):
			return true
		i = i + 1

	return false
