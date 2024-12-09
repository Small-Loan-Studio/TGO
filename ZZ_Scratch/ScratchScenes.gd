class_name ScratchScenes
extends Node

const SCENES = {"Greyboxing": "BadLevelA"}


## Returns a dictionary that is String->String.[br]
## [br]
## The keys are a UI-friendly description of the scene and the values are
## the resource path that should be loaded.[br]
## [br]
## Each scene should be fully self-contained as a debug environment and the
## expectation is that we can just load -> instantiate it and add it to the
## game's scene tree.[br]
## [br]
## For details of how this works see Driver.request_debug_load
static func get_scenes() -> Dictionary:
	var opts := Utils.walk_directory(
		Utils.LEVEL_DIR, func(s: String) -> bool: return s.ends_with(".tscn")
	)

	var result := {}
	for a in opts:
		var v := Utils.level_path_to_name(a)
		result[v] = v

	return result
