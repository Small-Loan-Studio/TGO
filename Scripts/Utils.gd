@tool
class_name Utils
extends RefCounted

const PLAYER_ID := "Devin"
const QUEST_DIR := "res://Scripts/Resources/Quests"
const USER_DATA_DIR := "user://"
const MARKERS_SECTION_NAME = "Markers"
## TODO: Replace this with the official location for levels in the future
const LEVEL_DIR := "res://Scenes/Levels/"
const LEVEL_EXT_BIN := ".scn"
const LEVEL_EXT_TXT := ".tscn"
const SAVE_FOLDER := "save/"
const LEVEL_FOLDER := "level/"
const INVENTORY_FOLDER := "inventory/"


## Finds a LevelBase ancestor of a node if it exists. Returns null if none
## found.
static func get_level_parent(node: Node) -> LevelBase:
	var ref := node
	while not (ref is LevelBase):
		ref = ref.get_parent()
		if ref == null:
			printerr("Switch: did not find a LevelBase parent for %s" % [node.name])
			return null

	return ref


## converts a string to a bool. string comparisons are case insensitive
## - 1 and t or true map to true.
## - 0 and f or false map to false.
##
## any other string will return false but print an error
static func str_to_bool(in_s: String) -> bool:
	in_s = in_s.to_lower()
	if in_s == "1" || in_s == "t" || in_s == "true":
		return true
	if in_s == "" || in_s == "0" || in_s == "f" || in_s == "false":
		return false
	printerr("Fallback to false trying to convert '%s' to bool" % [in_s])
	return false


# converts an angle relative to Vector2.UP into a direction;
# the angle is expected to be radians between [-TAU, TAU]
static func angle_to_direction(
	angle_rad: float,
	direction_count: Enums.DirectionMode = Enums.DirectionMode.EIGHT,
) -> Enums.Direction:
	match direction_count:
		Enums.DirectionMode.EIGHT:
			return _angle_to_direction_8(angle_rad)
		Enums.DirectionMode.FOUR:
			return _angle_to_direction_4(angle_rad)
	assert(false, "Bad direction mode: " + str(direction_count))
	return _angle_to_direction_4(angle_rad)


static func _angle_to_direction_8(angle_rad: float) -> Enums.Direction:
	# convert to degrees for my trig-lazy brain
	var normalized: float = angle_rad / TAU * 360
	var abs_normalized: float = abs(normalized)
	var side: int = 1 if normalized >= 0 else 0

	var segments: int = (abs_normalized / 22.5) as int

	if segments < 1:
		return Enums.Direction.NORTH
	if segments < 3:
		return [Enums.Direction.NORTH_WEST, Enums.Direction.NORTH_EAST][side]
	if segments < 5:
		return [Enums.Direction.WEST, Enums.Direction.EAST][side]
	if segments < 7:
		return [Enums.Direction.SOUTH_WEST, Enums.Direction.SOUTH_EAST][side]
	return Enums.Direction.SOUTH


static func _angle_to_direction_4(angle_rad: float) -> Enums.Direction:
	# convert to degrees for my trig-lazy brain
	var normalized: float = angle_rad / TAU * 360
	var abs_normalized: float = abs(normalized)
	var side: int = 1 if normalized >= 0 else 0

	var segments: int = (abs_normalized / 45) as int

	if segments < 1:
		return Enums.Direction.NORTH
	if segments < 3:
		return [Enums.Direction.WEST, Enums.Direction.EAST][side]
	return Enums.Direction.SOUTH


static func level_path_to_name(path: String) -> String:
	if path.begins_with("res://"):
		path = path.substr(Utils.LEVEL_DIR.length())
	if path.ends_with(".tscn"):
		path = path.substr(0, path.length() - 5)
	if path.ends_with(".scn"):
		path = path.substr(0, path.length() - 4)
	return path


static func level_is_debug(name: String) -> bool:
	return name.begins_with("Debug/")


## Used for getting persistent levels and loading saved levels [b]NOT[/b] the original levels
static func level_to_path_binary(level_name: String) -> String:
	return USER_DATA_DIR + SAVE_FOLDER + LEVEL_FOLDER + level_name + LEVEL_EXT_BIN


## Used for getting brand new levels in their original state [b]NOT[/b] persistent levels
static func level_to_path_text(level_name: String) -> String:
	return LEVEL_DIR + level_name + LEVEL_EXT_TXT


static func user_data_dir() -> String:
	return USER_DATA_DIR


static func user_save_dir() -> String:
	return USER_DATA_DIR + SAVE_FOLDER


static func user_level_dir() -> String:
	return USER_DATA_DIR + SAVE_FOLDER + LEVEL_FOLDER


static func user_inventory_dir() -> String:
	return USER_DATA_DIR + SAVE_FOLDER + INVENTORY_FOLDER


## Visits all files starting from some root directory calling the provided
## predicat function to determin if the should be included in the resulting
## fileset.
##
## Can be configured to recurse or not, if recursing the sub-dir files will
## have relative paths to the root.
##
## the predicate function, if not specified will include all files.
static func walk_directory(
	root: String,
	pred_fn: Callable = func(s: String) -> bool: return true,
	recursive: bool = true,
) -> Array[String]:
	var da := DirAccess.open(root)
	if da == null:
		printerr("Unable to open %s: %s", [root, DirAccess.get_open_error()])
		return []

	var results: Array[String] = []

	da.include_navigational = false
	da.list_dir_begin()

	var file_name := da.get_next()
	while file_name != "":
		if da.current_is_dir():
			if recursive:
				var nested := walk_directory("%s/%s" % [root, file_name], pred_fn)
				for e in nested:
					results.append("%s/%s" % [file_name, e])
		else:
			if pred_fn == null || pred_fn.call(file_name):
				results.append(file_name)
		file_name = da.get_next()
	da.list_dir_end()

	return results


## returns dialogic variable info as parsed from ProjectSettings; this
## is approximately the same process Dialogic uses at runtime but we
## can't use that during editing because it hasn't loaded VAR subsystem.
## As such this can only interact with variables that are defined through
## the UI and not anything created at runtime.
static func ersatz_dialogic_get_var(path: String) -> Variant:
	var parts := path.split(".")

	var folder: Dictionary = ProjectSettings.get_setting("dialogic/variables", {}).duplicate(true)
	while len(parts) > 1:
		var dict_name: String = parts[0]
		parts = parts.slice(1)
		folder = folder[dict_name]

	if len(parts) != 1:
		printerr("Error looking for dialogic variable '%s'" % [path])
		return []

	if !folder.has(parts[0]):
		return []

	var v: Variant = folder[parts[0]]
	return [v, typeof(v)]


#gdlint: disable=class-variable-name
class GroupNames:
	static var HasID := "NodesWithID"
	static var AudioNodes := "RegisteredAudioNode"
	static var Doors := "Doors"


class WwiseIds:
	static var AudioManager := "Audio Manager"
#gdlint: enable=class-variable-name
