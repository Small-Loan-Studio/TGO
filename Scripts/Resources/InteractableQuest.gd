extends InteractableAction
class_name InteractableQuest



@export var questid : int 
@export var objective_id : int
@export var value: int

func act(actor: Character) -> void:
		Signalbus.quest_update.emit(questid,objective_id,value)
