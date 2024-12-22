class_name ControllerBase
extends Node

func process_input(_event: InputEvent) -> void:
	pass


func get_vector() -> Vector2:
	return Vector2.ZERO


func get_button_pressed() -> Array[Enums.InputAction]:
	return []


func get_button_released() -> Array[Enums.InputAction]:
	return []