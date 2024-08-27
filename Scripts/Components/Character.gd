@tool

class_name Character
extends CharacterBody2D

## Set this to make the character be controlled by player input
@export var player_controled: bool = false

## This controls player movement speed in pixels/sec
@export var move_speed: int = 250

## The amonut of force the character has to push objects
@export var push_force: int = 200

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

## the most recent directional input as a vector
var _raw_input: Vector2 = Vector2.ZERO

## player input after any processing done ot the input
var _impulse: Vector2 = Vector2.ZERO

## _impulse represented as an angle off Vector2.UP; in radians / [-TAU, TAU]
var _facing: float = 0

## _facing reified into a direction
var _direction: Enums.Direction

## when pushing or pulling which direction is "forward"
var _push_direction: Enums.Direction

## how the character should be moving. This may impact speed or how input is interpreted
var _move_mode: Enums.MoveMode = Enums.MoveMode.WALK

## _target is a type safe container for anything that the player may focus to
## interact with
var _target: CharacterTarget = CharacterTarget.none()

# component cache
@onready var _sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var _interaction_sensor: Area2D = $InteractionSensor
@onready var _pinjoint: PinJoint2D = $PinJoint2D


func _ready() -> void:
	if _override_default_sprite_frames != null:
		_sprite.sprite_frames = _override_default_sprite_frames

	_target.target_changed.connect(Callable(self, "_handle_target_changed"))


func _unhandled_input(_event: InputEvent) -> void:
	if !player_controled:
		_raw_input = Vector2.ZERO
		_impulse = Vector2.ZERO
		return

	if Dialogic.current_timeline != null:
		return

	# TODO: may need to guard under Input.is_action_pressed for these or
	# handling input won't prevent movement in the face of non-propagating
	# input events
	_raw_input = (
		Input
		. get_vector(
			Enums.input_action_name(Enums.InputAction.LEFT),
			Enums.input_action_name(Enums.InputAction.RIGHT),
			Enums.input_action_name(Enums.InputAction.UP),
			Enums.input_action_name(Enums.InputAction.DOWN),
		)
		. normalized()
	)

	_impulse = _raw_input
	if _impulse != Vector2.ZERO:
		# figure out what the final impulse is based on the push/pull walk state

		if _move_mode == Enums.MoveMode.PUSH_PULL:
			# not changing the facing or direction because we're moving something and
			# those remain fixed until state change
			var axis := Enums.direction_push_pull_axis(_push_direction)
			_impulse = _impulse * axis

			if _is_push(_impulse, _push_direction):
				_pinjoint.node_b = ""
			else:
				_pinjoint.node_b = _target.get_moveable_block().get_path()

		else:
			_facing = Vector2.UP.angle_to(_impulse)
			_direction = Utils.angle_to_direction(_facing)

	_interaction_sensor.rotation = _facing

	if _event.is_action_pressed(Enums.input_action_name(Enums.InputAction.INTERACT)):
		if _target.is_interactable():
			_target.get_interactable().trigger(self)

		if _target.is_moveable_block():
			if _move_mode == Enums.MoveMode.PUSH_PULL:
				# currently push/pull, stop
				_move_mode = Enums.MoveMode.WALK
				_pinjoint.node_b = ""
				_target.get_moveable_block().freeze = true
				# TODO(envy) - better toast management
				Driver.instance().get_hud().clear_toast()
			else:
				# start push/pull, set the push direction for subsequent logic
				_move_mode = Enums.MoveMode.PUSH_PULL
				_push_direction = Utils.angle_to_direction(_facing, Enums.DirectionMode.FOUR)
				_target.get_moveable_block().freeze = false
				# TODO(envy) - better toast management
				Driver.instance().get_hud().set_toast("release")


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

	if !animation_correct || !_sprite.is_playing():
		_sprite.play(want_anim)

	var scale := move_speed
	if _move_mode == Enums.MoveMode.PUSH_PULL:
		if !_is_push(_impulse, _push_direction):
			scale = move_speed / 2

	velocity = _impulse * scale
	move_and_slide()

	# janky push/pull logic
	if _move_mode == Enums.MoveMode.PUSH_PULL:
		var collision_count := get_slide_collision_count()
		for c in range(0, collision_count):
			var cdata := get_slide_collision(c)
			var collider := cdata.get_collider()

			# if we're handling collision with the target and it's not frozen then
			# we should apply force. We unfreeze outside the physics loop when we
			# determine movement direction because it worked better (or maybe at
			# all, I don't recall at this point)
			if collider == _target.get_moveable_block() && !collider.freeze:
				collider.apply_central_force(_impulse * push_force)
				# we can only push one item so bail
				break


func _on_interaction_sensor_entered(area: Area2D) -> void:
	# while we're pushing and pulling don't let our focus change
	if _move_mode == Enums.MoveMode.PUSH_PULL:
		return

	if area is Interactable:
		var i := area as Interactable
		if i.automatic:
			i.trigger(self)
		else:
			_target.update(area)

	if area.get_parent() is MoveableBlock:
		_target.update(area.get_parent())


func _on_interaction_sensor_exited(area: Area2D) -> void:
	# while we're pushing and pulling don't let our focus change
	if _move_mode == Enums.MoveMode.PUSH_PULL:
		return

	if area is Interactable:
		if _target.get_interactable() == area:
			_target.reset()
	if area.get_parent() is MoveableBlock:
		if _target.get_moveable_block() == area.get_parent():
			_target.reset()


func _handle_target_changed() -> void:
	if !player_controled:
		return

	print("%s - _handle_target_changed -> %s" % [name, _target])
	# TODO(envy) - better toast management
	var hud := Driver.instance().get_hud()
	if _target.is_set():
		if _target.is_interactable():
			hud.set_toast("interact")
		if _target.is_moveable_block():
				hud.set_toast("push/pull")
	else:
		hud.clear_toast()


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


func _is_push(v: Vector2, push_direction: Enums.Direction) -> bool:
	var axis := Enums.direction_push_pull_axis(push_direction)
	var push_vec := Enums.direction_vector(push_direction)
	# normalize direction to the axis
	v = (v * axis).normalized()
	return v == push_vec
