extends CharacterState

@export var idle_state: State
@export var push_pull_state: State

var _tgt: CharacterTarget


func enter(_enter_ctx: Variant) -> void:
	_tgt = _ctx.character.target

	if _tgt.is_interactable():
		_animated_sprite.stop()
		var interactable := _tgt.get_interactable()
		interactable.trigger(_ctx.character)
		await interactable.triggered


func run_tick(_delta: float, change_state: Callable) -> void:
	if _tgt.is_moveable_block():
		_animated_sprite.stop()
		(
			change_state
			. call(
				push_pull_state,
				push_pull_state.mk_args(_ctx.character.facing, _tgt.get_moveable_block()),
			)
		)
		return

	if Dialogic.current_timeline == null:
		change_state.call(idle_state)
