class_name BadLevelA
extends LevelBase


func level_setup() -> void:
	level_name = get_scene_file_path().get_file().get_basename()
	print(level_name + " setup")

