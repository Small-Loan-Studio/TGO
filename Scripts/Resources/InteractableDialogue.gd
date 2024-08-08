class_name InteractableDialogue
extends InteractableAction

@export var timeline: DialogicTimeline


func act(_actor: Character, _cur_level: LevelBase) -> void:
	Dialogic.start(timeline)
