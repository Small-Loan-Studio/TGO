class_name AndCondition
extends TriggerCondition

@export var clauses: Array[TriggerCondition]


func evaluate(actor_id: String) -> bool:
	if len(clauses) == 0:
		return true

	for c in clauses:
		if !c.evaluate(actor_id):
			return false

	return true
