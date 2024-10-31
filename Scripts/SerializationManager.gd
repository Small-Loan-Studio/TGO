class_name SerializationManager
extends Node

const SAVE_FILE_PATH: String = "user://save/levels/"
const LEVEL_EXTENSION_NAME: String = ".scn"
const SAVE_FILE_NAME: String = "TGO.sav"

@onready var _persistent_levels: Dictionary = {}


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if !DirAccess.dir_exists_absolute(SAVE_FILE_PATH):
		var error: int = DirAccess.make_dir_recursive_absolute(SAVE_FILE_PATH)
		printerr("Could not create directory, Error: ", error)

func _save_game() -> void:
	pass


func _load_game() -> void:
	pass
	
## the dictionary containing, a Key - the name of a level, 
## and a Value - the location on disk of 
func get_persistent_level_dict() -> Dictionary:
	return _persistent_levels
	
## Checks the dictionary if the requested level is already in the dictionary
func check_level_persistence(target_level_name: String) -> bool:
	return _persistent_levels.has(target_level_name)

## Overwrites an existing persisted level on disk
func _update_persistent_level(level: LevelBase) -> void:
	print("Updating persistent level dictionary")

	var file_path:String = SAVE_FILE_PATH + level.level_name + LEVEL_EXTENSION_NAME
	var package: PackedScene = PackedScene.new()
	for x in level.get_children():
		x.set_owner(level)
	package.pack(level)
	
	var error:int = ResourceSaver.save(package, file_path)
	if error:
		printerr("Error saving previous level: ", )
	
	_persistent_levels[level.level_name] = SAVE_FILE_PATH+level.level_name+LEVEL_EXTENSION_NAME


func _save_persistent_levels() -> void:
	pass

func _load_persistent_levels(level_name: String) -> void:
	pass
