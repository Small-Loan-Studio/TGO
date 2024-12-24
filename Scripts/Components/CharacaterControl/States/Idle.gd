extends CharacterState

@export var walk_state: State
@export var _animation_name: String

func _local_setup() -> void:
	_ctx = _setup_args as StateMachine.CharacterContext
	_animated_sprite = _ctx.character._sprite

func run_input(_event: InputEvent) -> void:
	maybe_interact()

func enter(_ctx: Variant) -> void:
	if _animation_name != "":
		_animated_sprite.play(_animation_name)
	else:
		_animated_sprite.stop()

func run_tick(_delta: float) -> void:
	var vect := _ctx.controller.get_vector()
	if vect != Vector2.ZERO:
		_state_machine.queue_state_change(walk_state, walk_state.mk_args(vect))
