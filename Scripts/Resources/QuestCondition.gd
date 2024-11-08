class_name QuestCondition
extends Resource

var type: Enums.QuestConditionType


## evaluates whether this condition has been met; will throw an error if not
## overridden by a subclass
func eval() -> bool:
	assert(false, "A base QuestCondition has no way to evaluate to true")
	return false
