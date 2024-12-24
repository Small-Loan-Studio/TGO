extends CharacterState

@export var idle_state: State
@export var move_speed: int = 250

var _impulse: Vector2
var _facing: float
var _direction: Enums.Direction


func enter(ctx: Variant) -> void:
	run_input(null)


func run_input(_event: InputEvent) -> void:
	_impulse = _ctx.controller.get_vector()
	_facing = Vector2.UP.angle_to(_impulse)
	_direction = Utils.angle_to_direction(_facing)

	if _ctx.controller.get_vector() == Vector2.ZERO:
		_state_machine.queue_state_change(idle_state)
		return

	var want_animation := Enums.direction_name(_direction)
	var animation_correct := _animated_sprite.animation == want_animation
	if !animation_correct || !_animated_sprite.is_playing():
		print("_animated_sprite.play(%s)" % [want_animation])
		_animated_sprite.play(want_animation)

func run_physics(delta: float) -> void:
	_ctx.character._sensor_group.rotation = _facing
	_ctx.character.velocity = _impulse * move_speed
	_ctx.character.move_and_slide()


func run_tick(_delta: float) -> void:
	pass


static func mk_args(initial_vec: Vector2) -> Dictionary:
	return { 'impulse': initial_vec }