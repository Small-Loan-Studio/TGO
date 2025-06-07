class_name HUD
extends Control

@onready var _autoload := $DebugStack/SaveLoadMenu/AutoloadButton
@onready var _toast := %Toast
@onready var _toast_label: Label = %Toast/ToastLabel


func _ready() -> void:
	if SerializationManager.is_autoload():
		_autoload.set_pressed_no_signal(true)


func set_toast(val: String) -> void:
	_toast_label.text = val
	_toast.show()


func clear_toast() -> void:
	_toast_label.text = ""
	_toast.hide()
