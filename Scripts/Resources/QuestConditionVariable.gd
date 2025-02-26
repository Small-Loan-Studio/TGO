@tool
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


func lint() -> Array[String]:
	var errs: Array[String] = []
	if target_value.strip_edges() == "":
		errs.append("E: target value is empty")
	if variable.strip_edges() == "":
		errs.append("E: variable is empty")

	var var_info: Variant = Utils.ersatz_dialogic_get_var(variable)
	if var_info.size() == 0:
		errs.append("E: invalid variable specified (%s)" % [variable])
	else:
		var var_type: Variant.Type = var_info[1]
		match var_type:
			TYPE_INT:
				if int(target_value) == null:
					errs.append("E: target value must be of type INT: %s" % [target_value])
			TYPE_FLOAT:
				if float(target_value) == null:
					errs.append("E: target value must be of type FLOAT: %s" % [target_value])
			TYPE_BOOL:
				if Utils.str_to_bool(target_value) == null:
					errs.append("E: target value must be of type BOOL: %s" % [target_value])
			TYPE_STRING:
				pass
			_:
				errs.append("E: unsupported variable type %s: %s" % [var_info[0], var_type])

	return errs
