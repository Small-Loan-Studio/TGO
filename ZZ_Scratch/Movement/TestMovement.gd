extends Node2D

var _state: int = 0

@onready var _modulate: CanvasModulate = $CanvasModulate
@onready var _light_level_label: Label = $CanvasLayer/Label2


func _ready() -> void:
	if !_modulate.visible:
		_modulate.visible = true


func setup(_driver: Driver) -> void:
	pass


func get_target(state: int) -> Color:
	match state:
		0:
			return Color(.08, .08, .16)
		1:
			return Color(.5, .5, .5)
		2:
			return Color.WHITE
	return Color(.5, .5, .5)


func get_energy_target(state: int) -> float:
	match state:
		0:
			return .9
		1:
			return .5
		2:
			return 0
	return .5
