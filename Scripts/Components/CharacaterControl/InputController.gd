class_name InputController
extends ControllerBase

const DIR_NEG_X := 0
const DIR_POS_X := 1
const DIR_NEG_Y := 2
const DIR_POS_Y := 3

const JUST_PRESSED = 0
const PRESSED = 1
const JUST_RELEASED = 2
const UNPRESSED = 3

var deadzone := .05

var _movement: Array[String]
var _actions: Array[String]

var _dir_vector: Vector2

var _action_state: Dictionary
var _always_unpressed: InputController.ActionState
var _input: InputWrapper

func _init(
	movement_actions: Array[Enums.InputAction],
	actions_to_watch: Array[Enums.InputAction],
	input_src: Variant = null,
) -> void:
	for ele in movement_actions:
		_movement.append(Enums.input_action_name(ele))
	for ele in actions_to_watch:
		_actions.append(Enums.input_action_name(ele))
	_always_unpressed = InputController.ActionState.new()

	_input = InputWrapper.new(input_src)

func _ready() -> void:
	pass


func _unhandled_input(event: InputEvent) -> void:
	process_input(event)
	


func process_input(_event: InputEvent) -> void:
	_dir_vector = _input.get_vector(
		_movement[DIR_NEG_X], _movement[DIR_POS_X], _movement[DIR_NEG_Y], _movement[DIR_POS_Y], deadzone)
	_dir_vector = _dir_vector.normalized()

	for action_name in _actions:
		if _input.is_action_pressed(action_name):
			_action_state[action].state = PRESSED
			if _input.is_action_just_pressed(action_name):
				_action_state[action].state = JUST_PRESSED
		elif _input.is_action_just_released(action_name):
			_action_state[action].state = JUST_RELEASED
		else:
			_action_state[action].state = UNPRESSED


func action(input: Enums.InputAction) -> InputController.ActionState:
	if _action_state.has(input):
		return _action_state[input]
	
	printerr("InputController doesn't know about %s" % [Enums.input_action_name(input)])
	return _always_unpressed


class ActionState:
	extends RefCounted

	var state: int

	func just_pressed() -> bool:
		return state == JUST_PRESSED

	func is_pressed() -> bool:
		return state == JUST_PRESSED || state == PRESSED
	
	func just_released() -> bool:
		return state == JUST_RELEASED

	func not_pressed() -> bool:
		return state == JUST_RELEASED || state == UNPRESSED

class InputWrapper:
	extends RefCounted

	var _override: Variant

	func _init(override: Variant) -> void:
		_override = override

	func get_vector(left: String, right: String, down: String, up: String, deadzone: float) -> Vector2:
		if _override != null:
			return _override.get_vector(left, right, down, up, deadzone)
		return Input.get_vector(left, right, down, up, deadzone)

	func is_action_pressed(str: String) -> bool:
		if _override != null:
			return _override.is_action_pressed(str)
		return Input.is_action_pressed(str)
	
	func is_action_just_pressed(str: String) -> bool:
		if _override != null:
			return _override.is_action_just_pressed(str)
		return Input.is_action_just_pressed(str)
	
	func is_action_just_released(str: String) -> bool:
		if _override != null:
			return _override.is_action_just_released(str)
		return Input.is_action_just_released(str)