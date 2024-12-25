@tool
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

@export var deadzone := .05

## A list of inputs that map to movement controls
var _movement: Array[String]
## A list of monitored input actions
var _actions: Array[String]

var _dir_vector: Vector2

var _setup: bool = false
# Map[String, ActionState]
var _action_state: Dictionary
var _always_unpressed: InputController.ActionState
var _input: InputWrapper

func setup(
	movement_actions: Array,
	actions_to_watch: Array,
	input_src: Variant = null,
) -> void:
	for ele: Enums.InputAction in movement_actions:
		_movement.append(Enums.input_action_name(ele))
	for ele: Enums.InputAction in actions_to_watch:
		var name := Enums.input_action_name(ele)
		_actions.append(name)
		_action_state[name] = InputController.ActionState.new()
		_action_state[name].action = ele
	_always_unpressed = InputController.ActionState.new()

	_input = InputWrapper.new(input_src)

	_setup = true

func _ready() -> void:
	pass


func _unhandled_input(event: InputEvent) -> void:
	if !_setup:
		return

	process_input(event)



func process_input(_event: InputEvent) -> void:
	if !_setup:
		return

	_dir_vector = _input.get_vector(
		_movement[DIR_NEG_X], _movement[DIR_POS_X], _movement[DIR_NEG_Y], _movement[DIR_POS_Y], deadzone)
	_dir_vector = _dir_vector.normalized()

	if _dir_vector.length() < deadzone:
		_dir_vector = Vector2.ZERO

	for action_name: String in _action_state:
		if _input.is_action_pressed(action_name):
			_action_state.get(action_name).state = PRESSED
			if _input.is_action_just_pressed(action_name):
				_action_state.get(action_name).state = JUST_PRESSED
		elif _input.is_action_just_released(action_name):
			_action_state.get(action_name).state = JUST_RELEASED
		else:
			_action_state.get(action_name).state = UNPRESSED


func action(input: Enums.InputAction) -> InputController.ActionState:
	var name := Enums.input_action_name(input)
	if _action_state.has(name):
		return _action_state.get(name)

	printerr("InputController doesn't know about %s" % [Enums.input_action_name(input)])
	return _always_unpressed


func get_vector() -> Vector2:
	return _dir_vector


func get_just_pressed() -> Array[Enums.InputAction]:
	var r: Array[Enums.InputAction] = []
	for action_name in _actions:
		var state: ActionState = _action_state[action_name]
		if state.just_pressed():
			r.append(state.action)
	return r


func get_button_pressed() -> Array[Enums.InputAction]:
	var r: Array[Enums.InputAction] = []
	for action_name in _actions:
		var state: ActionState = _action_state[action_name]
		if state.is_pressed():
			r.append(state.action)
	return r


func get_just_released() -> Array[Enums.InputAction]:
	var r: Array[Enums.InputAction] = []
	for action_name in _actions:
		var state: ActionState = _action_state[action_name]
		if state.just_released():
			r.append(state.action)
	return r


func get_button_released() -> Array[Enums.InputAction]:
	var r: Array[Enums.InputAction] = []
	for action_name in _actions:
		var state: ActionState = _action_state[action_name]
		if state.not_pressed():
			r.append(state.action)
	return r


class ActionState:
	extends RefCounted

	var action: Enums.InputAction
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