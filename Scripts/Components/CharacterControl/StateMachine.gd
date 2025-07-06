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


func _ready() -> void:
	for c in get_children():
		if c is State:
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
		_switch(StateChange.mk(_initial_state))
	else:
		printerr("No initial state provided")

	_setup_complete = true


func _switch(next: StateChange, depth: int = 0) -> void:
	if next == null || next.next_state == null:
		return

	# Sometimes we make poor decisions in life like infinite state loops.
	# Don't let them be the end, just face plant and move on.
	if depth > 4:
		printerr(
			(
				"StateMachine having a bad time enter state depth of %d. Aborting further transitions"
				% [depth]
			)
		)
		return

	if _cur_state != null:
		_cur_state.exit()
	if print_state_changes:
		print("(%d) %s -> %s" % [depth, _cur_state.name, next.next_state.name])

	_cur_state = next.next_state

	# yes, the await is required
	var maybe_next: StateChange = await _cur_state.enter(next.ctx)
	if maybe_next != null:
		_switch(maybe_next, depth + 1)


func run_input(event: InputEvent) -> void:
	if !_setup_complete:
		return

	# yes, the await is required
	_switch(await _cur_state.run_input(event))


func run_physics(delta: float) -> void:
	if !_setup_complete:
		return
	# yes, the await is required
	_switch(await _cur_state.run_physics(delta))


func run_tick(delta: float) -> void:
	if !_setup_complete:
		return

	# yes, the await is required
	_switch(await _cur_state.run_tick(delta))


func cur_state() -> State:
	return _cur_state


func input_exclusive() -> bool:
	if _cur_state == null:
		return false
	return _cur_state._input_exclusive


class CharacterContext:
	extends RefCounted

	var character: CharacterBody2D
	var controller: ControllerBase
