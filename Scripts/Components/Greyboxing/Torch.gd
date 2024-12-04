@tool
class_name Torch
extends Node2D

@export_category("Lighting")
@export var light_color: Color = Color.WHITE:
	set(value):
		light_color = value
		_sync_light()

@export var light_energy: float = 1.0:
	set(value):
		light_energy = value
		_sync_light()

@export var light_size: float = 1:
	set(value):
		light_size = value
		_sync_light()

@export var light_texture: Texture2D = null:
	set(value):
		light_texture = value
		_sync_light()

@export_category("Visual")
@export var display_height: int:
	set(value):
		display_height = value
		_sync_height()

@export_subgroup("Static Sprite")
@export var sprite_texture: Texture2D = null:
	set(value):
		sprite_texture = value
		_sync_visuals()

@export_subgroup("Animated Sprite")
@export var sprite_frames: SpriteFrames = null:
	set(value):
		sprite_frames = value
		_sync_visuals()

@export var speed_scale: float = 1:
	set(value):
		speed_scale = value
		_sync_visuals()

var _point_light_2d: PointLight2D
var _sprite_2d: Sprite2D
var _animated_sprite: AnimatedSprite2D


func _ready() -> void:
	# taking this approach because we need access as a @tool script and @onready
	# doesn't run but _ready does
	_point_light_2d = get_node("PointLight2D")
	_sprite_2d = get_node("Sprite2D")
	_animated_sprite = get_node("AnimatedSprite2D")
	_sync_visuals()
	_sync_light()


func _sync_height() -> void:
	var offset_vec := display_height_offset()
	if _sprite_2d != null:
		_sprite_2d.offset = offset_vec
	if _animated_sprite != null:
		_animated_sprite.offset = offset_vec
	if _point_light_2d != null:
		_point_light_2d.offset = offset_vec


func _sync_light() -> void:
	if _point_light_2d == null:
		return

	_point_light_2d.energy = light_energy
	_point_light_2d.texture_scale = light_size * 2
	_point_light_2d.color = light_color
	_point_light_2d.texture = light_texture


func _sync_visuals() -> void:
	if sprite_texture != null && _sprite_2d != null:
		_sprite_2d.texture = (sprite_texture as Texture2D)
		_sprite_2d.show()

	if sprite_frames != null && _animated_sprite != null:
		_animated_sprite.sprite_frames = sprite_frames
		_animated_sprite.speed_scale = speed_scale
		_animated_sprite.show()
		if _sprite_2d != null:
			_sprite_2d.hide()

	_sync_height()


func display_height_offset() -> Vector2:
	return Vector2(0, -1 * ((display_height * 32) - 16))


func is_lit() -> bool:
	return _point_light_2d.enabled


func toggle(on: bool) -> void:
	_point_light_2d.enabled = on
