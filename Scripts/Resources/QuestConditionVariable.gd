## This functions the same as a DialogicVarCondition in how it lets you build
## checks against the value of a variable held in Dialogic. It adds on an
## inversion for simplicity.
class_name QuestConditionVariable
extends QuestCondition

## What variable are we checking. Should be the fully scoped name including the
## folders if applicable, e.g. Folder1.Folder2.VariableName
@export var variable: String

## What kind of comparison are we making against the variable
@export var check_type: Enums.CheckOp = Enums.CheckOp.EQ

## the value used as part of our check when comparing to the variable
@export var target_value: String

## if set the condition will return true when the variable does *not* meet
## the check / target value
@export var invert_result: bool = false


var _condition: DialogicVarCondition = null


func _ready() -> void:
	type = Enums.QuestConditionType.VARIABLE


func _exit_tree() -> void:
	if _condition != null:
		# TODO: do I need to do this or is it automatic?
		_condition.queue_free()


func _construct_condition() -> DialogicVarCondition:
	if _condition != null:
		return _condition

	var dvc := DialogicVarCondition.new()
	dvc.variable_name = variable
	dvc.check_type = check_type
	dvc.check_value = target_value
	_condition = dvc

	return _condition

func eval() -> bool:
	var dvc := _construct_condition()
	return dvc.evaluate("")