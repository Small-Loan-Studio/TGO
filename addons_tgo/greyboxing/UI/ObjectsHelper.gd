@tool

class_name ObjectsHelper
extends Control

const GREYBOX_OBJECT_SCENE = "res://Scenes/Components/Greyboxing/GreyboxObject.tscn"
const PUSHABLE_OBJECT_SCENE = "res://Scenes/Components/Greyboxing/MoveableBlock.tscn"
const NPC_OBJECT_SCENE = "res://Scenes/Components/NPC.tscn"
const ITEM_OBJECT_SCENE = "res://Scenes/Components/Inventory/Item.tscn"
const GENERIC_KEY = "generic"
const PUSHABLE_KEY = "pushable"
const NPC_KEY = "npc"
const ITEM_KEY = "item"
const SWITCH_KEY = "switch"
const CHARACTERS_CHILD_NODE = "Characters"
const ITEMS_CHILD_NODE = "Items"
const NPC_PATH = "res://Scripts/Resources/NPCs"
const ITEM_PATH = "res://Scripts/Resources/Items"
const BUTTON_IDX = 0
const DETAIL_IDX = 1
const RESET_IDX = 2
const BUTTON_TEXT_PLACE = "Place"
const BUTTON_TEXT_PLACING = "Placing object..."

var _plugin_ref: EditorPlugin

## Stores a collection of data for each helper.
##   Map[String, [Control, Control, Callable]].
##
## Key: object type id
## Value[0]: The button that activates an object detail config
## Value[1]: A container with any configuration necessary for the object config
## Value[2]: Callable that resets the configuration back to a default state
var _object_types: Dictionary = {}

## Stores the object parent, i.e., LevelBase.Objects
var _objects_parent: Node = null

## Details which object type we're currently configuring, will be one of _valid_keys
var _focused_object_type: String = ""

## what kind of objects we can configure
var _valid_keys: Array[String] = []

## character: String -> NPCConfig
var _npc_dict: Dictionary = {}

## timeline name: String -> String (path to DialogicTimeline)
var _npc_timeline_dict: Dictionary = {}

## item: String -> Item
var _item_dict: Dictionary = {}

## Check to see if an object is ready to be placed in the scene
var _is_object_ready_to_place: bool = false

#gdlint: disable=max-line-length
@onready var _generic := $Container/Scroll/AddItems/Generic
@onready var _generic_detail := $Container/Scroll/AddItems/GenericDetails
@onready var _generic_name: LineEdit = $Container/Scroll/AddItems/GenericDetails/HBox/Margin/Name
@onready var _generic_size: XbyY = $Container/Scroll/AddItems/GenericDetails/Size
@onready
var _generic_block_movement: CheckBox = $Container/Scroll/AddItems/GenericDetails/BlockMovement
@onready var _generic_occludes: CheckBox = $Container/Scroll/AddItems/GenericDetails/Occludes
@onready var _generic_interacts: CheckBox = $Container/Scroll/AddItems/GenericDetails/Interactable
@onready var _generic_interacts_desc := %InteractableDesc
@onready var _generic_tint: ColorPickerButton = %GreyboxTint

@onready var _pushable := $Container/Scroll/AddItems/Pushable
@onready var _pushable_detail := $Container/Scroll/AddItems/PushableDetails
@onready var _pushable_name: LineEdit = $Container/Scroll/AddItems/PushableDetails/HBox/Margin/Name
@onready var _pushable_size: XbyY = %PushableSize

@onready var _npc := $Container/Scroll/AddItems/NPC
@onready var _npc_detail := $Container/Scroll/AddItems/NPCDetails
@onready var _npc_dropdown := %NPCDropdown
@onready var _npc_dlg_path: LineEdit = %NPCDialoguePath
@onready var _npc_dlg_dropdown := %NPCDlgDropdown

@onready var _item := $Container/Scroll/AddItems/Item
@onready var _item_detail := $Container/Scroll/AddItems/ItemDetails
@onready var _item_dropdown := %ItemDropdown
@onready var _item_tex: TextureRect = %ItemIcon
@onready var _item_spinbox := %ItemSpinBox

