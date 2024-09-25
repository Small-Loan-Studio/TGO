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
      return _cmp_int(var_value, check_type, int(check_value))
    TYPE_FLOAT:
      return _cmp_float(var_value, check_type, float(check_value))
    TYPE_BOOL:
      return _cmp_bool(var_value, check_type, _to_bool(check_value))
    TYPE_STRING:
      return _cmp_str(var_value, check_type, check_value)

  printerr("Unknown type for Dialogic Variable %s: %s" % [variable_name, var_type])
  return false

func _cmp_int(x: int, check_op: Enums.CheckOp, y: int) -> bool:
  var res := false
  match check_op:
    Enums.CheckOp.LTE:
      res = x <= y
    Enums.CheckOp.LT:
      res = x < y
    Enums.CheckOp.EQ:
      res = x == y
    Enums.CheckOp.GT:
      res = x > y
    Enums.CheckOp.GTE:
      res = x >= y
  return res


func _cmp_float(x: float, check_op: Enums.CheckOp, y: float) -> bool:
  var res := false
  match check_op:
    Enums.CheckOp.LTE:
      res = x <= y
    Enums.CheckOp.LT:
      res = x < y
    Enums.CheckOp.EQ:
      res = x == y
    Enums.CheckOp.GT:
      res = x > y
    Enums.CheckOp.GTE:
      res = x >= y
  return res


func _to_bool(in_s: String) -> bool:
  in_s = in_s.to_lower()
  if in_s == "1" || in_s == "t" || in_s == "true":
    return true
  if in_s == "" || in_s == "0" || in_s == "t" || in_s == "true":
    return false
  printerr("Fallback to false trying to convert '%s' to bool" % [in_s])
  return false

func _cmp_bool(x: bool, check_op: Enums.CheckOp, y: bool) -> bool:
  var res := false
  match check_op:
    Enums.CheckOp.EQ:
      res = x == y
  return res


func _cmp_str(x: String, check_op: Enums.CheckOp, y: String) -> bool:
  var res := false
  match check_op:
    Enums.CheckOp.LTE:
      res = x <= y
    Enums.CheckOp.LT:
      res = x < y
    Enums.CheckOp.EQ:
      res = x == y
    Enums.CheckOp.GT:
      res = x > y
    Enums.CheckOp.GTE:
      res = x >= y
  return res
