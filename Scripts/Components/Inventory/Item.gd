@tool
class_name Item
extends Resource

const ITEM_PATH = "res://Scripts/Resources/Items"

@export var id: String = ""
@export var name: String = ""
## Unused property currently, will be necessary later on probably
@export var type: Enums.ItemType
@export_multiline var description: String = ""
@export var stackable: bool = false
@export var stack_size: int = 1:
	set(value):
		if stack_size > 1 && !stackable:
			printerr(
				(
					"Item %s has a stack_size of %s but has not set stackable to true"
					% [name, stack_size]
				)
			)
			stack_size = 1
		else:
			stack_size = value

@export var icon: Texture2D

## For equippable item types this configures what it does.
@export var gear_spec: Array[GearSpec] = []


func _to_string() -> String:
	return name


func save_state(c: Character) -> Array[Variant]:
	var state := [resource_path]
	for gs in gear_spec:
		# Relying on order is fragile af, probably need to plumb an ID, can't
		# rely on classname/typeof() <4.3, c.f., https://github.com/godotengine/godot/issues/21789
		state.append(gs.save_state(c))
	return state


func restore_state(c: Character, gs_data: Array[Variant]) -> void:
	if len(gs_data) != len(gear_spec):
		printerr("saved gearspec state and item config mismatch, trying anyway")

	# TODO: fragile! see note in save_state
	for i: int in range(len(gear_spec)):
		if i >= len(gear_spec):
			return
		var gs: GearSpec = gear_spec[i]
		var data: Variant = gs_data[i]
		gs.load_state(c, data)


#region utility functions for @tool usage


## walks the item directory and returns the id of all Item resources. This is
## intended only for use in the editor.
static func tool_all_ids() -> Array[String]:
	if !Engine.is_editor_hint():
		return []

	var r: Array[String] = []
	var paths := Utils.walk_directory(
		ITEM_PATH, func(s: String) -> bool: return s.ends_with(".tres")
	)
	for p in paths:
		var item := ResourceLoader.load(ITEM_PATH.path_join(p)) as Item
		if item != null:
			r.append(item.id)
	return r


## Walk item directory to find a resource with the provided ID. Some validation
## is done and we error if we find not exactly one item. Intended for use in the
## editor only.
static func tool_from_id(item_id: String) -> Item:
	if !Engine.is_editor_hint():
		return null

	var item_paths := Utils.walk_directory(
		ITEM_PATH,
		func(s: String) -> bool: return s.ends_with(".tres"),
	)

	var items := []
	for p in item_paths:
		var item := ResourceLoader.load(ITEM_PATH.path_join(p)) as Item
		if item != null:
			if item.id == item_id:
				items.append(item)

	if len(items) != 1:
		assert(
			false, "Unable to determine which item '%s' is associated with: %s" % [item_id, items]
		)
		return null

	return items[0]

#endregion
