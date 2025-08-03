class_name CharacterState
extends State

@export var interact_state: State
@export var menu_state: State
@export var dialog_state: State

var _ctx: StateMachine.CharacterContext
var _animated_sprite: AnimatedSprite2D


func _local_setup() -> void:
	_ctx = _setup_args as StateMachine.CharacterContext
	_animated_sprite = _ctx.character._sprite


func maybe_interact() -> StateChange:
	var just_pressed := _ctx.controller.get_just_pressed()

	if !_ctx.character.target.is_set():
		return null

	var tgt: Interactable = _ctx.character.target.get_interactable()
	if tgt != null && tgt.automatic:
		return StateChange.mk(interact_state)

	if Enums.InputAction.DEFAULT in just_pressed || Enums.InputAction.SECONDARY in just_pressed:
		return StateChange.mk(interact_state)

	return null


func maybe_menu() -> StateChange:
	var just_pressed := _ctx.controller.get_just_pressed()
	if menu_state == null || !_ctx.controller.just_pressed(Enums.InputAction.MENU):
		return null

	return StateChange.mk(menu_state, menu_state.mk_args(Menus.MenuKind.PAUSE))

func maybe_dialog() -> StateChange:
	if(Dialogic.current_timeline != null):
		return StateChange.mk(dialog_state)
	return null