@onready var _switch := $Container/Scroll/AddItems/Switch
@onready var _switch_detail: ObjectsHelperSwitchDetails = $Container/Scroll/AddItems/SwitchDetails

@onready var _complete_buttons := $Container/CompleteButtons
@onready var _place_button := $Container/CompleteButtons/Place
#gdlint: enable=max-line-length


func _ready() -> void:
	_object_types = {
		GENERIC_KEY: [_generic, _generic_detail, _reset_generic_state],
		PUSHABLE_KEY: [_pushable, _pushable_detail, _reset_pushable_state],
		NPC_KEY: [_npc, _npc_detail, _reset_npc_state],
		ITEM_KEY: [_item, _item_detail, _reset_item_state],
		SWITCH_KEY: [_switch, _switch_detail, _switch_detail.reset],
	}
	for k: String in _object_types.keys():
		_valid_keys.append(k)

	_reset()


func _input(event: InputEvent) -> void:
	# Handles mouse clicks, left click for placing an object, right click to cancel
	if _is_object_ready_to_place:
		if (
			event is InputEventMouseButton
			and event.button_index == MOUSE_BUTTON_RIGHT
			and event.pressed
		):
			_reset()
		if (
			event is InputEventMouseButton
			and event.button_index == MOUSE_BUTTON_LEFT
			and event.pressed
		):
			_apply_implementation(EditorInterface.get_editor_viewport_2d().get_mouse_position())


## Called after _ready to provide any necessary external objects.
## - plugin is a reference to the outtermost plugin host
## - parent_node is the first-level Levelbase node that will contain any
##   constructed objects
func setup(plugin: EditorPlugin, parent_node: Node) -> void:
	_objects_parent = parent_node
	_plugin_ref = plugin


func _reset() -> void:
	_place_button.text = BUTTON_TEXT_PLACE
	_is_object_ready_to_place = false
	_focused_object_type = ""
	for k: String in _object_types.keys():
		var main: Control = _object_types[k][BUTTON_IDX]
		var detail: Control = _object_types[k][DETAIL_IDX]
		var reset: Callable = _object_types[k][RESET_IDX]
		main.show()
		detail.hide()
		reset.call()
	_complete_buttons.hide()


## Hides object type selection buttons and focuses on the configuration details
## for the object type referenced via name.
func _select_object_type(type_name: String) -> void:
	_reset()
	if !(type_name in _valid_keys):
		assert(false, "Invalid object type key provided: %s vs %s" % [type_name, _valid_keys])

	_focused_object_type = type_name
	var detail: Control = _object_types[type_name][DETAIL_IDX]
	detail.show()
	_complete_buttons.show()
	for k: String in _object_types.keys():
		if k != type_name:
			_object_types[k][BUTTON_IDX].hide()
			_object_types[k][DETAIL_IDX].hide()


## Toggles the ability to place an object in the scene. Called when place
## button in ObjectsHelper scene is pressed.
func _apply() -> void:
	_is_object_ready_to_place = true
	_place_button.text = BUTTON_TEXT_PLACING


## Apply whatever type + configuration is in process
func _apply_implementation(obj_position: Vector2) -> void:
	match _focused_object_type:
		GENERIC_KEY:
			_apply_generic(obj_position)
		PUSHABLE_KEY:
			_apply_pushable(obj_position)
		NPC_KEY:
			_apply_npc(obj_position)
		ITEM_KEY:
			_apply_item(obj_position)
		SWITCH_KEY:
			_apply_switch(obj_position)
		_:
			assert(false, "Invalid focused object Type: " + _focused_object_type)
	var prev := _focused_object_type

	_reset()
	_select_object_type(prev)


## When adding a child node examine existing children and find a unique
## name based in in_str
func _mk_name_unique(parent: Node, in_str: String) -> String:
	if !parent.has_node(in_str):
		return in_str

	var i := 2
	while parent.has_node("%s_%d" % [in_str, i]):
		i = i + 1

	return "%s_%d" % [in_str, i]


