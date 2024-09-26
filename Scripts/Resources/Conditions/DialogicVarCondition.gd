class_name DialogicVarCondition
extends TriggerCondition

@export var variable_name: String = ""
@export var check_type: Enums.CheckOp = Enums.CheckOp.EQ
@export var check_value: String = ""


func evaluate(_actor_id: String) -> bool:
	var has_var := Dialogic.VAR.has(variable_name)
	if check_type == Enums.CheckOp.EXISTS:
		return has_var

	var var_value: Variant = Dialogic.VAR.get_variable(variable_name)
	var var_type := typeof(var_value)

	match var_type:
		TYPE_INT:
			return Enums.check_op_eval_int(check_type, var_value, int(check_value))
		TYPE_FLOAT:
			return Enums.check_op_eval_float(check_type, var_value, float(check_value))
		TYPE_BOOL:
			return Enums.check_op_eval_bool(check_type, var_value, _to_bool(check_value))
		TYPE_STRING:
			return Enums.check_op_eval_str(check_type, var_value, check_value)

	printerr("Unknown type for Dialogic Variable %s: %s" % [variable_name, var_type])
	return false


func _to_bool(in_s: String) -> bool:
	in_s = in_s.to_lower()
	if in_s == "1" || in_s == "t" || in_s == "true":
		return true
	if in_s == "" || in_s == "0" || in_s == "t" || in_s == "true":
		return false
	printerr("Fallback to false trying to convert '%s' to bool" % [in_s])
	return false
