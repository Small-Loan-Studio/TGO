class_name StateMachine
extends Node

var _states: Dictionary = {}

var _cur_state: State

func _ready() -> void:
	_cur_state = State.new()
	_cur_state.name = "Default"

	for c in get_children():
		if c is State:
			_states[c.name] = c

func setup(initial_state: State) -> void:
	_enter_state(initial_state)


func _enter_state(tgt: State) -> void:
	_cur_state.exit()
	_cur_state = tgt
	tgt.enter()


func run_physics() -> void:
	var next_state := _cur_state.run_physics()
	if next_state != null:
		_enter_state(next_state)


func run_tick() -> void:
	var next_state := _cur_state.run_tick()
	if next_state != null:
		_enter_state(next_state)


func get_state() -> State:
	return _cur_state