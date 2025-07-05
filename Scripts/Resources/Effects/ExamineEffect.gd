class_name ExamineEffect
extends Effect

const EXAMINE_DTL = preload("res://Dialogue/Other/examine.dtl") as DialogicTimeline
const EXAMINE_VAR = "Util.examine_text"

@export var examine_text: String


func act(_actor_id: String, _cur_level: LevelBase) -> Variant:
	Dialogic.VAR.set_variable(EXAMINE_VAR, examine_text)
	Dialogic.start(EXAMINE_DTL)
	await Dialogic.timeline_ended
	return null


static func mk_effect(txt: String) -> ExamineEffect:
	var ee := ExamineEffect.new()
	ee.examine_text = txt
	return ee


static func new_multipanel(txt: Array[String]) -> Array[Effect]:
	var arr: Array[Effect] = []
	for t in txt:
		arr.append(ExamineEffect.mk_effect(t))
	return arr
