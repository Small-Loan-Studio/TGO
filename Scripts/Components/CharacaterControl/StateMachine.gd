class_name StateMachine
extends Node

var _states: Dictionary = {}
var _cur_state: State

@export var _initial_state: State

func _ready() -> void:
	print("Discovering states:")
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
		_enter_state(_initial_state)
	else:
		printerr("No initial state provided")


func _enter_state(tgt: State) -> void:
	_cur_state.exit()
	print("%s -> %s" % [_cur_state.name, tgt.name])
	_cur_state = tgt
	tgt.enter()


func run_physics(delta: float) -> void:
	var next_state := _cur_state.run_physics(delta)
	if next_state != null:
		_enter_state(next_state)


func run_tick(delta: float) -> void:
	var next_state := _cur_state.run_tick(delta)
	if next_state != null:
		_enter_state(next_state)


func cur_state() -> State:
	return _cur_state


class CharacterContext:
	extends RefCounted

	var character: CharacterBody2D
	var controller: ControllerBase