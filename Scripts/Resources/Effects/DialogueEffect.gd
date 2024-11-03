class_name DialogueEffect
extends Effect

@export var timeline: DialogicTimeline


func act(_actor_id: String, _cur_level: LevelBase) -> void:
	if timeline == null:
		printerr(
			(
				"Attempting to speak with a character (%s) that doesn't have an assigned timeline"
				% [parent.get_parent().name]
			)
		)
		return

	Dialogic.start(timeline)
