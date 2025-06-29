class_name CharacterState
extends State

@export var interact_state: State
@export var interact_sub_state: State
@export var menu_state: State

var _ctx: StateMachine.CharacterContext
var _animated_sprite: AnimatedSprite2D


func _local_setup() -> void:
	_ctx = _setup_args as StateMachine.CharacterContext
	_animated_sprite = _ctx.character._sprite


func maybe_interact2() -> StateChange:
	var just_pressed := _ctx.controller.get_just_pressed()

	if !_ctx.character.target.is_set():
		return null

	var tgt: Interactable = _ctx.character.target.get_interactable()
	if tgt != null:
		if _ctx.character.target.get_interactable().automatic:
			# change_state.call(interact_state)
			return StateChange.mk(interact_state)

	if Enums.InputAction.DEFAULT in just_pressed || Enums.InputAction.SECONDARY in just_pressed:
		# change_state.call(interact_state)
		return StateChange.mk(interact_state)
		# return true

	return null

# func maybe_interact(change_state: Callable) -> bool:
# 	var just_pressed := _ctx.controller.get_just_pressed()

# 	if !_ctx.character.target.is_set():
# 		return false

# 	var tgt: Interactable = _ctx.character.target.get_interactable()
# 	if tgt != null:
# 		if _ctx.character.target.get_interactable().automatic:
# 			change_state.call(interact_state)
# 			return true

# 	if Enums.InputAction.DEFAULT in just_pressed || Enums.InputAction.SECONDARY in just_pressed:
# 		change_state.call(interact_state)
# 		return true

# 	return false


# func maybe_menu(change_state: Callable) -> bool:
# 	var just_pressed := _ctx.controller.get_just_pressed()
# 	if menu_state == null || !_ctx.controller.just_pressed(Enums.InputAction.MENU):
# 		return false

# 	(
# 		change_state
# 		. call(
# 			menu_state,
# 			menu_state.mk_args(Menus.MenuKind.PAUSE),
# 		)
# 	)
# 	return true

func maybe_menu2(change_state: Callable) -> StateChange:
	var just_pressed := _ctx.controller.get_just_pressed()
	if menu_state == null || !_ctx.controller.just_pressed(Enums.InputAction.MENU):
		return null

	return StateChange.mk(menu_state, menu_state.mk_args(Menus.MenuKind.PAUSE))
	# (
	# 	change_state
	# 	. call(
	# 		menu_state,
	# 		menu_state.mk_args(Menus.MenuKind.PAUSE),
	# 	)
	# )
	# return true
