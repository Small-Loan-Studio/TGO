class_name LevelBase
extends Node2D

var driver: Driver

# @export var level_setup: Callable

func setup(driver_in: Driver) -> void:
	driver = driver_in
	# if level_setup != null:
	# 	level_setup.call()
	level_setup()


func level_setup() -> void:
	print('LevelBase.level_setup()')


func load_into_level(tgt: PackedScene) -> void:
	driver.load_level(tgt)