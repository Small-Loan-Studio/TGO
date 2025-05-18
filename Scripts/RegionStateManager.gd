# TODO - cursor slop
class_name RegionStateManager
extends Node

## Emitted when a variable changes. Provides the full path, old value, and new value
signal variable_changed(path: String, old_value: Variant, new_value: Variant)

## The root state dictionary that holds all variables
var _state: Dictionary = {}

## Dictionary of expected variables and their default values
## Loaded from project settings
var _expected_vars: Dictionary = {}

## If true, warnings will be printed when accessing undefined variables
@export var strict_mode := true

func _enter_tree() -> void:
    # Load expected variables from project settings
    _expected_vars = ProjectSettings.get_setting("tgo/region_states", {})
    
    # Initialize state with default values from expected vars
    _state = _expected_vars.duplicate(true)

## Sets a variable at the given path. The path can be dot-separated to indicate nesting.
## Example: set_variable("dungeon.east_wing.door1", true)
func set_variable(path: String, value: Variant, ignore_validation := false) -> void:
    if strict_mode and not ignore_validation:
        var expected_value := _get_from_nested_dict(path, _expected_vars)
        if expected_value == null:
            printerr("Attempting to set undefined variable: %s" % path)
            return
        
        # Could add type validation here if needed
        # if typeof(value) != typeof(expected_value):
        #     printerr("Type mismatch for %s: expected %s, got %s" % [
        #         path, typeof(expected_value), typeof(value)
        #     ])
        #     return
    
    var old_value = get_variable(path)
    if old_value == value:
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
    variable_changed.emit(path, old_value, value)

## Gets a variable at the given path. Returns null if the path doesn't exist.
## Example: get_variable("dungeon.east_wing.door1")
func get_variable(path: String, ignore_validation := false) -> Variant:
    if strict_mode and not ignore_validation:
        if not _has_in_nested_dict(path, _expected_vars):
            printerr("Attempting to get undefined variable: %s" % path)
            return null
    
    return _get_from_nested_dict(path, _state)

## Returns true if a variable exists at the given path
func has_variable(path: String) -> bool:
    return _has_in_nested_dict(path, _state)

## Returns true if a variable is defined in the expected variables
func is_defined_variable(path: String) -> bool:
    return _has_in_nested_dict(path, _expected_vars)

## Saves the current state to a dictionary
func save() -> Dictionary:
    return _state.duplicate(true)

## Loads state from a dictionary, replacing any existing state
func load(content: Dictionary) -> void:
    _state.clear()
    
    if strict_mode:
        # Only load values that are defined in expected_vars
        for path in _get_all_paths(_expected_vars):
            var value = _get_from_nested_dict(path, content)
            if value != null:
                set_variable(path, value, true)  # ignore_validation=true since we're checking here
    else:
        _state = content.duplicate(true)

## Clears all state back to defaults
func clear() -> void:
    _state = _expected_vars.duplicate(true)

## Gets all defined variable paths
func get_defined_paths() -> Array[String]:
    return _get_all_paths(_expected_vars)

## Gets the default value for a path
func get_default_value(path: String) -> Variant:
    return _get_from_nested_dict(path, _expected_vars)

## Helper function to get a value from a nested dictionary using a dot path
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

## Helper function to check if a path exists in a nested dictionary
func _has_in_nested_dict(path: String, dict: Dictionary) -> bool:
    return _get_from_nested_dict(path, dict) != null

## Helper function to get all possible paths in a nested dictionary
func _get_all_paths(dict: Dictionary, base_path: String = "") -> Array[String]:
    var paths: Array[String] = []
    
    for key in dict:
        var current_path = base_path + ("." if base_path else "") + key
        if dict[key] is Dictionary:
            paths.append_array(_get_all_paths(dict[key], current_path))
        else:
            paths.append(current_path)
    
    return paths