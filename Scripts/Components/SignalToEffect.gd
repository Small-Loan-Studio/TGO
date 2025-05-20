class_name SignalToEffect
extends Node

@export var use_id: String = ""

@export var effects: Array[Effect] = []

func trigger() -> void:
	for effect: Effect in effects:
		if effect != null:
			effect.act(use_id, Driver.instance().get_current_level())
