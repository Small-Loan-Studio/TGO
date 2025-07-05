extends CharacterState

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
			interactable.primary.visible = true
			_is_selecting = false
			return StateChange.mk(idle_state)

		if (
			ctrl.just_pressed(Enums.InputAction.SECONDARY)
			|| ctrl.just_pressed(Enums.InputAction.INTERACT_CANCEL)
		):
			print("case X -> idle")
			return cancel.call()
		if ctrl.just_pressed(Enums.InputAction.DEFAULT):
			if interactable.secondary.selected == Enums.ActionVerb.CLOSE:
				print("case Y -> idle")
				return cancel.call()
			_is_interacting = true
			_is_selecting = false
			interactable.secondary.toggle()
			interactable.primary.visible = true
			await interactable.trigger(_ctx.character, interactable.secondary.selected)
			# await interactable.simple_triggered
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

		# in cases where there are more than one actions transition to a selecting sub-state
		if _ctx.controller.just_pressed(Enums.InputAction.SECONDARY):
			if interactable.action_count == 1:
				_is_interacting = false
				return StateChange.mk(idle_state)
			if interactable.action_count == 2:
				_is_interacting = true
				var verb: Enums.ActionVerb = interactable.secondary.selected
				await interactable.trigger(_ctx.character, verb)
				# await interactable.simple_triggered
				_is_interacting = false
				return StateChange.mk(idle_state)
			else:
				_is_selecting = true
				interactable.secondary.focus(interactable.default_verb)
				interactable.secondary.toggle()
				interactable.primary.visible = false
		elif _ctx.controller.just_pressed(Enums.InputAction.DEFAULT):
			# otherwise trigger the interactable
			_is_interacting = true
			print("%d: %s.trigger" % [_state_machine.rnd, interactable.get_parent().name])
			await interactable.trigger(_ctx.character)
			print("%d: awaiting" % [_state_machine.rnd])
			# await interactable.simple_triggered
			print("%d: %s.triggered" % [_state_machine.rnd, interactable.get_parent().name])
			_is_interacting = false
			return StateChange.mk(idle_state)

	return null


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
