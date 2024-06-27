@tool

extends CharacterBody2D

@export var player_controled: bool = false
@export var move_speed: int = 250

var _impulse: Vector2 = Vector2.ZERO
var _direction: Enums.Direction

var _sprite: AnimatedSprite2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for c in get_children():
		if c is AnimatedSprite2D:
			_sprite = c
			return

func _unhandled_input(_event: InputEvent) -> void:
	if !player_controled:
		return

	_impulse = Input.get_vector(
		Enums.InputActionName(Enums.InputAction.Left),
		Enums.InputActionName(Enums.InputAction.Right),
		Enums.InputActionName(Enums.InputAction.Up),
		Enums.InputActionName(Enums.InputAction.Down),
	).normalized()
	if _impulse != Vector2.ZERO:
		_direction = Utils.angle_to_direction(Vector2.UP.angle_to(_impulse))

func _physics_process(_delta: float) -> void:
	if _sprite == null:
		# there will be a moment where we haven't fonud the sprite child yet
		return

	if _impulse == Vector2.ZERO:
		_sprite.stop()
		return

	var want_anim := Enums.DirectionName(_direction)
	var animation_correct := _sprite.animation == want_anim

	if !animation_correct || !_sprite.is_playing:
		_sprite.play(want_anim)
	velocity = _impulse * move_speed
	move_and_slide()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func _get_configuration_warnings() -> PackedStringArray:
	var found_sprite: AnimatedSprite2D = null
	for c in get_children():
		if c is AnimatedSprite2D:
			found_sprite = c
			break

	if !found_sprite:
		return ["Character needs an animated sprite child."]

	var animations := found_sprite.sprite_frames.get_animation_names()
	var missing_anims: Array[String] = []

	for da: Enums.Direction in Enums.Direction.values():
		var want_name := Enums.DirectionName(da)
		if not want_name in animations:
			missing_anims.append(want_name)

	if missing_anims.size() > 0:
		return ["Missing expected animations in child sprite: " + str(missing_anims)]

	return []