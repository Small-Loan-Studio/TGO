@tool
class_name InteractableEffectLineItem
extends Control

signal do_sync(resource: Array[Effect])


@onready var _hbox := $HBoxContainer
@onready var _name_lbl: Label = $HBoxContainer/NameLabel

var _picker_control: EditorResourcePicker

var action_type: Enums.ActionVerb


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_name_lbl.text = Enums.action_verb_name(action_type).capitalize()
	
	## _picker_control = EditorResourcePicker.new()
	## _picker_control.
	

func _resource_updated(res: Resource) -> void:
	print(res)