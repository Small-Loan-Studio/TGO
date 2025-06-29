extends CharacterState

@export var idle_state: State

var _target: Interactable


func enter(ctx: Variant, _change_state: Callable) -> void:
	_target = ctx["tgt"]


func run_input(_event: InputEvent, change_state: Callable) -> void:
	if _target == null:
		change_state.call(idle_state)
		return

	if _ctx.controller.just_pressed(Enums.InputAction.INTERACT_CANCEL):
		change_state.call(idle_state)
		return

	if _ctx.controller.just_pressed(Enums.InputAction.SECONDARY):
		if _target.action_count == 2:
			var verb: Enums.ActionVerb = _target.secondary.selected
			_target.trigger(_ctx.character, verb)
			await _target.triggered


func run_tick(_delta: float, _change_state: Callable) -> void:
	pass


static func mk_args(interactable: Interactable) -> Dictionary:
	return {"tgt": interactable}
