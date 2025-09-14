@tool
class_name ControllerBase
extends Node


func process_input(_event: InputEvent) -> void:
	pass


func get_vector() -> Vector2:
	printerr("Using unimplemented code from base class")
	return Vector2.ZERO


func get_just_pressed() -> Array[Enums.InputAction]:
	printerr("Using unimplemented code from base class")
	return []


func get_button_pressed() -> Array[Enums.InputAction]:
	printerr("Using unimplemented code from base class")
	return []


func get_just_released() -> Array[Enums.InputAction]:
	printerr("Using unimplemented code from base class")
	return []


func get_button_released() -> Array[Enums.InputAction]:
	printerr("Using unimplemented code from base class")
	return []


func just_pressed(action: Enums.InputAction) -> bool:
	return Input.is_action_just_pressed(Enums.input_action_name(action))
	# return action in get_just_pressed()


func just_released(action: Enums.InputAction) -> bool:
	return Input.is_action_just_released(Enums.input_action_name(action))
	# return action in get_just_released()