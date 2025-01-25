class_name CharacterState
extends State

@export var interact_state: State
@export var menu_state: State

var _ctx: StateMachine.CharacterContext
var _animated_sprite: AnimatedSprite2D


func _local_setup() -> void:
	_ctx = _setup_args as StateMachine.CharacterContext
	_animated_sprite = _ctx.character._sprite


func maybe_interact() -> bool:
	var just_pressed := _ctx.controller.get_just_pressed()

	if !_ctx.character.target.is_set():
		return false

	if _ctx.character.target.get_interactable():
		if _ctx.character.target.get_interactable().automatic:
			_state_machine.queue_state_change(interact_state)
			return true

	if Enums.InputAction.INTERACT in just_pressed:
		_state_machine.queue_state_change(interact_state)
		return true

	return false

func maybe_menu() -> bool:
	var just_pressed := _ctx.controller.get_just_pressed()
	if menu_state == null || !_ctx.controller.just_pressed(Enums.InputAction.MENU):
		return false

	_state_machine.queue_state_change(
		menu_state,
		menu_state.mk_args(Enums.MenuType.GAMEPLAY),
	)
	return true