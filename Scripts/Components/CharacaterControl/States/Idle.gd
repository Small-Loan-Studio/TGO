extends State

var _ctx: StateMachine.CharacterContext
var _animated_sprite: AnimatedSprite2D

@export var walk_state: State
@export var _animation_name: String

func _local_setup() -> void:
	_ctx = _generic_ctx as StateMachine.CharacterContext
	_animated_sprite = _ctx.character._sprite

func enter() -> void:
	if _animation_name != "":
		_animated_sprite.play(_animation_name)

func exit() -> void:
	pass

func run_tick(_delta: float) -> State:
	if _ctx.controller.get_vector() != Vector2.ZERO:
		return walk_state

	return null
