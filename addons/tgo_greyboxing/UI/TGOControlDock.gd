@tool
class_name TGOControlDock
extends Control

const OBJECTS_HELPER_SCENE := "res://addons/tgo_greyboxing/UI/ObjectsHelper.tscn"

var _plugin_ref: TGOGreyboxingToolsPlugin = null

var _selection: EditorSelection = null:
	get:
		return EditorInterface.get_selection()

var _subsection_control: Control = null

@onready var _selection_label: Label = %SelectedLabel
@onready var _detail := %SectionDetails

var _active_section: Node = null:
	get:
		return _active_section
	set(value):
		print('_active_section: %s' % [value.name])
		_active_section = value

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

	# ensure we're only dealing with a single selected node
	var selected_node := _get_node(_selection.get_selected_nodes())
	if selected_node == null:
		_update_section_control(LevelSection.UNKNOWN)
		return

	var section := _get_section(selected_node, root)
	_active_section = _get_section_node(selected_node, root, section)
	_update_section_control(section)


func _get_node(nodes: Array[Node]) -> Node:
	if nodes.size() == 0:
		_selection_label.text = "Editing: None"
		return null
	if nodes.size() > 1:
		_selection_label.text = "Editing: Multiple"
		return null
	_selection_label.text = "Editing: %s" % [nodes[0].name]
	return nodes[0]


func _get_section_node(selected: Node, root: Node, typ: LevelSection) -> Node:
	if typ == LevelSection.UNKNOWN:
		return null

	if typ == LevelSection.ROOT:
		return root

	while selected != root:
		if typ == LevelSection.MAP && selected.name == "TileMap":
			return selected
		if typ == LevelSection.OBJECTS && selected.name == "Objects":
			return selected
		if typ == LevelSection.MARKERS && selected.name == "Markers":
			return selected

		selected = selected.get_parent()

	return null

func _get_section(selected: Node, root: LevelBase) -> LevelSection:
	if selected == root:
		return LevelSection.ROOT

	while selected != root:
		match selected.name:
			"TileMap":
				return LevelSection.MAP
			"Objects":
				return LevelSection.OBJECTS
			"Markers":
				return LevelSection.MARKERS
		selected = selected.get_parent()

	return LevelSection.UNKNOWN

func _update_section_control(section: LevelSection) -> void:
	if _subsection_control != null:
		_detail.remove_child(_subsection_control)
		_subsection_control.queue_free()
		_subsection_control = null

	if section == LevelSection.OBJECTS:
		var oh: ObjectsHelper = (ResourceLoader.load(OBJECTS_HELPER_SCENE) as PackedScene).instantiate()
		oh.setup(_active_section)
		_subsection_control = oh
		_detail.add_child(_subsection_control)

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