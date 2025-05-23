class_name SignalToEffect
extends Node

## If this is set the effect chain will be triggered with this ID. If not an
## empty string will be used. Note that running with no ID will dramatically
## impact the behavior of effects that are executed.
@export var use_id: String = ""

@export var effects: Array[Effect] = []

func trigger() -> void:
	for effect: Effect in effects:
		if effect != null:
			effect.parent = get_parent()
			effect.act(use_id, Driver.instance().get_current_level())
