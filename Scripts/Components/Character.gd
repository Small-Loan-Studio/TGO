@tool

class_name Character
extends CharacterBody2D

# emitted when this character equips or unequips an item in any GearSlot
signal equipment_changed(id: String)

## Unique ID used in our design systems
@export var id: String = ""

## When set to true the game will have a circle drawn at the character's origin
@export var _debug_draw_origin: bool = false

## Set to specify what controls this character's behavior, if none specified
## a default noop controller will be used.
@export var _controller_node_path: NodePath

## What items does this character have equipped?
## Map[Enums.GearSlot, Item]
@export var _equipment: Dictionary = {}

## Whether or not this character should register themselves with Wwise
@export var _has_audio_node: bool

## When set to false this will disable the monitoring state of the sensors
## a character uses to interact with the exterior world, e.g., use items /
## push/pull things. No checking is done to ensure it's safe to switch state
## when this is changed / mostly intended as an edit time setting.
@export var activate_external_sensors: bool = true:
	set = _set_activate_external_sensors

## direction represented as an angle off Vector2.UP; in radians / [-TAU, TAU]
var facing: float = 0

# FIXME: This is not robust...
var size: Vector2:
	get:
		var sprite: Sprite2D = self.find_child("Sprite2D")
		if sprite:
			return sprite.get_rect().position
		var asprite: AnimatedSprite2D = self.find_child("AnimatedSprite2D")
		if asprite:
			var animation_names := asprite.sprite_frames.get_animation_names()
			if len(animation_names) > 0:
				return asprite.sprite_frames.get_frame_texture(animation_names[0], 0).get_size()
		return Vector2(0, 0)

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

## holds the last reported map coords for this character's environment material
var _mat_pos_last_reported := Vector2i.ZERO

## holds the last reported material, this is used only to determine whether to
## update the wwise character material switch
var _last_mat := ""

@onready var stats: StatCollection = $Stats

# component cache
@onready var _sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var _sensor_group: Node2D = $SensorSet
@onready var _interaction_sensor: Area2D = $SensorSet/InteractionSensor
@onready var _push_pull_sensor: Area2D = $SensorSet/PushPullSensor
@onready var _state_machine: StateMachine = $StateMachine
@onready var _audio_node: AudioNode = $AudioNode


func _ready() -> void:
	queue_redraw()
	if Engine.is_editor_hint():
		return
	target.target_changed.connect(Callable(self, "_handle_target_changed"))
	var ctx := StateMachine.CharacterContext.new()
	ctx.character = self
	if _controller_node_path != null && !_controller_node_path.is_empty():
		_controller = get_node(_controller_node_path)

	if _controller != null:
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
					Enums.InputAction.LEFT,
					Enums.InputAction.RIGHT,
					Enums.InputAction.UP,
					Enums.InputAction.DOWN,
					Enums.InputAction.DEFAULT,
					Enums.InputAction.SECONDARY,
					Enums.InputAction.INTERACT_CANCEL,
					Enums.InputAction.SPRINT,
					Enums.InputAction.MENU,
					Enums.InputAction.LEFT_ITEM,
					Enums.InputAction.RIGHT_ITEM,
				],
			)
		)
	else:
		if id == Utils.PLAYER_ID:
			printerr("_controller is null, potentially unexpected, using noop fallback")
			_controller = ControllerBase.new()
			ctx.controller = _controller

	if !_has_audio_node || id == "":
		if _has_audio_node:
			printerr(
				(
					"%s: Not registering character that wants to be an AudioNode because it has no ID"
					% [name]
				)
			)
		_audio_node.queue_free()
		remove_child(_audio_node)
		_audio_node = null
	else:
		if id != "":
			_audio_node.setup(self, id)
			_audio_node.track_position = true
			if _state_machine != null:
				_state_machine.enter.connect(_on_state_enter)

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

	if !_state_machine.input_exclusive():
		if _controller != null:
			if _controller.just_pressed(Enums.InputAction.LEFT_ITEM):
				use_item(Enums.GearSlot.LEFT)
			if _controller.just_pressed(Enums.InputAction.RIGHT_ITEM):
				use_item(Enums.GearSlot.RIGHT)

	_maybe_report_env_material()


#region sensor / target managementregion
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
	# TODO(envy) - better toast management
	# print("%s - _handle_target_changed -> %s" % [name, target])
	var hud := Driver.instance().get_hud()
	if target.is_set():
		if target.is_interactable():
			hud.set_toast(target.get_interactable().verb_name())
		if target.is_moveable_block():
			hud.set_toast(Enums.action_verb_name(Enums.ActionVerb.PUSH_PULL))
	else:
		hud.clear_toast()


#endregion


