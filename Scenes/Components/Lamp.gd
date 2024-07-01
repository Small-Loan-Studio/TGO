class_name Lamp

extends Node2D

# this exists because i drew the stub lighting pattern to the left and couldn't
# be assed to rotate it to Vector2.UP so we have to factor in an addition +90deg
# to get the angle we actually want for it
const BASE_OFFSET = PI/2

@onready var _light: PointLight2D = $Beam

func face(rotation_rad: float) -> void:
	_light.rotation = rotation_rad + BASE_OFFSET

func _process(_delta: float) -> void:
	if rotation != 0:
		printerr('Unexpected Lamp rotation set, redirecting to beam')
		face(rotation)
		rotation = 0