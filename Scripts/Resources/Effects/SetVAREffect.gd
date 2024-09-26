## An effect that modifies a state variable tracked by Dialogic's variable
## subsystem. When making changes to a variable the variable must exist,
## i.e., if you pass a variable that hasn't been defined it will print
## an error and no changes will be made.
##
## Updates have two modes:
##   1. overwrite which will completely replace the previosu value
##   2. Update which applies a modification to the previous value.
##      An update change may only be done on a number.
class_name SetVAREffect
extends Effect

## The variable name to be set or updated.
@export var variable_name: String

## Is this change an totally new value or updating an existing value?
@export_enum("overwrite", "update") var set_type: String = "overwrite"

## What new value or change should be made.
@export var new_value: String

func act(_actor_id: String, _cur_level: LevelBase) -> void:
  var coerced_value: Variant = _get_valid_value(variable_name, new_value)
  if coerced_value == null:
    printerr("SetVAREffect: Unable to coerce %s into the expected type for %s" % [new_value, variable_name])
    return
  match set_type:
    "overwrite":
      Dialogic.VAR.set_variable(variable_name, coerced_value)
    "update":
      var cur_value: Variant = Dialogic.VAR.get_variable(variable_name)
      print("cur_value: ", cur_value)
      print("coerced_value: ", coerced_value)
      match typeof(cur_value):
        TYPE_INT:
          Dialogic.VAR.set_variable(variable_name, cur_value + coerced_value)
        TYPE_FLOAT:
          Dialogic.VAR.set_variable(variable_name, cur_value + coerced_value)
        _:
          printerr("SetVAREffect: Unable to make update to non-numeric variable ", variable_name)

func _get_valid_value(variable_name: String, new_value: String) -> Variant:
  if !Dialogic.VAR.has(variable_name):
    printerr("SetVAREffect: Invalid variable", variable_name)
    return null

  match typeof(Dialogic.VAR.get_variable(variable_name)):
    TYPE_INT:
      return int(new_value)
    TYPE_FLOAT:
      return float(new_value)
    TYPE_STRING:
      return new_value
    TYPE_BOOL:
      return Utils.str_to_bool(new_value)

  return null