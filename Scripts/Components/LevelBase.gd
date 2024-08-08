class_name LevelBase
extends Node2D

@onready var _marker_root := $Marker

var driver: Driver

# @export var level_setup: Callable

func setup(driver_in: Driver) -> void:
	print("LevelBase.setup - " + str(driver_in))
	driver = driver_in
	# if level_setup != null:
	# 	level_setup.call()
	level_setup()


func level_setup() -> void:
	print('LevelBase.level_setup()')


func save_level_state() -> void:
	pass


func swap_to_level(tgt: LevelBase) -> void:
	driver.load_level(tgt)


func get_named_location(named_pos: String) -> Vector2:
	var marker: Node2D = _marker_root.get_node(named_pos)

	if marker == null:
		printerr("Failed to locate named location '%s' using default" % [named_pos])
		if _marker_root.get_child_count() > 0:
			marker = _marker_root.get_child(0)
		else:
			printerr("Failed to find any location markers")

	return marker.global_position