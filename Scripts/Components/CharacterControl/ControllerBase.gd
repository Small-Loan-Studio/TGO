@tool
class_name ControllerBase
extends Node


func process_input(_event: InputEvent) -> void:
	pass


func get_vector() -> Vector2:
	printerr("Using unimplemented code from base clase")
	return Vector2.ZERO


func get_just_pressed() -> Array[Enums.InputAction]:
	printerr("Using unimplemented code from base clase")
	return []


func get_button_pressed() -> Array[Enums.InputAction]:
	printerr("Using unimplemented code from base clase")
	return []


func get_just_released() -> Array[Enums.InputAction]:
	printerr("Using unimplemented code from base clase")
	return []


func get_button_released() -> Array[Enums.InputAction]:
	printerr("Using unimplemented code from base clase")
	return []


func just_pressed(action: Enums.InputAction) -> bool:
	return action in get_just_pressed()


func just_released(action: Enums.InputAction) -> bool:
	return action in get_just_released()
