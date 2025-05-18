# TODO - partially cursor slop
class_name RegionStateManager
extends Node

## Emitted when a variable changes. Provides the full path, old value, and new value
signal region_changed(path: String, old_value: RegionState, new_value: RegionState)

## The root state dictionary that holds all variables
## Map[String, RegionState]
var _state: Dictionary = {}

## Dictionary of expected variables and their default values
## Loaded once at _enter_tree()
## Map[String, RegionState]
var _expected_vars: Dictionary = {}

## If true, warnings will be printed when accessing undefined variables
@export var strict_mode := true

func _enter_tree() -> void:
	print("RSM._enter_tree")

	# Load expected variables from project settings
	_expected_vars = ProjectSettings.get_setting("tgo/region_states", {})
	print("RSM._enter_tree: _expected_vars: %s" % _expected_vars)
	# Initialize state with default values from expected vars
	_state = _expected_vars.duplicate(true)

## Sets a variable at the given path. The path can be dot-separated to indicate nesting.
## Example: set_state("dungeon.east_wing.door1", new_state)
func set_state(path: String, value: RegionState) -> void:
	if strict_mode:
		var expected_value: Variant = _get_from_nested_dict(path, _expected_vars)
		if expected_value == null:
			printerr("Setting an undefined variable; this is likely an error: %s" % path)
			return
		
	var old_value: RegionState = get_state(path)
	if old_value.equal(value):
		return
		
	var parts := path.split(".")
	var current_dict := _state
	
	# Navigate to the correct nested dictionary
	while len(parts) > 1:
		var dict_name: String = parts[0]
		parts = parts.slice(1)
		
		if not current_dict.has(dict_name):
			current_dict[dict_name] = {}
		elif not current_dict[dict_name] is Dictionary:
			current_dict[dict_name] = {}
			
		current_dict = current_dict[dict_name]
	
	# Set the final value
	current_dict[parts[0]] = value
	region_changed.emit(path, old_value, value)

## Gets a variable at the given path. Returns a new RegionState if the path doesn't exist.
## Example: get_variable("dungeon.east_wing.door1")
func get_state(path: String) -> RegionState:
	if strict_mode:
		if not _has_in_nested_dict(path, _expected_vars):
			printerr("Returning default value for undefined variable: %s" % path)
			return RegionState.new()
	
	var rs := _get_from_nested_dict(path, _state) as RegionState
	return rs.clone()

## Returns true if a variable exists at the given path
func has(path: String) -> bool:
	return _has_in_nested_dict(path, _state)

## Saves the current state to a dictionary
func save() -> Dictionary:
	return _state.duplicate(true)

## Loads state from a dictionary, replacing any existing state
func load(content: Dictionary) -> void:
	_state.clear()
	_state = content.duplicate(true)

	for key: String in _expected_vars.keys():
		if !has(key):
			printerr("Loaded state missing variable: %s" % [key])
			set_state(key, _expected_vars[key])
	for key: String in content.keys():
		if _get_from_nested_dict(key, _expected_vars) == null:
			printerr("Loaded state missing expected variable: %s" % [key])

## Clears all state back to defaults
func clear() -> void:
	_state = _expected_vars.duplicate(true)

## Gets all variable paths
func dump_paths() -> Array[String]:
	return _get_all_paths(_state, "")

func block_region(path: String) -> void:
	var cur_state: RegionState = get_state(path)
	cur_state.passable = false
	set(path, cur_state)

func unblock_region(path: String) -> void:
	var cur_state: RegionState = get_state(path)
	cur_state.passable = true
	set(path, cur_state)

func show_region(path: String) -> void:
	var cur_state: RegionState = get_state(path)
	cur_state.visible = true
	set(path, cur_state)

func hide_region(path: String) -> void:
	var cur_state: RegionState = get_state(path)
	cur_state.visible = false
	set(path, cur_state)

## Helper function to get a value from a nested dictionary using a dot path
## Returns null of no path exists so we have to return a Variant because Godot's
## type system is shit.
func _get_from_nested_dict(path: String, dict: Dictionary) -> Variant:
	var parts := path.split(".")
	var current_dict := dict
	
	while len(parts) > 1:
		var dict_name: String = parts[0]
		parts = parts.slice(1)
		
		if not current_dict.has(dict_name) or not current_dict[dict_name] is Dictionary:
			return null
			
		current_dict = current_dict[dict_name]
	
	return current_dict.get(parts[0]) if len(parts) > 0 else null

## check if a path exists in a nested dictionary
func _has_in_nested_dict(path: String, dict: Dictionary) -> bool:
	return _get_from_nested_dict(path, dict) != null

## get all possible paths in a nested dictionary
func _get_all_paths(dict: Dictionary, base_path: String = "") -> Array[String]:
	var paths: Array[String] = []
	
	for key: String in dict:
		var current_path: String = base_path + ("." if base_path else "") + key
		if dict[key] is Dictionary:
			paths.append_array(_get_all_paths(dict[key], current_path))
		else:
			paths.append(current_path)
	
	return paths