extends InteractableAction
class_name InteractableQuest



@export var questid : int 

func act(actor: Character) -> void:
		Signalbus.quest_update.emit(questid)