## Create a generic greybox and add it to the scene
func _apply_generic(obj_position: Vector2) -> void:
	var obj_name := _generic_name.text.strip_edges()
	if obj_name == "":
		obj_name = "GreyboxObj"
	var new_obj_name := _mk_name_unique(_objects_parent, obj_name)
	var collides := _generic_block_movement.button_pressed
	var occludes := _generic_occludes.button_pressed
	var interacts := _generic_interacts.button_pressed

	var obj: GreyboxObject = preload(GREYBOX_OBJECT_SCENE).instantiate()
	obj.name = new_obj_name
	_objects_parent.add_child(obj)
	# the owner of the new greybox object is the level (Object's parent's parent)
	obj.owner = _objects_parent.get_parent()
	obj.can_block_movement = collides
	obj.can_block_light = occludes
	obj.can_interact = interacts
	obj.global_position = obj_position
	obj.size = _generic_size.get_xy()
	obj.tint = _generic_tint.color


func _reset_generic_state() -> void:
	_generic_name.text = _generic_name.placeholder_text
	_generic_block_movement.button_pressed = false
	_generic_occludes.button_pressed = false
	_generic_interacts.button_pressed = false
	_generic_tint.color = Color.GRAY


func _apply_pushable(obj_position: Vector2) -> void:
	var obj_name := _pushable_name.text
	if obj_name == "":
		obj_name = "PushableBlock"
	obj_name = _mk_name_unique(_objects_parent, obj_name)

	var obj: MoveableBlock = preload(PUSHABLE_OBJECT_SCENE).instantiate()
	obj.name = obj_name
	_objects_parent.add_child(obj)
	obj.owner = _objects_parent.get_parent()
	var xy := _pushable_size.get_xy()
	obj.width = xy.x
	obj.height = xy.y
	obj.global_position = obj_position


func _reset_pushable_state() -> void:
	_pushable_name.text = _pushable_name.placeholder_text
	_pushable_size.reset()


func _apply_npc(obj_position: Vector2) -> void:
	var npc_name: String = _npc_dropdown.get_item_text(_npc_dropdown.get_selected_id())
	var config: NPCConfig = _npc_dict[npc_name]

	var new_npc := preload(NPC_OBJECT_SCENE).instantiate()
	new_npc.config = config

	# This is fragile, messy, and runs counter one of my gdscript principles...
	# And so while I'd rather not do it I also don't want to restructure the
	# whole of the plugin setup bullshit so here we are.
	var parent := _objects_parent.get_node(CHARACTERS_CHILD_NODE)
	new_npc.name = _mk_name_unique(parent, npc_name)
	var timeline := _npc_get_timeline()
	if timeline != null:
		var dlg := DialogueEffect.new()
		dlg.timeline = timeline
		new_npc.dlg = dlg

	parent.add_child(new_npc)
	new_npc.owner = _objects_parent.get_parent()
	new_npc.global_position = obj_position


func _apply_switch(obj_position: Vector2) -> void:
	var parent := _objects_parent.get_node("Switches")

	var obj := _switch_detail.build()
	var obj_name := _switch_detail.switch_name.text
	if obj_name == "":
		obj_name = "Switch"
	obj.name = _mk_name_unique(parent, obj_name)

	parent.add_child(obj)
	obj.owner = _objects_parent.get_parent()
	obj.global_position = obj_position


func _reset_npc_state() -> void:
	_npc_dlg_path.text = ""
	_npc_dlg_dropdown.selected = 0


## returns a timeline from the selected path or null of element 0 is selected.
## N.B. Entry 0 is, by convention, "None" in the event we want to have a
## custom timeline that doesn't come from the "valid timeline" set in the
## NPCConfig.
func _npc_get_timeline() -> DialogicTimeline:
	var dlg_index: int = _npc_dlg_dropdown.get_selected_id()
	if dlg_index == 0:
		return null
	var key: String = _npc_dlg_dropdown.get_item_text(dlg_index)
	return _npc_timeline_dict[key]


