@tool

class_name GreyboxObject
extends Node2D

@export_category("Functionality")
@export var can_block_movement: bool = true:
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

@export var can_interact: bool = true:
	get:
		return can_interact
	set(value):
		can_interact = value
		_process_can_interact_update()


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
	if has_node("Display"):
		_display = get_node("Display")
	if has_node("Physics"):
		_physics = get_node("Physics")
	if has_node("Interactable"):
		_interactable = get_node("Interactable")
	if has_node("Light"):
		_light = get_node("Light")

	if Engine.is_editor_hint():
		get_parent().set_editable_instance(self, true)
		can_block_movement = false
		can_block_light = false
		can_interact = false
		_update_collider_display()

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
	if !Engine.is_editor_hint():
		printerr("May not change movement blocking at runtime")
		return

	if can_block_movement:
		if _physics != null:
			# already has a physics body
			return
		_physics = RigidBody2D.new()
		add_child(_physics)
		_physics.owner = self
		_physics.name = "Physics"
		_physics.collision_layer = 1
		_physics.collision_mask = 0
		var shape := CollisionShape2D.new()
		_physics.add_child(shape)
		shape.owner = self
		shape.name = "Shape"
		# reset collision shape display just to make sure things stay in sync
		_display_collision_shapes = true
	else:
		if _physics == null:
			# already doesn't have a physics body
			return
		remove_child(_physics)
		_physics.queue_free()
		_physics = null

	_sync_occluder()


func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		_sync_occluder()
		_sync_display()


func _process_can_interact_update() -> void:
	if !Engine.is_editor_hint():
		printerr("May not change movement blocking at runtime")
		return
	if can_interact:
		if _interactable != null:
			# already has an interactable object
			return

		_interactable = Interactable.new()
		add_child(_interactable)
		_interactable.owner = self
		_interactable.name = "Interactable"
		_interactable.collision_layer = 2
		_interactable.collision_mask = 0
		var shape := CollisionShape2D.new()
		_interactable.add_child(shape)
		shape.owner = self
		shape.name = "Shape"
		# reset collision shape display just to make sure things stay in sync
		_display_interaction_shapes = true
	else:
		if _interactable == null:
			# already doesn't have an interactioble object
			return
		remove_child(_interactable)
		_interactable.queue_free()
		_interactable = null


func _process_light_update() -> void:
	if !Engine.is_editor_hint():
		printerr("May not change light occlusion at runtime")
		return

	if !can_block_light:
		if !_light == null:
			remove_child(_light)
			_light.queue_free()
			_light = null
	else:
		if _light == null:
			_light = LightOccluder2D.new()
			_light.light_mask = 1
			_light.occluder_light_mask = 2
			_light.show_behind_parent = true
			_light.name = "Light"
			add_child(_light)
			_light.owner = self
		_sync_occluder()


func _sync_occluder() -> void:
	if _light == null:
		return

	if _physics == null:
		return

	var physics_shape: CollisionShape2D = _physics.get_node("Shape")
	if physics_shape == null || physics_shape.shape == null:
		return

	var collider_shape: Shape2D = physics_shape.shape
	print('ugh this will be a pain in the ass bc there are many different shape subclasses')
	print(collider_shape)

	_light.occluder = OccluderPolygon2D.new()
	_light.occluder.polygon = PackedVector2Array()
	_light.occluder.closed = true
	_light.occluder.cull_mode = OccluderPolygon2D.CULL_CLOCKWISE


func _sync_display() -> void:
	if !Engine.is_editor_hint:
		return

	if _display.position != Vector2.ZERO:
		_display.offset = _display.position
		_display.position = Vector2.ZERO
