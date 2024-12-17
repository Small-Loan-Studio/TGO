class_name OrCondition
extends TriggerCondition

@export var clauses: Array[TriggerCondition]

func evaluate(actor_id: String) -> bool:
	print("OrCondition.evaluate")
	if len(clauses) == 0:
		print("No clauses to evaluate")
		return true
	
	var i := 0
	for c in clauses:
		if c.evaluate(actor_id):
			print("Clause %d evaluated to true" % [i])
			return true
		i = i + 1

	return false