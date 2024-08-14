@tool
class_name TGOControlDock
extends Control

var _plugin_ref: TGOGreyboxingToolsPlugin = null
var _selection: EditorSelection = null:
	get:
		return EditorInterface.get_selection()


@onready var _selection_label: Label = %SelectedLabel
@onready var _detail := %SectionDetails

func setup(plugin_ref: TGOGreyboxingToolsPlugin) -> void:
	_plugin_ref = plugin_ref
	var selection := EditorInterface.get_selection()
	selection.selection_changed.connect(_update_selection)
	_update_selection()


func _reload() -> void:
	_plugin_ref.reload()


func _update_selection() -> void:
	var root := EditorInterface.get_edited_scene_root()
	if !(root is LevelBase):
		_selection_label.text = "Plugin only works active while editing LevelBase"
		_update_section_control(LevelSection.UNKNOWN)
		return

	var selected_node := _update_selection_label(_selection.get_selected_nodes())
	if selected_node == null:
		return

	var section := _get_section(selected_node, root)
	_update_section_control(section)


func _get_root(node: Node) -> Node:
	var parent := node.get_parent()
	if parent == null:
		return node
	return _get_root(parent)


func _update_selection_label(nodes: Array[Node]) -> Node:
	if nodes.size() == 0:
		_selection_label.text = "Editing: None"
		return null
	if nodes.size() > 1:
		_selection_label.text = "Editing: Multiple"
		return null
	_selection_label.text = "Editing: %s" % [nodes[0].name]
	return nodes[0]


func _get_section(selected: Node, root: Node) -> LevelSection:
	if selected == root:
		return LevelSection.ROOT

	while selected.get_parent() != root:
		selected = selected.get_parent()

	match selected.name:
		"TileMap":
			return LevelSection.MAP
		"Objects":
			return LevelSection.OBJECTS
		"Markers":
			return LevelSection.MARKERS

	return LevelSection.UNKNOWN


var _c: ObjectsHelper = null

func _update_section_control(section: LevelSection) -> void:
	if _c != null:
		_detail.remove_child(_c)
		_c.queue_free()
	if section == LevelSection.OBJECTS:
		_c = (ResourceLoader.load("res://addons/tgo_greyboxing/UI/ObjectsHelper.tscn") as PackedScene).instantiate()
		_detail.add_child(_c)

enum LevelSection {
	UNKNOWN,
	ROOT,
	MAP,
	OBJECTS,
	MARKERS,
}

func _level_section_str(ls: LevelSection) -> String:
	return {
		LevelSection.UNKNOWN: "Unknown",
		LevelSection.ROOT: "Root",
		LevelSection.MAP: "Map",
		LevelSection.OBJECTS: "Objects",
		LevelSection.MARKERS: "Markers",
	}[ls]