# region save/load
func save() -> Dictionary:
	return {
		"position": [global_position.x, global_position.y],
		"stats": stats.save(),
		"gear": _save_gear(),
	}


func load(data: Dictionary) -> void:
	# clear all equipment before loading
	for slot: Enums.GearSlot in _equipment:
		unequip(slot)
	var pos_x: float = data["position"][0]
	var pos_y: float = data["position"][1]
	global_position = Vector2(pos_x, pos_y)
	var stats_arr: Array[Dictionary] = []
	stats_arr.assign(data["stats"])
	stats.load(stats_arr)
	_load_gear(data["gear"])


# endregion


#region equipment
# attempts to equip some item into some gear slot. Returns true on success
# and false on failure.
func equip(slot: Enums.GearSlot, item: Item) -> bool:
	print("equip(%s, %s) - Current equip load: %s" % [slot, item.id, _equipment])
	# TODO: we should let equipping something unequip the previous item
	if _equipment.has(slot):
		return false

	if item.type != Enums.ItemType.EQUIPPABLE:
		return false

	_equipment[slot] = item
	if item.gear_spec != null:
		for gs in item.gear_spec:
			gs.on_equip(self)
	equipment_changed.emit(id)
	return true


func in_slot(slot: Enums.GearSlot) -> Item:
	return _equipment.get(slot, null)


func is_equipped(item: Item) -> bool:
	for slot: Enums.GearSlot in _equipment:
		var gear: Item = _equipment[slot]
		if gear != null && gear.id == item.id:
			return true
	return false


# removes equipment from slot, if any is present.
func unequip(slot: Enums.GearSlot) -> void:
	print("unequip(%s) - Current equip load: %s" % [slot, _equipment])
	if !_equipment.has(slot):
		return

	var old_gear: Item = _equipment[slot]
	var spec := old_gear.gear_spec
	_equipment.erase(slot)

	if spec != null:
		for gs in spec:
			gs.on_remove(self)

	equipment_changed.emit(id)


func use_item(slot: Enums.GearSlot) -> void:
	var equipment: Item = _equipment.get(slot, null)
	if equipment == null:
		printerr("Nothing equipped in %s" % [Enums.gear_slot_name(slot)])
		return
	if len(equipment.gear_spec) == 0:
		printerr("Gear has no specs attached")
		return
	for gs in equipment.gear_spec:
		gs.on_use(self)


# returns Map[GearSlot_name:String, item_state:Array[Variant]]
func _save_gear() -> Dictionary:
	var eq_state := {}
	for slot: Enums.GearSlot in _equipment:
		var item: Item = _equipment[slot]
		eq_state[Enums.gear_slot_name(slot)] = item.save_state(self)
	return eq_state


func _load_gear(data: Dictionary) -> void:
	if data == null:
		return

	for slot_name: String in data:
		var slot := Enums.gear_slot_from_str(slot_name)
		var data_array: Array[Variant] = data[slot_name]
		var path: String = data_array[0]
		var item := ResourceLoader.load(path) as Item
		if item == null:
			printerr("Unable to create equipment from: %s" % [path])
			continue
		equip(slot, item)
		item.restore_state(self, data_array.slice(1))
		equipment_changed.emit(id)


#endregion


#region audio
func is_audio_object() -> bool:
	return _audio_node != null


func audio_node() -> AudioNode:
	return _audio_node


func _on_state_enter(state_name: String) -> void:
	if !is_audio_object():
		return

	var sw_name := "%s_StateSwitch" % [id.to_lower()]
	var sw_value := state_name.to_lower()
	_audio_node.safely_set_switch(sw_name, sw_value)


func _maybe_report_env_material() -> void:
	# can't process this until the node's _ready has completed because that's
	# where we clean up or configure the audio node
	if !is_node_ready():
		return

	if _audio_node == null:
		return

	var cur_level := _level()
	if cur_level == null:
		return

	var coords := get_map_coords()
	if _mat_pos_last_reported == coords:
		return
	_mat_pos_last_reported = coords

	var mat := cur_level.get_tile_material(coords)
	if mat != "" && mat != _last_mat:
		_audio_node.set_switch("GroundMaterialSwitch", mat)
		_last_mat = mat


#endregion


#region logistics / introspection to the game world
## get the character's position within the current level's tilemap.
## Returns Vector2.ZERO if the level is null
func get_map_coords() -> Vector2i:
	var cur_level := _level()
	if cur_level == null:
		return Vector2i.ZERO
	return cur_level.get_map_coords(global_position)


func _level() -> LevelBase:
	var driver := Driver.instance()
	if driver != null:
		return driver.get_current_level()
	return null


#endregion


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

	if _has_audio_node && id == "":
		errs.append("Characters with audio nodes must have an ID")

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
