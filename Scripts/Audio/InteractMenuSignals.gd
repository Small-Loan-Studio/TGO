@tool

class_name InteractMenuSignals
extends Node

signal subpanel_open()
signal subpanel_close()
signal subpanel_up()
signal subpanel_down()
signal trigger(action: Enums.ActionVerb)

@export var action_map := {}

@export var action_signal_map := {}


func _get_property_list() -> Array[Dictionary]:
	var props: Array[Dictionary] = []

	return props