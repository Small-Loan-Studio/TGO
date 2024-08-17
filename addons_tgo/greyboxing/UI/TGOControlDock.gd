@tool
class_name TGOControlDock
extends Control

## Used to identify the context in which we're operating on a level
enum LevelSection {
	UNKNOWN,  # catch all / error state
	ROOT,  #### base level data
	MAP,  ##### the tilemap
	OBJECTS,  # objects that exist in the level but aren't constrained to the grid
	MARKERS,  # location markers within the level
}

## This is the scene loaded for editing objects
const OBJECTS_HELPER_SCENE := "res://addons_tgo/greyboxing/UI/ObjectsHelper.tscn"
const TILEMAP_SECTION_NAME := "TileMap"
const OBJECTS_SECTION_NAME := "Objects"
const MARKERS_SECTION_NAME := "Markers"

var _plugin_ref: TGOGreyboxingToolsPlugin = null

var _selection: EditorSelection = null:
	get:
		return EditorInterface.get_selection()

## Holds a reference to the interface that's been constructed and displayed to
## edit a specific subsection. May be null if no UI is currently active
var _subsection_control: Control = null

## The top-level node for a given section within the edited level, e.g.,
## TileMap, Objects, or Marker.
var _active_section: Node = null

# UI references

@onready var _selection_label: Label = %SelectedLabel
@onready var _detail := %SectionDetails


## called to establish any hooks to external references. Should be called post _ready
func setup(plugin_ref: TGOGreyboxingToolsPlugin) -> void:
	_plugin_ref = plugin_ref
	var selection := EditorInterface.get_selection()
	selection.selection_changed.connect(_update_selection)
	_update_selection()


## UI signal handler to trigger a plugin reload.
func _reload() -> void:
	_plugin_ref.reload()


## Handler for the UI selection changing.
func _update_selection() -> void:
	var root := EditorInterface.get_edited_scene_root()
	if !(root is LevelBase):
		_selection_label.text = "Only active while editing LevelBase"
		_active_section = null
		_update_section_control(LevelSection.UNKNOWN)
		return

	# ensure we're only dealing with a single selected node
	var selected_node := _get_node(_selection.get_selected_nodes())
	if selected_node == null:
		_active_section = null
		_update_section_control(LevelSection.UNKNOWN)
		return

	var section := _get_section(selected_node, root)
	var next_section := _get_section_node(selected_node, root, section)
	if _active_section == next_section:
		# bail early so we can click around a section without trashing the UI
		return

	_active_section = _get_section_node(selected_node, root, section)
	_update_section_control(section)


## Returns the node currently selected in a scene. If no node, or multiple
## nodes, are selected then it returns null.
func _get_node(nodes: Array[Node]) -> Node:
	if nodes.size() == 0:
		return null
	if nodes.size() > 1:
		return null
	return nodes[0]


## Given a selected node, the edited Levelbase, and a target section return the
## node corresponding to that section type. Returns null if things go awry.
func _get_section_node(selected: Node, root: LevelBase, typ: LevelSection) -> Node:
	if typ == LevelSection.UNKNOWN:
		return null

	if typ == LevelSection.ROOT:
		return root

	while selected != root:
		if typ == LevelSection.MAP && selected.name == TILEMAP_SECTION_NAME:
			return selected
		if typ == LevelSection.OBJECTS && selected.name == OBJECTS_SECTION_NAME:
			return selected
		if typ == LevelSection.MARKERS && selected.name == MARKERS_SECTION_NAME:
			return selected

		selected = selected.get_parent()

	return null


## Returns which section a selected node is in within a LevelBase.
func _get_section(selected: Node, root: LevelBase) -> LevelSection:
	if selected == root:
		return LevelSection.ROOT

	while selected != root:
		match selected.name:
			TILEMAP_SECTION_NAME:
				return LevelSection.MAP
			OBJECTS_SECTION_NAME:
				return LevelSection.OBJECTS
			MARKERS_SECTION_NAME:
				return LevelSection.MARKERS
		selected = selected.get_parent()

	return LevelSection.UNKNOWN


## switches the control to be the one appropriate for the selected section
## cleans up/removes a previous control if one was set
func _update_section_control(section: LevelSection) -> void:
	_selection_label.text = "Editing: %s" % [_level_section_str(section)]

	if _subsection_control != null:
		_detail.remove_child(_subsection_control)
		_subsection_control.queue_free()
		_subsection_control = null

	if section == LevelSection.OBJECTS:
		var oh: ObjectsHelper = (
			(ResourceLoader.load(OBJECTS_HELPER_SCENE) as PackedScene).instantiate()
		)
		oh.setup(_plugin_ref, _active_section)
		_subsection_control = oh
		_detail.add_child(_subsection_control)


func _level_section_str(ls: LevelSection) -> String:
	return {
		LevelSection.UNKNOWN: "Unknown",
		LevelSection.ROOT: "Root",
		LevelSection.MAP: "Map",
		LevelSection.OBJECTS: "Objects",
		LevelSection.MARKERS: "Markers",
	}[ls]
