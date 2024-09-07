@tool

class_name ObjectsHelper
extends Control

const GREYBOX_OBJECT_SCENE = "res://Scenes/Components/Greyboxing/GreyboxObject.tscn"
const PUSHABLE_OBJECT_SCENE = "res://Scenes/Components/Greyboxing/MoveableBlock.tscn"
const GENERIC_KEY = "generic"
const PUSHABLE_KEY = "pushable"
const NPC_KEY = "npc"
const CHARACTERS_CHILD_NODE = "Characters"
const NPC_PATH = "res://Scenes/Components/NPC"
const BUTTON_IDX = 0
const DETAIL_IDX = 1
const RESET_IDX = 2

var _npc_dict: Dictionary = {}

var _plugin_ref: EditorPlugin
## Stores a collection of data for each helper section.
##   Map[String, [Control, Control, Callable]].
##
## Key: section id
## Value[0]: The button that activates a section
## Value[1]: A container with any configuration necessary for the section
## Value[2]: Callable that resets the configuration back to a default state
var _sections: Dictionary = {}
var _objects_parent: Node = null
var _focused_section: String = ""
var _valid_keys: Array[String] = []

@onready var _generic := $Container/AddItems/Generic
@onready var _generic_detail := $Container/AddItems/GenericDetails
@onready var _generic_name: LineEdit = $Container/AddItems/GenericDetails/HBox/Margin/Name
@onready var _generic_block_movement: CheckBox = $Container/AddItems/GenericDetails/BlockMovement
@onready var _generic_occludes: CheckBox = $Container/AddItems/GenericDetails/Occludes
@onready var _generic_interacts: CheckBox = $Container/AddItems/GenericDetails/Interactable

@onready var _pushable := $Container/AddItems/Pushable
@onready var _pushable_detail := $Container/AddItems/PushableDetails
@onready var _pushable_name: LineEdit = $Container/AddItems/PushableDetails/HBox/Margin/Name
@onready var _pushable_size_x: SpinBox = %PushableSizeX
@onready var _pushable_size_y: SpinBox = %PushableSizeY

@onready var _npc := $Container/AddItems/NPC
@onready var _npc_detail := $Container/AddItems/NPCDetails
@onready var _npc_dropdown := %NPCDropdown
@onready var _npc_dlg_path: LineEdit = %NPCDialoguePath

@onready var _complete_buttons := $Container/CompleteButtons


func _ready() -> void:
	_sections = {
		GENERIC_KEY: [_generic, _generic_detail, _reset_generic_state],
		PUSHABLE_KEY: [_pushable, _pushable_detail, _reset_pushable_state],
		NPC_KEY: [_npc, _npc_detail, _reset_npc_state],
	}
	for k: String in _sections.keys():
		_valid_keys.append(k)

	_reset()


## Called after _ready to provide any necessary external objects.
## - plugin is a reference to the outtermost plugin host
## - parent_node is the first-level Levelbase node that will contain any
##   constructed objects
func setup(plugin: EditorPlugin, parent_node: Node) -> void:
	_objects_parent = parent_node
	_plugin_ref = plugin


func _reset() -> void:
	_focused_section = ""
	for k: String in _sections.keys():
		var main: Control = _sections[k][BUTTON_IDX]
		var detail: Control = _sections[k][DETAIL_IDX]
		var reset: Callable = _sections[k][RESET_IDX]
		main.show()
		detail.hide()
		reset.call()
	_complete_buttons.hide()


## Hides section selection buttons and focuses on the configuration details for
## the section referenced via name.
func _select_section(section_name: String) -> void:
	_reset()
	if !(section_name in _valid_keys):
		assert(false, "Invalid section key provided: %s vs %s" % [section_name, _valid_keys])

	_focused_section = section_name
	var detail: Control = _sections[section_name][DETAIL_IDX]
	detail.show()
	_complete_buttons.show()
	for k: String in _sections.keys():
		if k != section_name:
			_sections[k][BUTTON_IDX].hide()
			_sections[k][DETAIL_IDX].hide()


## Apply whatever section + configuration is in process
func _apply() -> void:
	match _focused_section:
		GENERIC_KEY:
			_apply_generic()
		PUSHABLE_KEY:
			_apply_pushable()
		NPC_KEY:
			_apply_npc()
		_:
			assert(false, "Invalid focused section: " + _focused_section)
	var prev := _focused_section

	_reset()
	_select_section(prev)


