@tool

class_name Torch
extends Node2D

@export_category("Lighting")
@export var light_color: Color = Color.WHITE:
	get:
		return light_color
	set(value):
		light_color = value
		_change_light_color(light_color)
@export var light_energy: float = 1.0:
	get:
		return light_energy
	set(value):
		light_energy = value
		_change_light_energy(light_energy)
@export var light_size: float = 0.75:
	get:
		return light_size
	set(value):
		light_size = value
		_change_light_size(light_size)
@export var light_texture: Texture2D = null:
	get:
		return light_texture
	set(value):
		light_texture = value
		_change_light_texture(light_texture)

@export_category("Sprite")
@export var sprite_texture: Texture = null:
	get:
		return sprite_texture
	set(value):
		sprite_texture = value
		_change_sprite_texture(sprite_texture)
@export_subgroup("Animated Sprite")
@export var sprite_frames: SpriteFrames = null:
	get:
		return sprite_frames
	set(value):
		sprite_frames = value
		_change_sprite_frames(sprite_frames)
@export var speed_scale: float = 1:
	get:
		return speed_scale
	set(value):
		speed_scale = value
		_change_speed_scale(speed_scale)

@onready var _point_light_2d: PointLight2D = $PointLight2D
@onready var _sprite_2d: Sprite2D = $Sprite2D
@onready var _animated_sprite: AnimatedSprite2D = $AnimatedSprite2D


func _toggle() -> void:
	_point_light_2d.visible = !_point_light_2d.visible
	print(_point_light_2d.visible)


func _change_light_color(new_color: Color) -> void:
	if _point_light_2d != null:
		_point_light_2d.color = new_color


func _change_light_energy(new_energy: float) -> void:
	if _point_light_2d != null:
		_point_light_2d.energy = new_energy


func _change_light_size(new_size: float) -> void:
	if _point_light_2d != null:
		_point_light_2d.texture_scale = new_size


func _change_light_texture(new_texture: Texture) -> void:
	if _point_light_2d != null:
		_point_light_2d.texture = new_texture


func _change_sprite_texture(new_texture: Texture) -> void:
	if _sprite_2d != null:
		_sprite_2d.texture = new_texture


func _change_sprite_frames(new_frames: SpriteFrames) -> void:
	if _animated_sprite != null:
		_animated_sprite.sprite_frames = new_frames


func _change_speed_scale(new_scale: float) -> void:
	if _animated_sprite != null:
		_animated_sprite.speed_scale = new_scale
