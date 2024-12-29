@tool

class_name Character
extends CharacterBody2D

## Unique ID used in our design systems
@export var id: String = ""

## When set to true the game will have a circle drawn at the character's origin
@export var _debug_draw_origin: bool = false

## Set to specify what controls this character's behavior, if none specified
## a default noop controller will be used.
@export var _controller_node_path: NodePath

## When set to false this will disable the monitoring state of the sensors
## a character uses to interact with the exterior world, e.g., use items /
## push/pull things. No checking is done to ensure it's safe to switch state
## when this is changed / mostly intended as an edit time setting.
@export var activate_external_sensors: bool = true:
	set = _set_activate_external_sensors

## direction represented as an angle off Vector2.UP; in radians / [-TAU, TAU]
var facing: float = 0

## target is a type safe container for anything that the player may focus to
## interact with.
## TODO: post state machine rewrite we lose the ability to trivially check
## the current state and not switch target when the character is in a push_pull
## mode (because that exists as a function of the state machine which isn't
## available at this abstraction level). As a result it means we have a bug where
## the target shifts mid-push/pull and we can get kicked out surprisingly.
## In order to fix we'll likely need to rework the target system to not be a
## single target and let the state transition logic handle precedence. As it
## stands though the new bug is better than the old state that had push/pull
## bugs _and_ was a shitty factoring for state management in the Character.
var target: CharacterTarget = CharacterTarget.none()

## resolved node from _controller_node_path
var _controller: ControllerBase

@onready var stats: StatCollection = $Stats

# component cache
@onready var _sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var _sensor_group: Node2D = $SensorSet
@onready var _interaction_sensor: Area2D = $SensorSet/InteractionSensor
@onready var _push_pull_sensor: Area2D = $SensorSet/PushPullSensor
@onready var _state_machine: StateMachine = $StateMachine


func _ready() -> void:
	queue_redraw()
	if Engine.is_editor_hint():
		return
	target.target_changed.connect(Callable(self, "_handle_target_changed"))
	var ctx := StateMachine.CharacterContext.new()
	ctx.character = self
	if _controller_node_path != null:
		_controller = get_node(_controller_node_path)
		# TODO: .setup here isn't in the ControllerBase interface, need better
		# config process; for now rely on duck typing
		ctx.controller = _controller
		(
			_controller
			. setup(
				[
					Enums.InputAction.LEFT,
					Enums.InputAction.RIGHT,
					Enums.InputAction.UP,
					Enums.InputAction.DOWN,
				],
				[
					Enums.InputAction.INTERACT,
					Enums.InputAction.SPRINT,
				],
			)
		)
	else:
		if id == Utils.PLAYER_ID:
			printerr("_controller is null, potentially unexpected, using noop fallback")
		_controller = ControllerBase.new()
		ctx.controller = _controller

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


# region sensor / target management


func _on_interaction_sensor_entered(area: Area2D) -> void:
	if area is Interactable:
		target.update(area)


func _on_interaction_sensor_exited(area: Area2D) -> void:
	if area is Interactable:
		if target.get_interactable() == area:
			target.reset()


func _on_pushpull_sensor_entered(area: Area2D) -> void:
	if area.get_parent() is MoveableBlock:
		target.update(area.get_parent())


func _on_pushpull_sensor_exited(area: Area2D) -> void:
	if area.get_parent() is MoveableBlock:
		if target.get_moveable_block() == area.get_parent():
			target.reset()


func _handle_target_changed() -> void:
	# print("%s - _handle_target_changed -> %s" % [name, target])
	# TODO(envy) - better toast management
	var hud := Driver.instance().get_hud()
	if target.is_set():
		if target.is_interactable():
			hud.set_toast(target.get_interactable().verb_name())
		if target.is_moveable_block():
			hud.set_toast(Enums.action_verb_name(Enums.ActionVerb.PUSH_PULL))
	else:
		hud.clear_toast()


# end region sensor / target management

# region save/load
## TODO
func save() -> Dictionary:
	return {}


func load(data: Dictionary) -> void:
	pass
# end region save/load


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

	if _controller_node_path == null || !has_node(_controller_node_path):
		errs.append("Controller Node Path must be set to respond to input or use State Machines")
	elif !(get_node(_controller_node_path) is ControllerBase):
		errs.append("Controller Node Path must reference a ControllerBase or subclass")

	return errs


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
