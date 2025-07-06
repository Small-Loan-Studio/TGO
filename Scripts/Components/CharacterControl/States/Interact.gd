extends CharacterState

## TODO: multi-action panel control is ... confusing; could use a refactor

@export var idle_state: State
@export var push_pull_state: State

var _is_interacting: bool = false
var _is_selecting: bool = false
var _tgt: CharacterTarget


func enter(_enter_ctx: Variant) -> StateChange:
	_tgt = _ctx.character.target
	return await run_input(null)


func run_input(_event: InputEvent) -> StateChange:
	if _is_interacting:
		return null

	var interactable := _tgt.get_interactable()
	if _is_selecting:
		interactable.primary.visible = false

		var ctrl := _ctx.controller
		var cancel := func() -> StateChange:
			interactable.secondary.blur()
			interactable.secondary.toggle()
			_show_panels()
			_is_selecting = false
			return StateChange.mk(idle_state)

		if (
			ctrl.just_pressed(Enums.InputAction.SECONDARY)
			|| ctrl.just_pressed(Enums.InputAction.INTERACT_CANCEL)
		):
			return cancel.call()
		if ctrl.just_pressed(Enums.InputAction.DEFAULT):
			if interactable.secondary.selected == Enums.ActionVerb.INTERACT_MENU_CLOSE:
				return cancel.call()
			_is_interacting = true
			_is_selecting = false

			interactable.secondary.toggle()
			interactable.secondary.visible = false
			await interactable.trigger(_ctx.character, interactable.secondary.selected)
			_show_panels()
			_is_interacting = false
			return StateChange.mk(idle_state)

		elif _ctx.controller.just_pressed(Enums.InputAction.DOWN):
			interactable.secondary.next()

		elif _ctx.controller.just_pressed(Enums.InputAction.UP):
			interactable.secondary.previous()

		return null

	if _tgt.is_interactable():
		_animated_sprite.stop()
		interactable.primary.visible = true

		if _ctx.controller.just_pressed(Enums.InputAction.SECONDARY):
			# secondary + one action -> not actually interacting
			if interactable.action_count == 1:
				_is_interacting = false
				return StateChange.mk(idle_state)

			# secondary + 2 actions -> trigger the second action
			if interactable.action_count == 2:
				_is_interacting = true
				var verb: Enums.ActionVerb = interactable.secondary.selected
				interactable.primary.visible = false
				interactable.secondary.visible = false
				await interactable.trigger(_ctx.character, verb)
				_show_panels()
				_is_interacting = false
				return StateChange.mk(idle_state)

			else:
				# secondary + 3+ actions -> move to secondary action selection sub-state
				_is_selecting = true
				interactable.secondary.focus(interactable.default_verb)
				interactable.secondary.toggle()
				interactable.primary.visible = false
				# remain in interactable state
				return null

		elif _ctx.controller.just_pressed(Enums.InputAction.DEFAULT):
			# otherwise trigger the interactable
			_is_interacting = true
			interactable.primary.visible = false
			if interactable.action_count > 1:
				interactable.secondary.visible = false
			await interactable.trigger(_ctx.character)
			_show_panels()
			_is_interacting = false
			return StateChange.mk(idle_state)

	return null


func _show_panels() -> void:
	var interactable := _tgt.get_interactable()
	if interactable == null:
		# this happens when one of the interactions triggers a load level
		return

	if interactable.primary != null:
		interactable.primary.visible = true
	if interactable.secondary != null && interactable.action_count > 1:
		interactable.secondary.visible = true


func run_tick(_delta: float) -> StateChange:
	if _is_selecting:
		return
	if _tgt.is_moveable_block():
		_animated_sprite.stop()
		_is_interacting = false
		return StateChange.mk(
			push_pull_state,
			push_pull_state.mk_args(_ctx.character.facing, _tgt.get_moveable_block())
		)

	return null
