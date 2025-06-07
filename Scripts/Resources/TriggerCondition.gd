class_name TriggerCondition
extends Resource
# TODO: I'm making a bunch of things resources that may not need to be one
# because I want to utilize the in-editor editing... unclear if there is a
# better way or how inefficient that is.


func evaluate(_actor_id: String) -> bool:
	return false


static func evaluate_all(conditions: Array[TriggerCondition], _actor_id: String) -> bool:
	for condition: TriggerCondition in conditions:
		if !condition.evaluate(_actor_id):
			return false
	return true
