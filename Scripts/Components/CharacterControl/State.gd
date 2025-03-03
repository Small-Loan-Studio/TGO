class_name State
extends Node

## Janky way to specify that if this state is running the state machine owner
## should (probably) not allow other things to handle input. Mostly for
## menu overlays. Probably better handled through understanding the UI event
## propagation model but alas.
@export var _input_exclusive: bool = false

var _state_machine: StateMachine
var _setup_args: Variant


func setup(machine: StateMachine, setup_args: Variant = {}) -> void:
	_state_machine = machine
	_setup_args = setup_args
	_local_setup()


func _local_setup() -> void:
	pass


func enter(_ctx: Variant) -> void:
	pass


func exit() -> void:
	pass


func run_input(_event: InputEvent, _change_state: Callable) -> void:
	pass


func run_physics(_delta: float, _change_state: Callable) -> void:
	pass


func run_tick(_delta: float, _change_state: Callable) -> void:
	pass
