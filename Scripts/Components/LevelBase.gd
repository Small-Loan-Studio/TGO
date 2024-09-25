class_name LevelBase
extends Node2D

const DEFAULT_MARKER: String = "PlayerStart"

var driver: Driver

@onready var _marker_root := $Markers


## TODO: possible set up a by_id(String) -> Node2D function

func setup(driver_in: Driver) -> void:
	driver = driver_in
	level_setup()


## Called when the level has been added to the game world scene tree
## and driver has been set. Intended to be overridden by subclasses; any
## level specific setup that impacts all levels should happen in setup.
func level_setup() -> void:
	pass


## Called before a level gets freed and unloaded, can be used to save
## locations of objects etc that we may want to repopulate to their original
## state when returning to this level.
func save_level_state() -> void:
	pass


## Switches the current level out for some new target level.
##
## TODO: Currently this is just plumbing between the level and driver that
## may be unnecessary. Think about the wiring and what this should look like.
func swap_to_level(tgt: LevelBase, marker_target: String) -> void:
	driver.load_level(tgt, marker_target)


## Finds a named position under the market root. Used in conjuction with
## InteractableLevelLoad to place characters when they enter the scene.
##
## If no marker can be found we use the first child of the marker root.
## If there are none defined this will throw an error.
func get_named_location(named_pos: String) -> Vector2:
	var marker: Node2D = _marker_root.get_node(named_pos)

	if marker == null:
		printerr("Failed to locate named location '%s' using default" % [named_pos])
		if _marker_root.get_child_count() > 0:
			marker = _marker_root.get_child(0)
		else:
			printerr("Failed to find any location markers")

	return marker.global_position
