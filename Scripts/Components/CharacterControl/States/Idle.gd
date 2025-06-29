extends CharacterState

@export var walk_state: State
@export var sprint_state: State
@export var _animation_name: String


func _local_setup() -> void:
	_ctx = _setup_args as StateMachine.CharacterContext
	_animated_sprite = _ctx.character._sprite


func enter(_ctx: Variant, _change_state: Callable) -> StateChange:
	if _animation_name != "":
		_animated_sprite.play(_animation_name)
	else:
		_animated_sprite.stop()
	return null


func run_input(_event: InputEvent, change_state: Callable) -> StateChange:
	var ns := maybe_menu2(change_state)
	if ns != null:
		return ns
	ns = maybe_interact2()
	if ns != null:
		return ns
	return null
	# if maybe_menu(change_state) || maybe_interact(change_state):
	# 	# this is a noop but here to quiet lint
	# 	return


func run_tick(_delta: float, change_state: Callable) -> StateChange:
	var vect := _ctx.controller.get_vector()
	if vect != Vector2.ZERO:
		if Enums.InputAction.SPRINT in _ctx.controller.get_button_pressed():
			# change_state.call(sprint_state, sprint_state.mk_args(vect))
			return StateChange.mk(sprint_state, sprint_state.mk_args(vect))
		else:
			# change_state.call(walk_state, walk_state.mk_args(vect))
			return StateChange.mk(walk_state, walk_state.mk_args(vect))
	return null
