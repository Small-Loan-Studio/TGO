extends CharacterState

@export var idle_state: State
@export var push_pull_state: State

var _tgt: CharacterTarget

func enter(_enter_ctx: Variant) -> void:
  _tgt = _ctx.character._target
  print(_tgt)

  if _tgt.is_interactable():
    _animated_sprite.stop()
    _tgt.get_interactable().trigger(_ctx.character)

  elif _tgt.is_moveable_block():
    _animated_sprite.stop()
    _state_machine.queue_state_change(
      push_pull_state,
      push_pull_state.mk_args(_ctx.character._facing, _tgt.get_moveable_block()),
    )

func run_tick(_delta: float) -> void:
  if Dialogic.current_timeline == null && !_tgt.is_moveable_block():
    _state_machine.queue_state_change(idle_state)