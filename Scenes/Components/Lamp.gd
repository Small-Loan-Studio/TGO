class_name Lamp
extends Node2D

# this exists because i drew the stub lighting pattern to the left and couldn't
# be assed to rotate it to Vector2.UP so we have to factor in an addition +90deg
# to get the angle we actually want for it
const BASE_OFFSET = PI/2

var light_level: Enums.LightLevel:
	set(ll):
		match ll:
			Enums.LightLevel.OFF:
				_replace_beam(null)
			Enums.LightLevel.NORMAL:
				_replace_beam(_beam1)
			Enums.LightLevel.BRIGHT:
				_replace_beam(_beam2)
			Enums.LightLevel.SPECIAL:
				_replace_beam(_beam3)
			_:
				printerr("Unknown light level: ", str(ll))
				_replace_beam(null)
				ll = Enums.LightLevel.OFF
		light_level = ll
	get:
		return light_level

@onready var _beam1: PointLight2D = $Beam
@onready var _beam2: PointLight2D = $Beam2
@onready var _beam3: PointLight2D = $Beam3

var _light: PointLight2D
var _facing: float

func _replace_beam(new_light: PointLight2D) -> void:
		if _light != null:
			_light.visible = false
		_light = new_light
		if _light != null:
			_light.visible = true

func face(rotation_rad: float) -> void:
	_facing = rotation_rad + BASE_OFFSET

func _process(_delta: float) -> void:
	if rotation != 0:
		printerr('Unexpected Lamp rotation set, redirecting to beam')
		face(rotation)
		rotation = 0
	if _light != null:
		_light.rotation = _facing
