class_name Lamp
extends Node2D

# this exists because i drew the stub lighting pattern to the left and couldn't
# be assed to rotate it to Vector2.UP so we have to factor in an addition +90deg
# to get the angle we actually want for it
const BASE_OFFSET = PI/2

var light_level: Enums.LightLevel: set = _set_light_level, get = _get_light_level
var energy: float

var _light: PointLight2D
var _detector: Area2D
var _facing: float

@onready var _beam1: PointLight2D = $Beam

@onready var _beam2: PointLight2D = $Beam2
@onready var _beam2_detector: Area2D = $Beam2/Area2D

@onready var _beam3: PointLight2D = $Beam3
@onready var _beam3_detector: Area2D = $Beam3/Area2D

func _set_light_level(ll: Enums.LightLevel) -> void:
	match ll:
		Enums.LightLevel.OFF:
			_replace_lamp(null, null)
		Enums.LightLevel.NORMAL:
			_replace_lamp(_beam1, null)
		Enums.LightLevel.BRIGHT:
			_replace_lamp(_beam2, _beam2_detector)
		Enums.LightLevel.SPECIAL:
			_replace_lamp(_beam3, _beam3_detector)
		_:
			printerr("Unknown light level: ", str(ll))
			_replace_lamp(null, null)
			ll = Enums.LightLevel.OFF
	light_level = ll

func _get_light_level() -> Enums.LightLevel:
	return light_level

func _replace_lamp(new_light: PointLight2D, new_detector: Area2D) -> void:
		if _light != null:
			_light.enabled = false
		if _detector != null:
			_detector.monitoring = false

		_light = new_light
		_detector = new_detector

		if _light != null:
			_light.enabled = true
			_light.energy = energy
		if _detector != null:
			_detector.monitoring = true

func face(rotation_rad: float) -> void:
	_facing = rotation_rad + BASE_OFFSET

func _process(_delta: float) -> void:
	if rotation != 0:
		printerr('Unexpected Lamp rotation set, redirecting to beam')
		face(rotation)
		rotation = 0
	if _light != null:
		_light.rotation = _facing
		_light.energy = energy

func _on_lamp2_exit(area:Area2D) -> void:
	# print('_on_lamp2_exit - ' + area.name + ' / ' + area.get_parent().name)
	area.set_detected(false)

func _on_lamp2_enter(area:Area2D) -> void:
	# print('_on_lamp2_enter - ' + area.name + ' / ' + area.get_parent().name)
	area.set_detected(true)

func _on_lamp3_exited(area:Area2D) -> void:
	# print('_on_lamp3_exit - ' + area.name + ' / ' + area.get_parent().name)
	area.set_detected(false)

func _on_lamp3_entered(area:Area2D) -> void:
	# print('_on_lamp3_enter - ' + area.name + ' / ' + area.get_parent().name)
	area.set_detected(true)