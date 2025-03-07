class_name State
extends Node

var _state_machine: StateMachine
var _setup_args: Variant


func setup(machine: StateMachine, setup_args: Variant = {}) -> void:
	_state_machine = machine
	_setup_args = setup_args
	_local_setup()


func _local_setup() -> void:
	pass


func enter(_ctx: Variant, _change_state: Callable) -> void:
	pass


func exit() -> void:
	pass


func run_input(_event: InputEvent, _change_state: Callable) -> void:
	pass


func run_physics(_delta: float, _change_state: Callable) -> void:
	pass


func run_tick(_delta: float, _change_state: Callable) -> void:
	pass
