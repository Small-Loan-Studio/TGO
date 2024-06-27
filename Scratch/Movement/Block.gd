@tool

extends Sprite2D

@export var is_background := false:
	get:
		return is_background
	set(new_v):
		print('aoeu')
		is_background = new_v
		if new_v:
			z_index = -1000
		else:
			z_index = 0

@export var blocks_light := false
@export var blocks_movement := true

# component cache
@onready var _rigid_body := $RigidBody2D
@onready var _collision_shape := $RigidBody2D/CollisionShape2D
@onready var _occluder := $LightOccluder2D

func _ready() -> void:
	if blocks_movement:
		_setup_rigid_body()
	else:
		remove_child(_rigid_body)
	# _compute_offset()

func _compute_offset() -> void:
	var cur_pos := position
	var half_height := cur_pos.y / 2
	cur_pos.y += half_height
	offset.y -= half_height

func _setup_rigid_body() -> void:
	var rect := RectangleShape2D.new()
	rect.size = texture.get_size() * scale
	_collision_shape.shape = rect