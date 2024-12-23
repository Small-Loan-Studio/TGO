class_name CharacterState
extends State

var _ctx: StateMachine.CharacterContext
var _animated_sprite: AnimatedSprite2D

func _local_setup() -> void:
	_ctx = _generic_ctx as StateMachine.CharacterContext
	_animated_sprite = _ctx.character._sprite