extends Node2D

@onready var _marker: Node2D = $World/ScnA/StartMarker
@onready var _devin: Devin = $Devin


func _ready() -> void:
	_devin.visible = false
	_devin.global_position = _marker.global_position
	_devin.visible = true
	print(_marker.position)
	print(_marker.global_position)


func setup(_driver: Driver) -> void:
	pass