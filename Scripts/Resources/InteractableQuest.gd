extends InteractableAction
class_name InteractableQuest



@export var questid : int 
@export var update_objective: String
@export var value: int

func act(actor: Character) -> void:
		Signalbus.quest_update.emit(questid,update_objective,value)

