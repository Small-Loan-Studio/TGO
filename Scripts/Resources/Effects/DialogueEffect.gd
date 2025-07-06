class_name DialogueEffect
extends Effect

@export var timeline: DialogicTimeline


func act(_actor_id: String, _cur_level: LevelBase) -> Variant:
	if timeline == null:
		printerr(
			(
				"Attempting to speak with a character (%s) that doesn't have an assigned timeline"
				% [parent.get_parent().name]
			)
		)
		return null

	Dialogic.start(timeline)
	await Dialogic.timeline_ended
	return null


static func mk_effect(res: DialogicTimeline) -> DialogueEffect:
	var de := DialogueEffect.new()
	de.timeline = res
	return de
