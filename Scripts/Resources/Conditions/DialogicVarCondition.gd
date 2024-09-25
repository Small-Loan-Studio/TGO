class_name DialogicVarCondition
extends TriggerCondition

@export var variable_name: String = ""
@export var check_type: Enums.CheckOp = Enums.CheckOp.EQ
@export var check_value: String

func evaluate() -> bool:
  var has_var := Dialogic.VAR.has(variable_name)
  if check_type == Enums.CheckOp.EXISTS:
    return has_var

  # coerce the dialogic var into a string
  # TODO: This is extremely not the right move but works for now
  var var_value: String = "%s" % [Dialogic.VAR.get_variable(variable_name)]

  var res := false
  match check_type:
    Enums.CheckOp.LTE:
      res = var_value <= check_value
    Enums.CheckOp.LT:
      res = var_value < check_value
    Enums.CheckOp.EQ:
      res = var_value == check_value
    Enums.CheckOp.GT:
      res = var_value > check_value
    Enums.CheckOp.GTE:
      res = var_value >= check_value

  print("%s vs %s: %s" % [var_value, check_value, res])
  return res