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

@onready var _physics: RigidBody2D = $Physics
@onready var _interactable: Interactable = $Interactable


func _ready() -> void:
	if Engine.is_editor_hint():
		get_parent().set_editable_instance(self, true)
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


## TODO: update mask / layer shit for rigid body and interactable below


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
