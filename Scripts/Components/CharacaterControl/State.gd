class_name State
extends Node

var _state_machine: StateMachine
var _generic_ctx: Variant

func setup(machine: StateMachine, ctx: Variant = {}) -> void:
	_state_machine = machine
	_generic_ctx = ctx
	_local_setup()

func _local_setup() -> void:
	pass

func enter() -> void:
	pass

func exit() -> void:
	pass

func run_physics(_delta: float) -> State:
	return null

func run_tick(_delta: float) -> State:
	return null