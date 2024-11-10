class_name LevelLoadEffect
extends Effect

## Path to a scene that should be loaded as the next level.
## TODO: Unclear why using PackedScene didn't work here -- that's very much
## the ideal approach :shrug: Try again in the future when we have time to
## debug
@export var load_level_path: String

## What marker should we use to locate the player when placing
## them in the next scene? If nothing is provided the default
## is used (c.f. LevelBase.DEFAULT_MARKER)
@export var marker_name: String = ""


func act(_actor_id: String, cur_level: LevelBase) -> void:
	if cur_level == null:
		return

	var load_level: PackedScene = load(load_level_path)
	var new_level: LevelBase = load_level.instantiate()
	# TODO: should this be cur_level.driver.load_level(new_level) instead
	cur_level.swap_to_level(new_level, marker_name)
