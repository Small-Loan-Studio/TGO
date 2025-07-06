@tool
class_name LevelBase
extends Node2D

const DEFAULT_MARKER: String = "PlayerStart"
const MATERIAL_LAYER = "material"

## Not for normal use -- explicitly paired with level_name to cache the
## the res:// path on initial load. Nested save state basically depends
## on not touching this.
@export var _name: String

## Set this to a color to get an overlay and rough simulation of how your
## lighting will look in that setting
@export var editor_overlay_color: Color = Color.DIM_GRAY:
	get:
		return editor_overlay_color
	set(value):
		editor_overlay_color = value
		if Engine.is_editor_hint() && _canvas_modulate != null:
			_canvas_modulate.color = value

## When enabled the color overlay will be applied. When unset it will not.
@export var apply_editor_overlay: bool = false:
	get:
		return apply_editor_overlay
	set(value):
		apply_editor_overlay = value
		if Engine.is_editor_hint() && _canvas_modulate != null:
			_canvas_modulate.visible = apply_editor_overlay

@export var fixed_ambient_color: Color = Color.RED:
	get:
		return fixed_ambient_color
	set(value):
		fixed_ambient_color = value
		if _canvas_modulate != null:
			if use_fixed_ambient == "CUSTOM":
				_canvas_modulate.color = value
				_canvas_modulate.visible = true

@export_enum("BLACKOUT", "CUSTOM", "DISABLE") var use_fixed_ambient: String:
	set(value):
		use_fixed_ambient = value
		if _canvas_modulate != null:
			if value == "CUSTOM":
				_canvas_modulate.color = fixed_ambient_color
				_canvas_modulate.visible = true
			elif value == "DISABLE":
				_canvas_modulate.visible = false
			elif value != "":
				_canvas_modulate.color = _interior_light[value]
				_canvas_modulate.visible = true
			elif value == "":
				_canvas_modulate.visible = false

var driver: Driver

var level_name: String:
	get:
		if _name == "":
			_name = Utils.level_path_to_name(get_scene_file_path())
		return _name
	set(value):
		printerr("Unable to assign level_name to: ", level_name)

var _interior_light: Dictionary = {"BLACKOUT": Color.BLACK}
var _has_material_data: bool = false

var _canvas_modulate: CanvasModulate = null:
	get:
		var path := "CanvasModulate"
		if has_node(path):
			# done as a property getter because we can't use @onready as part of @tool
			# script and I don't know a better pattern
			return get_node(path)
		return null

@onready var tilemap: TileMap = $TileMap

@onready var _marker_root := $Markers


func _ready() -> void:
	var ts := tilemap.get_tileset()
	var idx := ts.get_custom_data_layer_by_name(MATERIAL_LAYER)
	_has_material_data = idx != -1


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
func swap_to_level(target_level_name: String, marker_target: String) -> void:
	driver.load_level(target_level_name, marker_target)


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


## Examines nodes that are marked as having an ID and returns the first match
## if any are found.
func get_by_id(id: String) -> Node2D:
	if id == "" || id == null:
		printerr("Unable to find empty or null id")
		return null

	id = id.to_lower()
	for n in get_tree().get_nodes_in_group(Utils.GroupNames.HasID):
		if n.id.to_lower() == id:
			return n
	return null


func get_region_by_id(region_id: String) -> ControlledRegion:
	var region: ControlledRegion = null
	for maybe_region: Node2D in get_tree().get_nodes_in_group(Utils.GroupNames.ControlledRegions):
		if maybe_region is ControlledRegion:
			region = maybe_region as ControlledRegion
		if region == null || region.region_id != region_id:
			continue
		if region.region_id == region_id:
			return region
	return null


func get_audio_node(id: String) -> AudioNode:
	for node: AudioNode in get_tree().get_nodes_in_group(Utils.GroupNames.AudioNodes):
		if node.id == id:
			return node
	return null


func get_map_coords(global_pos: Vector2) -> Vector2i:
	var map_local_coords: Vector2 = tilemap.to_local(global_pos)
	return tilemap.local_to_map(map_local_coords)


func get_tile_material(map_coords: Vector2i) -> String:
	if !_has_material_data:
		return ""

	var mat := ""
	for layer: int in range(tilemap.get_layers_count()):
		var td: TileData = tilemap.get_cell_tile_data(layer, map_coords)
		if td != null:
			var maybe_mat: Variant = td.get_custom_data(MATERIAL_LAYER)
			if maybe_mat != null:
				mat = maybe_mat as String
	return mat
