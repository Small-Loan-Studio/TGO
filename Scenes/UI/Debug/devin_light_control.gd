class_name DevinLightControl
extends HBoxContainer

var _devin: Devin
var _light: Torch

@onready var _toggle_btn: Button = $ToggleLight


func setup(devin: Devin, torch: Torch) -> void:
	_devin = devin
	_light = torch
	if !_light.is_lit():
		_toggle_btn.text = "Off"


func _on_toggle_light() -> void:
	if _light.is_lit():
		_light.toggle(false)
		_toggle_btn.text = "Off"
	else:
		_light.toggle(true)
		_toggle_btn.text = "On"
