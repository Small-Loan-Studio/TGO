@tool

class_name Torch
extends Node2D

@export_category("Lighting")
@export var light_color: Color = Color.WHITE:
	get:
		return light_color
	set(value):
		light_color = value
		_change_light_color(light_color)
@export var light_energy: float = 1.0:
	get:
		return light_energy
	set(value):
		light_energy = value
		_change_light_energy(light_energy)
@export var light_size: float = 0.75:
	get:
		return light_size
	set(value):
		light_size = value
		_change_light_size(light_size)

@onready var _pointLight2D: PointLight2D = $PointLight2D


func _toggle() -> void:
	_pointLight2D.visible = !_pointLight2D.visible
	print(_pointLight2D.visible)

func _change_light_color(new_color: Color) -> void:
	if _pointLight2D != null:
		_pointLight2D.color = new_color

func _change_light_energy(new_energy: float) -> void:
	if _pointLight2D != null:
		_pointLight2D.energy = new_energy

func _change_light_size(new_size: float) -> void:
	if _pointLight2D != null:
		_pointLight2D.texture_scale = new_size

