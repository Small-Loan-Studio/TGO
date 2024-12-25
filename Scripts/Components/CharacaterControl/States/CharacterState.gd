class_name CharacterState
extends State

@export var interact_state: State

var _ctx: StateMachine.CharacterContext
var _animated_sprite: AnimatedSprite2D

func _local_setup() -> void:
	_ctx = _setup_args as StateMachine.CharacterContext
	_animated_sprite = _ctx.character._sprite

func maybe_interact() -> bool:
	var just_pressed := _ctx.controller.get_just_pressed()

	if !_ctx.character._target.is_set():
		return false

	if _ctx.character._target.get_interactable():
		if _ctx.character._target.get_interactable().automatic:
			_state_machine.queue_state_change(interact_state)
			return true

	if Enums.InputAction.INTERACT in just_pressed:
		_state_machine.queue_state_change(interact_state)
		return true

	return false