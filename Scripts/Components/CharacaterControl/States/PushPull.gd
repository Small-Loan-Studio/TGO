extends CharacterState

@export var idle_state: State
@export var move_speed: int = 250

var _hud: HUD:
  get:
    return Driver.instance().get_hud()

var _target: MoveableBlock
# which direction is pushing
var _push_direction: Enums.Direction

# what is the axis we move on for this push direction
var _movement_axis: Vector2

# raw input from the controller
var _impulse: Vector2

# actual movement mediated by the movement axis
var _projected_impulse: Vector2


func enter(ctx: Variant) -> void:
  var ctx_dict := ctx as Dictionary
  _push_direction = ctx_dict["push_direction"]
  _movement_axis = Enums.direction_push_pull_axis(_push_direction)

  _target = ctx_dict["target"]
  run_input(null)

func run_input(_event: InputEvent) -> void:
  print("PushPull.run_input(null)")
  if Enums.InputAction.INTERACT in _ctx.controller.get_just_pressed():
    print("PushPull.queue idle state")
    _state_machine.queue_state_change(idle_state)
    # TODO: Undo toast
    return

  _impulse = _ctx.controller.get_vector()
  if _impulse == Vector2.ZERO:
    _animated_sprite.stop()
    return

  _projected_impulse = _impulse * _movement_axis
  var direction := Utils.angle_to_direction(Vector2.UP.angle_to(_projected_impulse))
  var want_animation := Enums.direction_name(direction)
  var animation_correct := _animated_sprite.animation == want_animation
  if !animation_correct || !_animated_sprite.is_playing():
    _animated_sprite.play(want_animation)

func run_physics(_delta: float) -> void:
  _ctx.character.velocity = _projected_impulse * move_speed / 2
  _ctx.character.move_and_slide()

func run_tick(_delta: float) -> void:
  pass


static func mk_args(facing: float, tgt: MoveableBlock) -> Dictionary:
  return {
		"push_direction": Utils.angle_to_direction(facing, Enums.DirectionMode.FOUR),
    "target": tgt,
	}
