@tool
## ControllerBase impl that pulls all control inputs from input devices
## (kb/m, controller, etc)
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

# what is the current frame; used to track just_pressed
var _frame_count := 0

## A list of inputs that map to movement controls
var _movement: Array[String]
## A list of monitored input actions
var _actions: Array[String]

var _dir_vector: Vector2

var _setup: bool = false
# Map[String, ActionState]
var _action_states: Dictionary
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
		_action_states[name] = InputController.ActionState.new()
		_action_states[name].action = ele
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

	# headed toward debounce, c.f. https://github.com/Small-Loan-Studio/TGO/issues/176
	# Also might end up ditching InputController entirely as the concept seems
	# like it might be a mostly failed experiment
	_dir_vector = _input.get_vector(
		_movement[DIR_NEG_X],
		_movement[DIR_POS_X],
		_movement[DIR_NEG_Y],
		_movement[DIR_POS_Y],
		deadzone
	)
	_dir_vector = _dir_vector.normalized()

	if _dir_vector.length() < deadzone:
		_dir_vector = Vector2.ZERO

	for action_name: String in _action_states:
		var state: ActionState = _action_states[action_name]
		var prev_state := state.state

		if !state._is_new_frame(_frame_count):
			continue

		# if action_name == "left_item":
		# print("-> %s" % [state])
		var cur_pressed := _input.is_action_pressed(action_name)
		match [prev_state, cur_pressed]:
			[JUST_PRESSED, true]:
				state.state = PRESSED
			[JUST_PRESSED, false]:
				state.state = JUST_RELEASED
			[PRESSED, true]:
				state.state = PRESSED
			[PRESSED, false]:
				state.state = JUST_RELEASED
			[JUST_RELEASED, true]:
				state.state = JUST_PRESSED
			[JUST_RELEASED, false]:
				state.state = UNPRESSED
			[UNPRESSED, true]:
				state.state = JUST_PRESSED
			[UNPRESSED, false]:
				state.state = UNPRESSED
		state.entered_state = _frame_count
		# if action_name == "left_item":
		# 	print("<- %s" % [state])

		# if _input.is_action_pressed(action_name):
		# 	# _action_states.get(action_name).state = PRESSED
		# 	state.state = PRESSED
		# 	if _input.is_action_just_pressed(action_name):
		# 		_action_states.get(action_name).state = JUST_PRESSED
		# 		_state.state = JUST_PRESSED
		# elif _input.is_action_just_released(action_name):
		# 	_action_states.get(action_name).state = JUST_RELEASED
		# else:
		# 	_action_states.get(action_name).state = UNPRESSED


func action(input: Enums.InputAction) -> InputController.ActionState:
	var name := Enums.input_action_name(input)
	if _action_states.has(name):
		return _action_states.get(name)

	printerr("InputController doesn't know about %s" % [Enums.input_action_name(input)])
	return _always_unpressed


func get_vector() -> Vector2:
	return _dir_vector


func get_just_pressed() -> Array[Enums.InputAction]:
	var r: Array[Enums.InputAction] = []
	for action_name in _actions:
		var state: ActionState = _action_states[action_name]
		if state.just_pressed() && state.entered_state == _frame_count:
			r.append(state.action)
	return r


func get_button_pressed() -> Array[Enums.InputAction]:
	var r: Array[Enums.InputAction] = []
	for action_name in _actions:
		var state: ActionState = _action_states[action_name]
		if state.is_pressed():
			r.append(state.action)
	return r


func get_just_released() -> Array[Enums.InputAction]:
	var r: Array[Enums.InputAction] = []
	for action_name in _actions:
		var state: ActionState = _action_states[action_name]
		if state.just_released() && state.entered_state == _frame_count:
			r.append(state.action)
	return r


func get_button_released() -> Array[Enums.InputAction]:
	var r: Array[Enums.InputAction] = []
	for action_name in _actions:
		var state: ActionState = _action_states[action_name]
		if state.not_pressed():
			r.append(state.action)
	return r


func _process(_delta: float) -> void:
	_frame_count += 1


class ActionState:
	extends RefCounted

	var action: Enums.InputAction
	var state: int = UNPRESSED
	var entered_state: int = 0

	# returns whether the current frame is later than the frame that we are
	# currently tracking
	func _is_new_frame(n: int) -> bool:
		return n > entered_state

	func just_pressed() -> bool:
		return state == JUST_PRESSED

	func is_pressed() -> bool:
		return state == JUST_PRESSED || state == PRESSED

	func just_released() -> bool:
		return state == JUST_RELEASED

	func not_pressed() -> bool:
		return state == JUST_RELEASED || state == UNPRESSED

	func _to_string() -> String:
		var str := Enums.input_action_name(action)
		match state:
			JUST_PRESSED:
				str += " JUST_PRESSED"
			PRESSED:
				str += " PRESSED"
			JUST_RELEASED:
				str += " JUST_RELEASED"
			UNPRESSED:
				str += " UNPRESSED"
		str += ", %d" % [entered_state]
		return str


class InputWrapper:
	extends RefCounted

	var _override: Variant

	func _init(override: Variant) -> void:
		_override = override

	func get_vector(
		left: String, right: String, down: String, up: String, deadzone: float
	) -> Vector2:
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
