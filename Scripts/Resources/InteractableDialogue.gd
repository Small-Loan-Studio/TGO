extends InteractableAction
class_name InteractableDialogue

@export var timeline : DialogicTimeline


func act(actor: Character,_level: LevelBase) -> void:
	if timeline != null:
		Dialogic.start(timeline)
