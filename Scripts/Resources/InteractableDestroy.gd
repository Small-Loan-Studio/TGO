extends InteractableAction
class_name InteractableDestroy
@export var destroy_in_timeline :bool
@export var destroy_attached_object: bool
func act(actor: Character,_level: LevelBase) -> void:
	if destroy_in_timeline:
		var result : String = await Dialogic.signal_event
		print(result)
		if result == "item_taken":
			destroy()
	else:
		destroy()
func destroy()->void:
	if destroy_attached_object:
		parent.get_parent().queue_free()
	else:
		parent.queue_free()
