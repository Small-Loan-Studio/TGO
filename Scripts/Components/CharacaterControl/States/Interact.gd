extends CharacterState

@export var idle_state: State

var _tgt: CharacterTarget

func enter(_enter_ctx: Variant) -> void:
  _tgt = _ctx.character._target
  if _tgt.is_interactable():
    _animated_sprite.stop()
    _tgt.get_interactable().trigger(_ctx.character)

func run_tick(_delta: float) -> void:
  if Dialogic.current_timeline == null:
    _state_machine.queue_state_change(idle_state)