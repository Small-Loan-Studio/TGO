class_name QuestCondition
extends Resource

var type: Enums.QuestConditionType


## evaluates whether this condition has been met; will throw an error if not
## overridden by a subclass
func eval() -> bool:
	assert(false, "A base QuestCondition has no way to evaluate to true")
	return false


## checks validity of this quest condition, should probably only be run in
## tool mode. Used in Quest.lint()
func lint() -> Array[String]:
	return []
