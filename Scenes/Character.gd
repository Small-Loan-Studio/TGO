@tool

extends CharacterBody2D

@export var player_controled: bool = false
@export var move_speed: int = 250
@export var _override_default_sprite_frames: SpriteFrames:
	get:
		return _override_default_sprite_frames
	set(new_value):
		if new_value == null:
			new_value = preload("res://Art/character_placeholder.tres")
		_override_default_sprite_frames = new_value
		if Engine.is_editor_hint():
			_sprite.sprite_frames = new_value

# direction force will be applied for movement
var _impulse: Vector2 = Vector2.ZERO
# _impulse represented as [-TAU, TAU] off Vector2.UP
var _facing: float = 0
# _facing reified into a direction
var _direction: Enums.Direction

# component cache
@onready var _sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var _interaction_sensor: Area2D = $InteractionSensor
@onready var _interaction_shape: CollisionShape2D = $InteractionSensor/InteractionShape

func _ready() -> void:
	if _override_default_sprite_frames != null:
		_sprite.sprite_frames = _override_default_sprite_frames

func _unhandled_input(_event: InputEvent) -> void:
	if !player_controled:
		return

	# TODO: may need to guard under Input.is_action_pressed for these or
	# handling input won't prevent movement in the face of non-propagating
	# input events
	_impulse = Input.get_vector(
		Enums.InputActionName(Enums.InputAction.Left),
		Enums.InputActionName(Enums.InputAction.Right),
		Enums.InputActionName(Enums.InputAction.Up),
		Enums.InputActionName(Enums.InputAction.Down),
	).normalized()

	if _impulse != Vector2.ZERO:
		_facing = Vector2.UP.angle_to(_impulse)
		_direction = Utils.angle_to_direction(_facing)
	_interaction_sensor.rotation = _facing

func _physics_process(_delta: float) -> void:
	if Engine.is_editor_hint():
		# gross. but here we are
		return

	if _impulse == Vector2.ZERO:
		# TODO: plausible we'll want a directional idle state to switch into
		_sprite.stop()
		return

	var want_anim := Enums.DirectionName(_direction)
	var animation_correct := _sprite.animation == want_anim

	if !animation_correct || !_sprite.is_playing:
		_sprite.play(want_anim)
	velocity = _impulse * move_speed
	move_and_slide()

func _get_configuration_warnings() -> PackedStringArray:
	var found_sprite: AnimatedSprite2D = null
	var animations := found_sprite.sprite_frames.get_animation_names()
	var missing_anims: Array[String] = []

	for da: Enums.Direction in Enums.Direction.values():
		var want_name := Enums.DirectionName(da)
		if not want_name in animations:
			missing_anims.append(want_name)

	if missing_anims.size() > 0:
		return ["Missing expected animations in child sprite: " + str(missing_anims)]

	return []
