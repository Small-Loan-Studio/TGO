class_name StateMachine
extends Node

@export var _initial_state: State
var print_state_changes: bool = false

# Set after setup is called
var _setup_complete: bool = false
# Dictionary of node name -> State object
#     Map[String, State]
var _states: Dictionary = {}
# The state currently being run
var _cur_state: State
# When a new state has been queued this gets set
var _next_state: State = null
# Any context that should be passed into the next state's enter call
var _next_state_ctx: Variant = null


func _ready() -> void:
	print("%s Discovering states:" % [get_parent().name])
	for c in get_children():
		if c is State:
			print("  - ", c.name)
			_states[c.name] = c


func setup(ctx: Variant = null) -> void:
	var noop := State.new()
	noop.name = "_Default"
	_states[noop.name] = noop
	_cur_state = noop

	for st_name: String in _states:
		var st: State = _states[st_name]
		st.setup(self, ctx)

	if _initial_state != null:
		_next_state = _initial_state
		_maybe_enter_state()
	else:
		printerr("No initial state provided")

	_setup_complete = true


func _maybe_enter_state() -> void:
	if _next_state == null:
		return

	_cur_state.exit()
	if print_state_changes:
		print("%s -> %s" % [_cur_state.name, _next_state.name])
	_cur_state = _next_state
	_next_state = null
	_cur_state.enter(_next_state_ctx)


func run_input(event: InputEvent) -> void:
	if !_setup_complete:
		return

	_next_state = null
	_cur_state.run_input(event)
	_maybe_enter_state()


func run_physics(delta: float) -> void:
	if !_setup_complete:
		return

	_next_state = null
	_cur_state.run_physics(delta)
	_maybe_enter_state()


func run_tick(delta: float) -> void:
	if !_setup_complete:
		return

	_next_state = null
	_cur_state.run_tick(delta)
	_maybe_enter_state()


func cur_state() -> State:
	return _cur_state


## TODO: the current model is not thread safe and I think we're basically
## daring race conditions between physics, main, and input thread (caveat:
## physics only runs in its own thread if we configure it iirc so we're probably
## okayish, idk about input event processing)
func queue_state_change(next_state: State, context: Variant = null) -> void:
	# print("%s / StateMachine.queue_state_change(%s)" % [_cur_state.name, next_state.name])
	if _next_state != null:
		printerr(
			"Warning: Overwriting _next_state %s with %s" % [_next_state.name, next_state.name]
		)
	_next_state = next_state
	_next_state_ctx = context


class CharacterContext:
	extends RefCounted

	var character: CharacterBody2D
	var controller: ControllerBase
