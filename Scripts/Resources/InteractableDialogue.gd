class_name InteractableDialogue
extends InteractableAction

@export var timeline: DialogicTimeline

func act(actor: Character) -> void:
  Dialogic.start(timeline)