extends CharacterState

@export var walk_state: State
@export var sprint_state: State
@export var _animation_name: String


func _local_setup() -> void:
	_ctx = _setup_args as StateMachine.CharacterContext
	_animated_sprite = _ctx.character._sprite


func enter(_ctx: Variant) -> void:
	if _animation_name != "":
		_animated_sprite.play(_animation_name)
	else:
		_animated_sprite.stop()


func run_input(_event: InputEvent) -> void:
	if maybe_menu() || maybe_interact():
		# this is a noop but here to quiet lint
		return


func run_tick(_delta: float) -> void:
	var vect := _ctx.controller.get_vector()
	if vect != Vector2.ZERO:
		if Enums.InputAction.SPRINT in _ctx.controller.get_button_pressed():
			_state_machine.queue_state_change(sprint_state, sprint_state.mk_args(vect))
		else:
			_state_machine.queue_state_change(walk_state, walk_state.mk_args(vect))
