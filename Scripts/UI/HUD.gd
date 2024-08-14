class_name HUD
extends Control

@onready var _toast := %Toast
@onready var _toast_label: Label = %Toast/ToastLabel

func set_toast(val: String) -> void:
	_toast_label.text = val
	_toast.show()

func clear_toast() -> void:
	_toast_label.text = ""
	_toast.hide()