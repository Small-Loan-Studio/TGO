class_name ScratchScenes
extends Node

const SCENES = {
	"TestMovement": "res://Scratch/Movement/TestMovement.tscn",
}

static func get_scenes() -> Dictionary:
	return SCENES