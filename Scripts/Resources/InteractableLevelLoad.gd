class_name InteractableLevelLoad
extends InteractableAction

## Path to a scene that should be loaded as the next level
@export var load_level_path: String

## What marker should we use to locate the player when placing
## them in the next scene? If nothing is provided the default
## is used (c.f. LevelBase.DEFAULT_MARKER)
@export var marker_name: String = ""


func act(_actor: Character, cur_level: LevelBase) -> void:
	if cur_level == null:
		return

	var load_level := load(load_level_path) as PackedScene
	var new_level := load_level.instantiate() as LevelBase
	# TODO: should this be cur_level.driver.load_level(new_level) instead
	cur_level.swap_to_level(new_level, marker_name)