## When adding a child node examine existing children and find a unique
## name based in in_str
func _mk_unique(parent: Node, in_str: String) -> String:
	if !parent.has_node(in_str):
		return in_str

	var i := 2
	while parent.has_node("%s_%d" % [in_str, i]):
		i = i + 1

	return "%s_%d" % [in_str, i]


## Create a generic greybox and add it to the scene
func _apply_generic() -> void:
	var obj_name := _generic_name.text.strip_edges()
	if obj_name == "":
		obj_name = "GreyboxObj"
	var new_obj_name := _mk_unique(_objects_parent, obj_name)
	var collides := _generic_block_movement.button_pressed
	var occludes := _generic_occludes.button_pressed
	var interacts := _generic_interacts.button_pressed

	var obj: GreyboxObject = preload(GREYBOX_OBJECT_SCENE).instantiate()
	obj.name = new_obj_name
	# var urm := _plugin_ref.get_undo_redo()
	# _objects_parent.add_child(obj)
	# urm.create_action(
	# 	"Add generic greybox object (%s, %s, %s)" % [collides, occludes, interacts],
	# 	0,
	# 	_objects_parent
	# )
	_objects_parent.add_child(obj)
	# the owner of the new greybox object is the level (Object's parent's parent)
	obj.owner = _objects_parent.get_parent()
	obj.can_block_movement = collides
	obj.can_block_light = occludes
	obj.can_interact = interacts


func _reset_generic_state() -> void:
	_generic_name.text = _generic_name.placeholder_text
	_generic_block_movement.button_pressed = false
	_generic_occludes.button_pressed = false
	_generic_interacts.button_pressed = false


func _apply_pushable() -> void:
	var obj_name := _pushable_name.text
	if obj_name == "":
		obj_name = "PushableBlock"
	obj_name = _mk_unique(_objects_parent, obj_name)

	var obj: MoveableBlock = preload(PUSHABLE_OBJECT_SCENE).instantiate()
	obj.name = obj_name
	_objects_parent.add_child(obj)
	obj.owner = _objects_parent.get_parent()
	obj.width = _pushable_size_x.value
	obj.height = _pushable_size_y.value


func _reset_pushable_state() -> void:
	_pushable_name.text = _pushable_name.placeholder_text
	_pushable_size_x.value = 1
	_pushable_size_y.value = 1


func _apply_npc() -> void:
	var name: String = _npc_dropdown.get_item_text(_npc_dropdown.get_selected_id())
	var path: String = _npc_dict[name]

	var scene := ResourceLoader.load(path) as PackedScene
	var obj := scene.instantiate() as NPC
	
	var parent := _objects_parent.get_node(CHARACTERS_CHILD_NODE)
	obj.name = _mk_unique(parent, name)
	parent.add_child(obj)
	obj.owner = _objects_parent.get_parent()	

func _reset_npc_state() -> void:
	_npc_dropdown.clear()
	_npc_dict.clear()
	_npc_dlg_path.text = ""


func _npc_get_target_dlg() -> DialogicTimeline:
	var path := _npc_dlg_path.text
	var resource := ResourceLoader.load(path)
	if !(resource is DialogicTimeline):
		return null
	return resource


func _npc_dialogue_text_changed(new_text:String) -> void:
	if !new_text.ends_with(".dtl"):
		_npc_dlg_path.add_theme_color_override("font_color", Color.RED)
		return

	if null == _npc_get_target_dlg():
		_npc_dlg_path.add_theme_color_override("font_color", Color.RED)
		return

	_npc_dlg_path.remove_theme_color_override("font_color")


func _npc_detail_visibility_changed() -> void:
	if _npc_detail == null:
		return
	
	if !_npc_detail.visible:
		_npc_dropdown.clear()
		_npc_dict.clear()
		return

	var dir := DirAccess.open(NPC_PATH)
	if dir == null:
		printerr("Failed to open npc resource path:")
		printerr(DirAccess.get_open_error())
		return
	
	dir.list_dir_begin()
	var npc_file := dir.get_next()
	while npc_file != "":
		if npc_file.ends_with(".tscn"):
			var key := npc_file.substr(0, npc_file.length() - 5)
			_npc_dict[key] = "%s/%s" % [NPC_PATH, npc_file]
			_npc_dropdown.add_item(key)
		npc_file = dir.get_next()
