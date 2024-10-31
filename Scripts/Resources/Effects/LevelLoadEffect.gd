class_name LevelLoadEffect
extends Effect

## Path to a scene that should be loaded as the next level.
## TODO: Unclear why using PackedScene didn't work here -- that's very much
## the ideal approach :shrug: Try again in the future when we have time to
## debug
@export var load_level_name: String

## What marker should we use to locate the player when placing
## them in the next scene? If nothing is provided the default
## is used (c.f. LevelBase.DEFAULT_MARKER)
@export var marker_name: String = ""


func act(_actor_id: String, cur_level: LevelBase) -> void:
	if cur_level == null:
		return

	# TODO: should this be cur_level.driver.load_level(new_level) instead
	cur_level.swap_to_level(load_level_name, marker_name)
