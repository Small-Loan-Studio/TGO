class_name SerializationManager
extends Node

signal load_saved_level(level_name: String, marker: String)

const INVENTORY_FOLDER := "inventory/"
const TGO_SCREENSHOT_FILE_NAME := "thumbnail.png"
const SAVE_FILE_NAME := "TGO.sav"
const ZIP_FILE_NAME := "TGO.zip"
const META_FILE_NAME := "TGO.meta"

const WORLD_STATE_FILE := "world_state.bin"
const DIALGOIC_SLOT := "tgo_world"
const DIALOGIC_FILENAME := "state.txt"
const DIALOGIC_THUMBNAIL := "thumbnail.png"

@export var is_loading_game: bool = false

## Stores all the levels the player has encountered during a playthrough.
## Key: the name of a level
## Value: the location on disk of the named level
var _persistent_levels: Dictionary = {}


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if !_check_file_path_exists():
		_create_file_paths()


func _check_file_path_exists() -> bool:
	var exist: bool = DirAccess.dir_exists_absolute(Utils.user_save_dir())

	if !exist:
		printerr("Save file path does not exist")
	return exist


func _check_save_exists() -> bool:
	var path := Utils.USER_DATA_DIR + SAVE_FILE_NAME
	var exist: bool = FileAccess.file_exists(path)
	if !exist:
		printerr("Save file (%s) does not exist" % [path])
	return exist


func _create_file_paths() -> int:
	print("Creating file path")
	var error: int
	error = DirAccess.make_dir_recursive_absolute(Utils.user_save_dir())
	if error != OK && error != ERR_ALREADY_EXISTS:
		printerr("Could not create directory: ", Utils.user_save_dir(), " Error: ", error)
		return error

	if !DirAccess.dir_exists_absolute(Utils.user_level_dir()):
		error = DirAccess.make_dir_absolute(Utils.user_level_dir())
		if error != OK:
			printerr("Could not create directory: ", Utils.user_level_dir(), " Error: ", error)
			return error

	if !DirAccess.dir_exists_absolute(Utils.user_inventory_dir()):
		error = DirAccess.make_dir_absolute(Utils.user_inventory_dir())
		if error != OK:
			printerr("Could not create directory: ", Utils.user_inventory_dir(), " Error: ", error)

	return error


## Saves everything necessary in the game and creates a .sav file recording this data.
## Connected to Driver.gd signal: save_level
func save_game() -> void:
	print("Saving Game")
	if !_check_file_path_exists():
		_create_file_paths()

	# Need to get the last loaded level to update and its name for meta data which lives in Driver.
	var last_level := Driver.instance().get_current_level()

	var meta_data := SaveFileMeta.new()

	if last_level != null:
		update_level(last_level)
		meta_data.level_name = last_level.level_name

	Driver.instance().inventory_mgr.save(Utils.user_save_dir())

	_write_meta(meta_data)
	if !_write_dialogic_data():
		printerr("Unable to save world game state")
		return

	_write_zip_file()
	DirAccess.rename_absolute(
		Utils.user_data_dir() + ZIP_FILE_NAME, Utils.user_data_dir() + SAVE_FILE_NAME
	)
	print("Saved Game")


## Loads a previously saved game. Connected to Driver.gd signal: load_save
func load_game() -> void:
	print("Loading Game")

	if _check_save_exists():
		var error: int = DirAccess.rename_absolute(
			Utils.user_data_dir() + SAVE_FILE_NAME, Utils.user_data_dir() + ZIP_FILE_NAME
		)
		if error != OK:
			printerr("Could not open sav file: ", error)
			return

	is_loading_game = true
	if !_unzip_save():
		printerr("Unable to decompress save file.")
		return

	if !_restore_dialogic():
		printerr("Unable to restore world state")
		return

	var save_meta := _read_meta()
	if save_meta != null:
		_load_saved_level(save_meta.level_name)

	DirAccess.rename_absolute(
		Utils.user_data_dir() + ZIP_FILE_NAME, Utils.user_data_dir() + SAVE_FILE_NAME
	)
	print("Loaded Game")


## Deletes the save folder where persisted data exists and the TGO.sav file if they exist.
## NOTE: These should probably be seperated in the future because we will always want to clear
## the persisted data folder when the game closes not necessarily delete any save files.
func delete_save() -> void:
	print("Deleting Save...")
	if FileAccess.file_exists("user://" + SAVE_FILE_NAME):
		OS.move_to_trash(ProjectSettings.globalize_path(Utils.user_data_dir() + SAVE_FILE_NAME))

	if _check_file_path_exists():
		OS.move_to_trash(ProjectSettings.globalize_path(Utils.user_save_dir()))
	else:
		printerr("There is no save to delete")
		return
	print("Deleted Save")


## the dictionary containing, a Key - the name of a level,
## and a Value - the location on disk of the named level
func get_persistent_level_dict() -> Dictionary:
	return _persistent_levels


## Checks the dictionary if the requested level is already in the the working set.
func check_level_persistence(target_level_name: String) -> bool:
	return _persistent_levels.has(target_level_name)


## Overwrites an existing persisted level on disk. This can be thought of as
## checkpointing the level until we revisit.
func update_level(level: LevelBase) -> void:
	var file_path: String = Utils.level_to_path_binary(level.level_name)
	var level_basedir := file_path.get_base_dir()

	var create_err := DirAccess.make_dir_recursive_absolute(level_basedir)
	if create_err != OK && create_err != ERR_ALREADY_EXISTS:
		printerr(
			(
				"Failed to create level directory '%s' for %s: %d"
				% [
					level_basedir,
					level.level_name,
				]
			)
		)
		return

	var package: PackedScene = PackedScene.new()
	for node in level.get_children():
		node.set_owner(level)
	package.pack(level)

	var error: int = ResourceSaver.save(package, file_path)
	if error != OK:
		printerr("Error saving previous level to %s: %s" % [file_path, error])
		return

	_persistent_levels[level.level_name] = Utils.level_to_path_binary(level.level_name)