# is called when the detail visibility is chahnged; when made visible
# we reload the viable NPC configs and populate the template dropdown
func _npc_detail_visibility_changed() -> void:
	if _npc_detail == null:
		return

	_npc_dropdown.clear()
	_npc_dict.clear()
	if !_npc_detail.visible:
		return

	var dir := DirAccess.open(NPC_PATH)
	if dir == null:
		printerr("Failed to open npc resource path:", DirAccess.get_open_error())
		return

	dir.list_dir_begin()
	var npc_file := dir.get_next()
	# walks the NPC resource path and gets the configured resources
	# TODO: doesn't traverse subdirs
	while npc_file != "":
		if npc_file.ends_with(".tres"):
			var config := ResourceLoader.load(NPC_PATH + "/" + npc_file) as NPCConfig
			if config != null:
				var key := config.character_id
				_npc_dict[key] = config
				_npc_dropdown.add_item(key)
		npc_file = dir.get_next()
	_npc_dlg_refresh()


func _npc_config_selected(_index: int) -> void:
	_npc_dlg_refresh()


## Populate the dialog selection dropdown based on the currently selected NPC
## template. Will always include an element-0 "None/Custom" entry if you don't
## want to use the blessed timelines for some reason.
func _npc_dlg_refresh() -> void:
	# clear existing state
	_npc_dlg_dropdown.clear()
	_npc_timeline_dict.clear()

	# get current id
	var index: int = _npc_dropdown.get_selected_id()
	if index == -1:
		return

	# get config
	var config: NPCConfig = _npc_dict[_npc_dropdown.get_item_text(index)]

	# populate with DTL options
	_npc_dlg_dropdown.add_item("None / Custom")
	for dtl_path in config.valid_timelines:
		if dtl_path.ends_with(".dtl"):
			var dtl := load(dtl_path)
			if dtl is DialogicTimeline:
				var key := dtl.resource_path.split("/").slice(-1)[0]
				key = key.substr(0, key.length() - 4)
				_npc_timeline_dict[key] = dtl
				_npc_dlg_dropdown.add_item(key)


func _apply_item(obj_position: Vector2) -> void:
	var item_name: String = _item_dropdown.get_item_text(_item_dropdown.get_selected_id())
	var config: Item = _item_dict[item_name]

	var new_item := preload(ITEM_OBJECT_SCENE).instantiate()
	new_item.item = config
	new_item.quantity = _item_spinbox.value

	# This is fragile, messy, and runs counter one of my gdscript principles...
	# And so while I'd rather not do it I also don't want to restructure the
	# whole of the plugin setup bullshit so here we are.
	var parent := _objects_parent.get_node(ITEMS_CHILD_NODE)
	new_item.name = _mk_name_unique(parent, item_name)

	parent.add_child(new_item)
	new_item.owner = _objects_parent.get_parent()
	new_item.global_position = obj_position


func _reset_item_state() -> void:
	_item_dropdown.selected = 0


# is called when the detail visibility is changed; when made visible
# we reload the viable Item configs and populate the template dropdown
func _item_detail_visibility_changed() -> void:
	if _item_detail == null:
		return

	_item_dropdown.clear()
	_item_dict.clear()
	if !_item_detail.visible:
		return

	var dir := DirAccess.open(ITEM_PATH)
	if dir == null:
		printerr("Failed to open item resource path:", DirAccess.get_open_error())
		return

	dir.list_dir_begin()
	var item_file := dir.get_next()
	# walks the Item resource path and gets the configured resources
	# TODO: doesn't traverse subdirs
	while item_file != "":
		if item_file.ends_with(".tres"):
			var config := ResourceLoader.load(ITEM_PATH + "/" + item_file) as Item
			if config != null:
				var key := config.id
				_item_dict[key] = config
				if _item_dropdown:
					_item_dropdown.add_item(key)
		item_file = dir.get_next()

	_item_dropdown_selected(-1)


func _item_dropdown_selected(_unused: int) -> void:
	var index: int = _item_dropdown.get_selected_id()
	if index == -1:
		_item_tex.hide()
		return

	var key: String = _item_dropdown.get_item_text(index)
	var detail: Item = _item_dict[key]
	_item_tex.texture = detail.icon
	_item_tex.show()


func _on_generic_interactable_toggled(toggled_on: bool) -> void:
	_generic_interacts_desc.visible = toggled_on
