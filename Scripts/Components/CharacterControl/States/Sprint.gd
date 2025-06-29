extends CharacterState

@export var idle_state: State
@export var walk_state: State
@export var move_speed: int = 300
@export var stamina_drain_rate: int = 5

var _impulse: Vector2
var _direction: Enums.Direction
var _has_entered: bool


func enter(_state: Variant, change_state: Callable) -> StateChange:
	if _get_stam().value < stamina_drain_rate:
		# change_state.call(idle_state)
		return StateChange.mk(idle_state)
	var next := await run_input(null, change_state)
	_has_entered = true
	return next


func exit() -> void:
	_has_entered = false


func run_input(_event: InputEvent, change_state: Callable) -> StateChange:
	_impulse = _ctx.controller.get_vector()

	if _impulse != Vector2.ZERO:
		_ctx.character.facing = Vector2.UP.angle_to(_impulse)
		_direction = Utils.angle_to_direction(_ctx.character.facing)

		var want_animation := Enums.direction_name(_direction)
		var animation_correct := _animated_sprite.animation == want_animation
		if !animation_correct || !_animated_sprite.is_playing():
			_animated_sprite.play(want_animation)
	else:
		# change_state.call(idle_state)
		return StateChange.mk(idle_state)

	if !Enums.InputAction.SPRINT in _ctx.controller.get_button_pressed():
		# change_state.call(walk_state, walk_state.mk_args(_impulse))
		return StateChange.mk(walk_state, walk_state.mk_args(_impulse))

	return null


func run_physics(_delta: float, _change_state: Callable) -> StateChange:
	if !_has_entered:
		return null
	_ctx.character._sensor_group.rotation = _ctx.character.facing
	_ctx.character.velocity = _impulse * move_speed
	_ctx.character.move_and_slide()
	return null


func _get_stam() -> CharacterStat:
	return _ctx.character.stats.get_stat(Enums.Stat.STAMINA)


func run_tick(delta: float, change_state: Callable) -> StateChange:
	if _get_stam().value < stamina_drain_rate:
		# change_state.call(idle_state)
		return StateChange.mk(idle_state)
	_ctx.character.stats.get_stat(Enums.Stat.STAMINA).drain(stamina_drain_rate * delta)

	return null


static func mk_args(initial_vec: Vector2) -> Dictionary:
	return {"impulse": initial_vec}
