extends CharacterState

@export var idle_state: State
@export var sprint_state: State
@export var move_speed: int = 200

var _impulse: Vector2
var _direction: Enums.Direction
var _has_entered: bool


func enter(_state: Variant) -> void:
	run_input(null)
	_has_entered = true


func exit() -> void:
	_has_entered = false


func run_input(_event: InputEvent) -> void:
	_impulse = _ctx.controller.get_vector()

	if _impulse != Vector2.ZERO:
		_ctx.character.facing = Vector2.UP.angle_to(_impulse)
		if Enums.InputAction.SPRINT in _ctx.controller.get_button_pressed():
			_state_machine.queue_state_change(sprint_state, sprint_state.mk_args(_impulse))
			_impulse = Vector2.ZERO
			return

		_direction = Utils.angle_to_direction(_ctx.character.facing)
		var want_animation := Enums.direction_name(_direction)
		var animation_correct := _animated_sprite.animation == want_animation
		if !animation_correct || !_animated_sprite.is_playing():
			_animated_sprite.play(want_animation)
	else:
		_state_machine.queue_state_change(idle_state)

	maybe_interact()


func run_physics(_delta: float) -> void:
	if !_has_entered:
		return
	_ctx.character._sensor_group.rotation = _ctx.character.facing
	_ctx.character.velocity = _impulse * move_speed
	_ctx.character.move_and_slide()


static func mk_args(initial_vec: Vector2) -> Dictionary:
	return {"impulse": initial_vec}
