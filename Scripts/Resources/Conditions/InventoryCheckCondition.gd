class_name InventoryCheckCondition
extends TriggerCondition

## Which inventory should be checked, if unset uses the actor prompting the
## evaluation
@export var inventory_id: String = ""

## What item are we checking for
@export var target_item: Item

## What kind of check to do
@export var check_type: Enums.CheckOp = Enums.CheckOp.EXISTS

@export var check_value: int

func evaluate(actor_id: String) -> bool:
  var check_id := inventory_id
  if check_id == "":
    check_id = actor_id

  var inv := Driver.instance().inventory_mgr.get_inventory(check_id)

  if check_type == Enums.CheckOp.EXISTS:
    return inv.has_item(target_item)

  return Enums.check_op_eval_int(check_type, inv.count_item(target_item), check_value)