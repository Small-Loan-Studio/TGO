extends CharacterState

@export var idle_state: State
@export var push_pull_state: State

var _is_interacting: bool = false
var _is_selecting: bool = false
var _tgt: CharacterTarget


func enter(_enter_ctx: Variant, change_state: Callable) -> void:
	_tgt = _ctx.character.target
	run_input(null, change_state)


func run_input(_event: InputEvent, change_state: Callable) -> void:
	if _is_interacting:
		return

	if _is_selecting:
		var interactable := _tgt.get_interactable()
		if _ctx.controller.just_pressed(Enums.InputAction.DEFAULT):
			if interactable.interact.selected == Enums.ActionVerb.DEFAULT:
				interactable.interact.blur()
				interactable.interact.toggle()
				_is_selecting = false
				change_state.call(idle_state)
			else:
				_is_interacting = true
				_is_selecting = false
				interactable.interact.toggle()
				interactable.trigger(_ctx.character, interactable.interact.selected)
				await interactable.triggered
		elif _ctx.controller.just_pressed(Enums.InputAction.DOWN):
			interactable.interact.next()
		elif _ctx.controller.just_pressed(Enums.InputAction.UP):
			interactable.interact.previous()
		return

	if _tgt.is_interactable():
		_animated_sprite.stop()
		var interactable := _tgt.get_interactable()
		print("Found interactable: %s" % [interactable.name])
		print("available actions:")
		for key: Enums.ActionVerb in interactable.action_map.keys():
			print("  %s" % [key])

		# in cases where there are more than one actions transition to a selecting sub-state
		if interactable.interact.actions.size() > 1:
			_is_selecting = true
			interactable.interact.focus(interactable.default_verb)
			interactable.interact.toggle()
		else:
			# otherwise trigger the interactable
			_is_interacting = true
			interactable.trigger(_ctx.character)
			await interactable.triggered


func run_tick(_delta: float, change_state: Callable) -> void:
	if _is_selecting:
		return
	if _tgt.is_moveable_block():
		_animated_sprite.stop()
		(
			change_state
			. call(
				push_pull_state,
				push_pull_state.mk_args(_ctx.character.facing, _tgt.get_moveable_block()),
			)
		)
		_is_interacting = false
		return

	if Dialogic.current_timeline == null:
		change_state.call(idle_state)
		_is_interacting = false
