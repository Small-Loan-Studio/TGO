@tool

class_name MoveableBlock
extends RigidBody2D

## The id of this moveable block if it needs to be referenced in the level
@export var id: String = ""

## The pixel size of a single unit of tile
@export var tile_size := 32

@export var width: int = 1:
	get:
		return width
	set(value):
		width = value
		_set_size(width, height)

@export var height: int = 1:
	get:
		return height
	set(value):
		height = value
		_set_size(width, height)

@onready var _sprite := $Sprite2D
@onready var _collider: CollisionShape2D = $Collider
@onready var _sensor_collider: CollisionShape2D = $SensorTargetArea/Collider


func _ready() -> void:
	_set_size(width, height)


func _process(_delta: float) -> void:
	if scale != Vector2.ONE:
		printerr("Moveable Blocks may not be scaled")
		scale = Vector2.ONE


func set_size(x: int, y: int) -> void:
	width = x
	height = y


func _set_size(x: int, y: int) -> void:
	# needs to be put under guard because width/height get populated during
	# object construction whcich happens before children are available
	if _collider != null && _sensor_collider != null && _sprite != null:
		_update_shape(_collider.shape as RectangleShape2D, x, y)
		_update_shape(_sensor_collider.shape as RectangleShape2D, x, y)
		_sprite.scale = Vector2(x, y)


func _update_shape(rect: RectangleShape2D, x: int, y: int) -> void:
	rect.size.x = x * tile_size
	rect.size.y = y * tile_size

func _get_configuration_warnings() -> PackedStringArray:
	# TODO: don't use a magic number here
	if collision_layer | 4:
		if id == "" || id == null:
			return ["This is a switch actor and may need an ID"]
	return []