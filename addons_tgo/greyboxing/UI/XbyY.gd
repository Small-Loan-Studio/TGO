@tool
class_name XbyY
extends HBoxContainer

@export var unit: String = ""
@export var min_value: int = 0
@export var max_value: int = 100
@export var initial_values := Vector2(1, 1)
@export var step: float = 1

@onready var _x_spinner: SpinBox = $Margin/SizeX
@onready var _y_spinner: SpinBox = $Margin3/SizeY

func _ready() -> void:
	_setup(_x_spinner)
	_setup(_y_spinner)
	reset()


func _setup(sp: SpinBox) -> void:
	sp.suffix = unit
	sp.min_value = min_value
	sp.max_value = max_value
	sp.step = step


func reset() -> void:
	_x_spinner.value = initial_values.x
	_y_spinner.value = initial_values.y


func get_xy() -> Vector2:
	return Vector2(_x_spinner.value, _y_spinner.value)