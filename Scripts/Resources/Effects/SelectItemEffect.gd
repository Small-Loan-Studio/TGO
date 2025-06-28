@tool
class_name SelectItemEffect
extends Effect

const SELECT_DTL = preload("res://Dialogue/Other/select_item.dtl") as DialogicTimeline
const ITEM_VAR = "Util.selected_item_id"

@export var with_item: Array[Effect]

func act(actor_id: String, cur_level: LevelBase) -> Variant:
	Dialogic.VAR.set_variable(ITEM_VAR, "")
	Dialogic.start(SELECT_DTL)
	await Dialogic.timeline_ended
	var item_id: String = SelectItemEffect.get_selected_id()
	if item_id != "":
		return _run_next(with_item, actor_id, cur_level)
	return null


static func mk_effect(next: Array[Effect]) -> SelectItemEffect:
	var sie := SelectItemEffect.new()
	if next != null:
		sie.with_item = next
	return sie


static func get_selected_id() -> String:
	return Dialogic.VAR.get_variable(ITEM_VAR)