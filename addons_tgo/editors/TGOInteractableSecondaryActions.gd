@tool
class_name TGOInteractableSecondaryActions
extends Control

@onready var _margin_container := $MarginContainer
@onready var _add_entry_btn := %AddEntry

var _data: Interactable


func _ready() -> void:
	custom_minimum_size.y = _margin_container.size.y


func setup(obj: Interactable) -> void:
	_data = obj


func _on_add_entry_pressed() -> void:
	print("_on_add_entry_pressed")