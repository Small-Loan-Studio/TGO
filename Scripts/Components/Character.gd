@tool

class_name Character
extends CharacterBody2D

## Set this to make the character be controlled by player input
@export var player_controled: bool = false

## This controls player movement speed in pixels/sec
@export var move_speed: int = 250

## set this to customize the AnimatedSprite, should only be accessed during
## scene editing. Should have an animation for every direction defined in
## Enums.Direction
@export var _override_default_sprite_frames: SpriteFrames:
	get:
		return _override_default_sprite_frames
	set(new_value):
		if new_value == null:
			new_value = preload("res://Art/Characters/character_placeholder.tres")
		_override_default_sprite_frames = new_value
		if Engine.is_editor_hint() && _sprite != null:
			_sprite.sprite_frames = new_value

# direction force will be applied for movement
var _impulse: Vector2 = Vector2.ZERO

# _impulse represented as [-TAU, TAU] off Vector2.UP
var _facing: float = 0

# _facing reified into a direction
var _direction: Enums.Direction

var _focused_interactable: Interactable = null

# component cache
@onready var _sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var _interaction_sensor: Area2D = $InteractionSensor
@onready var _interaction_shape: CollisionShape2D = $InteractionSensor/InteractionShape


func _ready() -> void:
	if _override_default_sprite_frames != null:
		_sprite.sprite_frames = _override_default_sprite_frames


func _unhandled_input(_event: InputEvent) -> void:
	if !player_controled:
		_impulse = Vector2.ZERO
		return

	if Dialogic.current_timeline != null:
		return

	# TODO: may need to guard under Input.is_action_pressed for these or
	# handling input won't prevent movement in the face of non-propagating
	# input events
	_impulse = (
		Input
		. get_vector(
			Enums.input_action_name(Enums.InputAction.LEFT),
			Enums.input_action_name(Enums.InputAction.RIGHT),
			Enums.input_action_name(Enums.InputAction.UP),
			Enums.input_action_name(Enums.InputAction.DOWN),
		)
		. normalized()
	)

	if _impulse != Vector2.ZERO:
		_facing = Vector2.UP.angle_to(_impulse)
		_direction = Utils.angle_to_direction(_facing)

	_interaction_sensor.rotation = _facing

	if _focused_interactable != null:
		if _event.is_action_pressed(Enums.input_action_name(Enums.InputAction.INTERACT)):
			var actions := _focused_interactable.actions
			for a in actions:
				print("Action: " + str(a))
			_focused_interactable.trigger(self)


func _physics_process(_delta: float) -> void:
	if Engine.is_editor_hint():
		# gross. but here we are
		return

	if _impulse == Vector2.ZERO:
		# TODO: plausible we'll want a directional idle state to switch into
		_sprite.stop()
		return

	var want_anim := Enums.direction_name(_direction)
	var animation_correct := _sprite.animation == want_anim

	print(
		(
			"want_anim: %s / animation_correct: %s / is_playing: %s"
			% [want_anim, animation_correct, _sprite.is_playing()]
		)
	)

	if !animation_correct || !_sprite.is_playing():
		_sprite.play(want_anim)
	velocity = _impulse * move_speed
	move_and_slide()


func _on_interaction_sensor_entered(area: Area2D) -> void:
	if area is Interactable:
		var i := area as Interactable
		print("found interactable " + area.name + " / " + area.get_parent().name)
		if i.automatic:
			print("automatic trigger, not tracking for manual engagement")
			i.trigger(self)
		else:
			_focused_interactable = area


func _on_interaction_sensor_exited(area: Area2D) -> void:
	if area is Interactable:
		print("lost interactable " + area.name + " / " + area.get_parent().name)
		if _focused_interactable == area:
			_focused_interactable = null


func _get_configuration_warnings() -> PackedStringArray:
	var animations := _sprite.sprite_frames.get_animation_names()
	var missing_anims: Array[String] = []

	for da: Enums.Direction in Enums.Direction.values():
		var want_name := Enums.direction_name(da)
		if not want_name in animations:
			missing_anims.append(want_name)

	if missing_anims.size() > 0:
		return ["Missing expected animations in child sprite: " + str(missing_anims)]

	return []
