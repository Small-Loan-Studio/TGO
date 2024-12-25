@tool

class_name Character
extends CharacterBody2D

## When set to true the game will have a circle drawn at the character's origin
@export var _debug_draw_origin: bool = false

## Unique ID used in our design systems
@export var id: String = ""

## Set this to make the character be controlled by player input
@export var player_controled: bool = false

## This controls player movement speed in pixels/sec
@export var move_speed: int = 250

## The amonut of force the character has to push objects
@export var push_force: int = 200

## When set to false this will disable the monitoring state of the sensors
## a character uses to interact with the exterior world, e.g., use items /
## push/pull things. No checking is done to ensure it's safe to switch state
## when this is changed / mostly intended as an edit time setting.
@export var activate_external_sensors: bool = true:
	set = _set_activate_external_sensors

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
@onready var _sensor_group: Node2D = $SensorSet
@onready var _interaction_sensor: Area2D = $SensorSet/InteractionSensor
@onready var _push_pull_sensor: Area2D = $SensorSet/PushPullSensor
@onready var _pinjoint: PinJoint2D = $PinJoint2D
@onready var _state_machine: StateMachine = $StateMachine

# Character.gd - assigned to specify what controls this character
@export var _controller: ControllerBase


func _ready() -> void:
	queue_redraw()
	if Engine.is_editor_hint():
		return
	_target.target_changed.connect(Callable(self, "_handle_target_changed"))
	var ctx := StateMachine.CharacterContext.new()
	ctx.character = self
	if _controller != null:
		ctx.controller = _controller
	else:
		if id == Utils.PLAYER_ID:
			printerr("_controller is null, potentially unexpected, using noop fallback")
		_controller = ControllerBase.new()
		ctx.controller = _controller

	_controller.setup(
		[ Enums.InputAction.LEFT,
			Enums.InputAction.RIGHT,
			Enums.InputAction.UP,
			Enums.InputAction.DOWN,
		],
		[
			Enums.InputAction.INTERACT,
		],
	)
	_state_machine.setup(ctx)


func _draw() -> void:
	if _debug_draw_origin:
		draw_circle(Vector2.ZERO, 3, Color.GREEN)


func _unhandled_input(event: InputEvent) -> void:
	_state_machine.run_input(event)

func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint():
		return

	_state_machine.run_physics(delta)


func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		return

	_state_machine.run_tick(delta)


func _on_interaction_sensor_entered(area: Area2D) -> void:
	if area is Interactable:
		var i := area as Interactable
		if i.automatic:
			_target.update(area)
		else:
			_target.update(area)


func _on_interaction_sensor_exited(area: Area2D) -> void:
	# while we're pushing and pulling don't let our focus change
	if _move_mode == Enums.MoveMode.PUSH_PULL:
		return

	if area is Interactable:
		if _target.get_interactable() == area:
			_target.reset()


func _on_pushpull_sensor_entered(area: Area2D) -> void:
	# while we're pushing and pulling don't let our focus change
	if _move_mode == Enums.MoveMode.PUSH_PULL:
		return

	if area.get_parent() is MoveableBlock:
		_target.update(area.get_parent())


func _on_pushpull_sensor_exited(area: Area2D) -> void:
	if area.get_parent() is MoveableBlock:
		if _target.get_moveable_block() == area.get_parent():
			_stop_pushpull()
			_target.reset()


func _handle_target_changed() -> void:
	if !player_controled:
		return

	# print("%s - _handle_target_changed -> %s" % [name, _target])
	# TODO(envy) - better toast management
	var hud := Driver.instance().get_hud()
	if _target.is_set():
		if _target.is_interactable():
			hud.set_toast(_target.get_interactable().verb_name())
		if _target.is_moveable_block():
			hud.set_toast(Enums.action_verb_name(Enums.ActionVerb.PUSH_PULL))
	else:
		hud.clear_toast()


func _get_configuration_warnings() -> PackedStringArray:
	var errs := []
	if _sprite.sprite_frames == null:
		errs.append("No sprite frames have been set on AnimatedSprite2D")
	else:
		var animations := _sprite.sprite_frames.get_animation_names()
		var missing_anims: Array[String] = []

		for da: Enums.Direction in Enums.Direction.values():
			var want_name := Enums.direction_name(da)
			if not want_name in animations:
				missing_anims.append(want_name)

		if missing_anims.size() > 0:
			errs.append("Missing expected animations in child sprite: " + str(missing_anims))

	var controller := get_children().filter(func (c: Node) -> bool: return c is ControllerBase)
	if len(controller) < 1:
		errs.append("No character controller: no way to respond to input")
	if len(controller) > 1:
		errs.append("Multiple controllers found as children, ambiguous control path")

	return errs


func _is_push(v: Vector2, push_direction: Enums.Direction) -> bool:
	var axis := Enums.direction_push_pull_axis(push_direction)
	var push_vec := Enums.direction_vector(push_direction)
	# normalize direction to the axis
	v = (v * axis).normalized()
	return v == push_vec


func _start_pushpull() -> void:
	if _move_mode == Enums.MoveMode.PUSH_PULL:
		return

	# start push/pull, set the push direction for subsequent logic
	_move_mode = Enums.MoveMode.PUSH_PULL
	_push_direction = Utils.angle_to_direction(_facing, Enums.DirectionMode.FOUR)
	_target.get_moveable_block().freeze = false
	# TODO(envy) - better toast management
	Driver.instance().get_hud().set_toast(Enums.action_verb_name(Enums.ActionVerb.RELEASE))


func _stop_pushpull() -> void:
	if _move_mode != Enums.MoveMode.PUSH_PULL:
		return

	_move_mode = Enums.MoveMode.WALK
	_pinjoint.node_b = ""
	_target.get_moveable_block().set_deferred("freeze", true)
	# TODO(envy) - better toast management
	Driver.instance().get_hud().clear_toast()


func _set_activate_external_sensors(value: bool) -> void:
	activate_external_sensors = value
	# need the null checks to prevent error spew during Editing
	if _interaction_sensor != null:
		_interaction_sensor.monitorable = value
		_interaction_sensor.monitoring = value
	if _push_pull_sensor != null:
		_push_pull_sensor.monitorable = value
		_push_pull_sensor.monitoring = value
	if _sensor_group != null:
		_sensor_group.visible = value
