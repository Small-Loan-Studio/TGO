@tool

class_name ObjectsHelper
extends Control


var _sections: Dictionary = {}
var _objects_parent: Node = null
var _focused_section: String = ""

@onready var _generic := $Container/AddItems/Generic
@onready var _generic_detail := $Container/AddItems/GenericDetails
@onready var _pushable := $Container/AddItems/Pushable
@onready var _pushable_detail := $Container/AddItems/PushableDetails
@onready var _npc := $Container/AddItems/NPC
@onready var _npc_detail := $Container/AddItems/NPCDetails

func _ready() -> void:
	_sections = {
		"generic": [_generic, _generic_detail],
		"pushable": [_pushable, _pushable_detail],
		"npc": [_npc, _npc_detail],
	}
	_reset()

func setup(parent_node: Node) -> void:
	_objects_parent = parent_node

func _reset() -> void:
	_focused_section = ""
	_objects_parent = null
	for k: String in _sections.keys():
		var main: Control = _sections[k][0]
		var detail: Control = _sections[k][1]
		main.show()
		detail.hide()

func _select_section(name: String) -> void:
	_reset()
	_focused_section = name
	var detail: Control = _sections[name][1]
	detail.show()
	for k in _sections.keys():
		if k != name:
			_sections[k][0].hide()
			_sections[k][1].hide()

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
	var cb_collides := _checkbox(_generic_detail, "BlockMovement")
	var collides := cb_collides.button_pressed
	cb_collides.button_pressed = false

	var cb_occludes := _checkbox(_generic_detail, "Occludes")
	var occludes := cb_occludes.button_pressed
	cb_occludes.button_pressed = false

	var cb_interacts := _checkbox(_generic_detail, "Interactable")
	var interacts := cb_interacts.button_pressed
	cb_interacts.button_pressed = false

	print(collides)
	print(occludes)
	print(interacts)

func _apply_pushable() -> void:
	pass


func _apply_npc() -> void:
	pass


func _checkbox(parent: Node, child: String) -> CheckBox:
	return (parent.get_node(child) as CheckBox)
	var obj := preload("res://Scenes/Components/Greyboxing/GreyboxObject.tscn").instantiate()
	obj.add_child(_objects_parent)
	# the parent of the new greybox object is the level (Object's parent's parent)
	obj.owner = _objects_parent.get_parent()