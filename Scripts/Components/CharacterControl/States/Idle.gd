extends CharacterState

@export var walk_state: State
@export var sprint_state: State
@export var _animation_name: String


func _local_setup() -> void:
	_ctx = _setup_args as StateMachine.CharacterContext
	_animated_sprite = _ctx.character._sprite


func enter(_ctx: Variant) -> StateChange:
	if _animation_name != "":
		_animated_sprite.play(_animation_name)
	else:
		_animated_sprite.stop()
	return null


func run_input(_event: InputEvent) -> StateChange:
	var ns := maybe_menu()
	if ns != null:
		return ns
	ns = maybe_interact()
	if ns != null:
		return ns
	return null


func run_tick(_delta: float) -> StateChange:
	var vect := _ctx.controller.get_vector()
	if vect != Vector2.ZERO:
		if Enums.InputAction.SPRINT in _ctx.controller.get_button_pressed():
			return StateChange.mk(sprint_state, sprint_state.mk_args(vect))
		return StateChange.mk(walk_state, walk_state.mk_args(vect))
	return null
