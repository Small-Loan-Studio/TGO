@tool

class_name ObjectsHelper
extends Control

const GREYBOX_OBJECT_SCENE = "res://Scenes/Components/Greyboxing/GreyboxObject.tscn"

var _sections: Dictionary = {}
var _objects_parent: Node = null
var _focused_section: String = ""

@onready var _generic := $Container/AddItems/Generic
@onready var _generic_detail := $Container/AddItems/GenericDetails
@onready var _pushable := $Container/AddItems/Pushable
@onready var _pushable_detail := $Container/AddItems/PushableDetails
@onready var _npc := $Container/AddItems/NPC
@onready var _npc_detail := $Container/AddItems/NPCDetails
@onready var _complete_buttons := $Container/CompleteButtons

func _ready() -> void:
	_sections = {
		"generic": [_generic, _generic_detail, Callable(self, '_reset_generic_state')],
		"pushable": [_pushable, _pushable_detail, Callable(self, '_reset_pushable_state')],
		"npc": [_npc, _npc_detail, Callable(self, '_reset_npc_state')],
	}
	_reset()

func setup(parent_node: Node) -> void:
	_objects_parent = parent_node

func _reset() -> void:
	_focused_section = ""
	for k: String in _sections.keys():
		var main: Control = _sections[k][0]
		var detail: Control = _sections[k][1]
		var reset: Callable = _sections[k][2]
		main.show()
		detail.hide()
		reset.call()
	_complete_buttons.hide()

func _select_section(name: String) -> void:
	_reset()
	_focused_section = name
	var detail: Control = _sections[name][1]
	detail.show()
	for k in _sections.keys():
		if k != name:
			_sections[k][0].hide()
			_sections[k][1].hide()

	if name == "generic":
		_complete_buttons.show()

func _apply() -> void:
	match _focused_section:
		"generic":
			_apply_generic()
		"pushable":
			_apply_pushable()
		"npc":
			_apply_npc()

	_reset()


func _apply_generic() -> void:
	var le: LineEdit = _generic_detail.get_node("HBoxContainer/MarginContainer/NameEdit")
	var name := le.text
	var collides := _checkbox(_generic_detail, "BlockMovement").button_pressed
	var occludes := _checkbox(_generic_detail, "Occludes").button_pressed
	var interacts := _checkbox(_generic_detail, "Interactable").button_pressed

	var obj: GreyboxObject = preload(GREYBOX_OBJECT_SCENE).instantiate()
	obj.name = name
	_objects_parent.add_child(obj)
	# the owner of the new greybox object is the level (Object's parent's parent)
	obj.owner = _objects_parent.get_parent()
	obj.owner = EditorInterface.get_edited_scene_root()
	obj.can_block_movement = collides
	obj.can_block_light = occludes
	obj.can_interact = interacts


func _apply_pushable() -> void:
	pass


func _apply_npc() -> void:
	pass


func _reset_generic_state() -> void:
	var le: LineEdit = _generic_detail.get_node("HBoxContainer/MarginContainer/NameEdit")
	le.text = le.placeholder_text

	var cb_collides := _checkbox(_generic_detail, "BlockMovement")
	cb_collides.button_pressed = false

	var cb_occludes := _checkbox(_generic_detail, "Occludes")
	cb_occludes.button_pressed = false

	var cb_interacts := _checkbox(_generic_detail, "Interactable")
	cb_interacts.button_pressed = false

func _reset_pushable_state() -> void:
	pass

func _reset_npc_state() -> void:
	pass


func _checkbox(parent: Node, child: String) -> CheckBox:
	return (parent.get_node(child) as CheckBox)