@tool

class_name GreyboxObject
extends Node2D

const UNIT_SIZE = 32
const Y_SORT_BUFFER_LENGTH = 40
const DISPLAY_NODE = "Display"
const PHYSICS_NODE = "Physics"
const SHAPE_CHILD_NODE = "Shape"
const INTERACT_NODE = "Interactable"
const LIGHT_NODE = "Lighting"

@export_category("Core Configuration")
@export var size: Vector2 = Vector2(1, 1):
	get:
		return size
	set(value):
		size = value
		y_sort_width = Y_SORT_BUFFER_LENGTH + UNIT_SIZE * size.x
		_sync_all_shapes()

@export var can_block_movement: bool = false:
	get:
		return can_block_movement
	set(value):
		can_block_movement = value
		_process_can_block_movement_update()

@export var can_block_light: bool = false:
	get:
		return can_block_light
	set(value):
		can_block_light = value
		_process_light_update()

@export var can_interact: bool = false:
	get:
		return can_interact
	set(value):
		can_interact = value
		_process_can_interact_update()

@export_subgroup("Interactable Configuration")
@export var action_verb: Enums.ActionVerb = Enums.ActionVerb.DEFAULT
@export var effects: Array[Effect] = []

@export_category("Display Noise")
@export var _display_collision_shapes: bool = true:
	get:
		return _display_collision_shapes
	set(value):
		_display_collision_shapes = value
		_update_collider_display()

@export var _display_interaction_shapes: bool = true:
	get:
		return _display_interaction_shapes
	set(value):
		_display_interaction_shapes = value
		_update_collider_display()

@export_subgroup("Y Sort info")
@export var y_sort_width: int = 100:
	get:
		return y_sort_width
	set(value):
		y_sort_width = value
		queue_redraw()

@export var show_object_center: bool = true:
	get:
		return show_object_center
	set(value):
		show_object_center = value
		queue_redraw()

@export var show_y_sort_line: bool = true:
	get:
		return show_y_sort_line
	set(value):
		show_y_sort_line = value
		queue_redraw()

@export var debug_color: Color = Color.RED:
	get:
		return debug_color
	set(value):
		debug_color = value
		queue_redraw()

var _display: Sprite2D
var _physics: RigidBody2D
var _interactable: Interactable
var _light: LightOccluder2D


func _ready() -> void:
	# Not done via @onready because the may not all exist given the configurable
	# nature of the greybox object
	if has_node(DISPLAY_NODE):
		_display = get_node(DISPLAY_NODE)
	if has_node(PHYSICS_NODE):
		_physics = get_node(PHYSICS_NODE)
	if has_node(INTERACT_NODE):
		_interactable = get_node(INTERACT_NODE)
		_interactable.actions = effects
		_interactable.action_verb = action_verb
	if has_node(LIGHT_NODE):
		_light = get_node(LIGHT_NODE)

	_sync_all_shapes()


func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		_sync_all_shapes()


func _draw() -> void:
	if Engine.is_editor_hint():
		if show_y_sort_line:
			draw_line(Vector2(-y_sort_width / 2, 0), Vector2(y_sort_width / 2, 0), debug_color, 2)
		if show_object_center:
			draw_circle(Vector2.ZERO, 4, debug_color)


func _update_collider_display() -> void:
	var always_display := !Engine.is_editor_hint()
	if _physics != null:
		_physics.visible = always_display || _display_collision_shapes
	if _interactable != null:
		_interactable.visible = always_display || _display_interaction_shapes


func _process_can_block_movement_update() -> void:
	if !can_block_movement:
		if !has_node(PHYSICS_NODE):
			return
		var n := get_node(PHYSICS_NODE)
		n.queue_free()
		remove_child(n)
		_physics = null
		return

	if _physics == null:
		_physics = RigidBody2D.new()
		add_child(_physics)
		_physics.owner = self
		_physics.name = PHYSICS_NODE
		_physics.collision_layer = 1
		_physics.collision_mask = 0
		_physics.set_freeze_mode(1)  #sets freeze to kinematic
		var shape := CollisionShape2D.new()
		_physics.add_child(shape)
		shape.owner = self
		shape.name = SHAPE_CHILD_NODE
		# reset collision shape display just to make sure things stay in sync
		_display_collision_shapes = true

	_sync_collision_shape()


func _process_can_interact_update() -> void:
	if !can_interact:
		if !has_node(INTERACT_NODE):
			return
		var inode := get_node(INTERACT_NODE)
		remove_child(inode)
		inode.queue_free()
		_interactable = null
		return

	_interactable = Interactable.new()
	add_child(_interactable)
	_interactable.owner = self
	_interactable.name = INTERACT_NODE
	_interactable.collision_layer = 2
	_interactable.collision_mask = 0
	var shape := CollisionShape2D.new()
	_interactable.add_child(shape)
	shape.owner = self
	shape.name = SHAPE_CHILD_NODE
	_display_interaction_shapes = true

	_sync_all_shapes()


func _process_light_update() -> void:
	if !can_block_light:
		if !_light == null:
			remove_child(_light)
			_light.queue_free()
			_light = null
		return

	if _light == null:
		_light = LightOccluder2D.new()
		_light.light_mask = 1
		_light.occluder_light_mask = 2
		_light.show_behind_parent = true
		_light.name = "Light"
		add_child(_light)
		_light.owner = self

	_sync_all_shapes()


func _sync_all_shapes() -> void:
	if _display != null:
		_sync_display()
	if _physics != null:
		_sync_collision_shape()
	if _light != null:
		_sync_occluder()
	if _interactable != null:
		_sync_interactable()


func _sync_collision_shape() -> void:
	var pshape := _physics.get_node(SHAPE_CHILD_NODE)
	pshape.shape = RectangleShape2D.new()
	pshape.shape.size = (UNIT_SIZE * size)
	pshape.position = Vector2(0, _get_y_offset())


func _sync_occluder() -> void:
	if _light == null:
		return

	if _light.occluder == null:
		_light.occluder = OccluderPolygon2D.new()
	var oc := _light.occluder
	oc.closed = true
	oc.cull_mode = OccluderPolygon2D.CULL_CLOCKWISE
	var x := UNIT_SIZE * (size.x / 2)
	var y := UNIT_SIZE * (size.y / 2)
	var y_off := _get_y_offset()
	oc.polygon = [
		Vector2(-x, -y + y_off),
		Vector2(x, -y + y_off),
		Vector2(x, y + y_off),
		Vector2(-x, y + y_off),
	]


func _sync_interactable() -> void:
	if _interactable == null:
		return

	var ishape := _interactable.get_node(SHAPE_CHILD_NODE)
	ishape.shape = RectangleShape2D.new()
	ishape.shape.size = (UNIT_SIZE * size)
	ishape.position = Vector2(0, _get_y_offset())


func _get_y_offset() -> int:
	return 2 - (UNIT_SIZE * size.y) / 2

func _sync_display() -> void:
	_display.scale = size
	_display.offset.y = _get_y_offset() / size.y