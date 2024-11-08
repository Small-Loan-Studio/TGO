## TODO: should I replace with just active|failed|completed; we won't really
## ever support moving back to dormant state
class_name SetQuestStateEffect
extends Effect

@export var quest_id: String

@export var target_state: Enums.QuestState = Enums.QuestState.ACTIVE


func act(_actor_id: String, _cur_level: LevelBase) -> void:
	var mgr := Driver.instance().quest_mgr
	match target_state:
		Enums.QuestState.ACTIVE:
			mgr.start_quest(quest_id)
		Enums.QuestState.COMPLETED:
			mgr.quest_by_id(quest_id).mark_completed()
		Enums.QuestState.FAILED:
			mgr.quest_by_id(quest_id).mark_failed()
		Enums.QuestState.DORMANT:
			printerr("Does not support setting quest state to dormant")