func _load_saved_level(map_name: String) -> void:
	load_saved_level.emit(map_name, "")
	is_loading_game = false


func _write_zip_file() -> void:
	var writer: ZIPPacker = ZIPPacker.new()
	var error := writer.open(Utils.user_data_dir() + ZIP_FILE_NAME)
	if error != OK:
		printerr("Could not open zip: ", error)
		return

	# Saves the files inside the save folder
	var file_list := Utils.walk_directory(Utils.user_save_dir())
	for file_name: String in file_list:
		writer.start_file(file_name)
		writer.write_file(FileAccess.get_file_as_bytes(Utils.user_save_dir() + file_name))

	writer.close_file()
	writer.close()


func _unzip_save() -> bool:
	var reader: ZIPReader = ZIPReader.new()
	var error := reader.open(Utils.user_data_dir() + ZIP_FILE_NAME)
	if error != OK:
		printerr("Could not open zip: ", error)
		return false

	# file_name includes the whole directory path within the zip file for example,
	# the filename for a level would be level/level_name.scn
	for file_name: String in reader.get_files():
		if file_name.ends_with(".scn") or file_name.ends_with(".tscn"):
			var file: PackedByteArray = reader.read_file(file_name, true)
			var new_file: FileAccess = FileAccess.open(
				Utils.user_save_dir() + file_name, FileAccess.WRITE_READ
			)
			if !new_file:
				printerr("newfile is null: ", FileAccess.get_open_error())
				return false

			new_file.store_buffer(file)

			var map_name: String = file_name.substr(Utils.LEVEL_FOLDER.length()).split(".")[0]

			_persistent_levels[map_name] = Utils.user_save_dir() + file_name

			new_file.close()

	reader.close()
	return true


func _write_dialogic_data() -> bool:
	var err := Dialogic.Save.save(DIALGOIC_SLOT)
	if err != OK:
		printerr("Failed to save world state: %d" % [err])
		return false
	err = (
		DirAccess
		. copy_absolute(
			Dialogic.Save.SAVE_SLOTS_DIR.path_join(DIALGOIC_SLOT).path_join(DIALOGIC_FILENAME),
			Utils.user_save_dir().path_join(WORLD_STATE_FILE),
		)
	)
	if err != OK:
		printerr("Failed to copy dialogic state: %d" % [err])
		return false

	err = (
		DirAccess
		. copy_absolute(
			Dialogic.Save.SAVE_SLOTS_DIR.path_join(DIALGOIC_SLOT).path_join(DIALOGIC_THUMBNAIL),
			Utils.user_save_dir().path_join(TGO_SCREENSHOT_FILE_NAME),
		)
	)
	if err != OK:
		printerr("Failed to copy over save state screenshot: %d" % [err])
		return false

	return true


func _restore_dialogic() -> bool:
	var err := DirAccess.make_dir_absolute(Dialogic.Save.SAVE_SLOTS_DIR.path_join(DIALGOIC_SLOT))
	if err != OK && err != ERR_ALREADY_EXISTS:
		printerr("Failed to make Dialogic save state dir: %d" % [err])
		return false

	err = (
		DirAccess
		. copy_absolute(
			Utils.user_save_dir().path_join(WORLD_STATE_FILE),
			Dialogic.Save.SAVE_SLOTS_DIR.path_join(DIALGOIC_SLOT).path_join(DIALOGIC_FILENAME),
		)
	)
	if err != OK:
		printerr("Failed to move world state into place: %d" % [err])
		return false

	err = Dialogic.Save.load(DIALGOIC_SLOT)
	if err != OK:
		printerr("Failed to restore world state in Dialogic: %d" % [err])
		return false

	return true


func _write_meta(data: SaveFileMeta) -> bool:
	var path := Utils.user_save_dir() + META_FILE_NAME
	var file := FileAccess.open(path, FileAccess.WRITE_READ)
	if !file:
		printerr("Unable to write metadata %s: %s" % [path, FileAccess.get_open_error()])
		return false

	file.store_string(data.marshal())

	file.close()
	return true


func _read_meta() -> SaveFileMeta:
	var path := Utils.user_save_dir() + META_FILE_NAME
	var file := FileAccess.open(path, FileAccess.READ)

	if !file:
		printerr("Unable to read metadata %s: %d" % [path, FileAccess.get_open_error()])
		return null

	var meta_string := file.get_as_text(true)
	file.close()

	return SaveFileMeta.unmarshal(meta_string)


class SaveFileMeta:
	extends RefCounted

	var level_name: String

	func marshal() -> String:
		var data := {
			"meta_version": 0,
			"level": level_name,
		}

		return JSON.stringify(data, "\t")

	static func unmarshal(input_str: String) -> SaveFileMeta:
		var sf := SaveFileMeta.new()

		var json := JSON.new()
		var err := json.parse(input_str)
		if err != OK:
			printerr(
				(
					"Failed to parse save data. Line: %d, error: %s"
					% [
						json.get_error_line(),
						json.get_error_message(),
					]
				),
			)
			return null

		if json.data["meta_version"] != 0:
			assert(false, "Unknown meta file format")

		sf.level_name = json.data["level"]

		return sf
