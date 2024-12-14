class_name QuestStateCondition
extends TriggerCondition

@export var quest_id: String = ""
@export var check_type: Enums.CheckOp = Enums.CheckOp.EQ
@export var check_value: Enums.QuestState = Enums.QuestState.DORMANT


func evaluate(_actor_id: String) -> bool:
	var quest := Driver.instance().quest_mgr.quest_by_id(quest_id)

  # We consider a quest to "exist" if it's not dormant
	if check_type == Enums.CheckOp.EXISTS:
		return quest.state != Enums.QuestState.DORMANT

	if check_type == Enums.CheckOp.EQ:
		return quest.state == check_value

	printerr("Invalid check type for quest state: %d" % [check_type])
	return false