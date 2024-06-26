@tool

extends Node2D

var _editor_sprite: Sprite2D = null

@export var _animated_sprite: AnimatedSprite2D:
	get:
		return _animated_sprite
	set(new_value):
		_animated_sprite = new_value
		if Engine.is_editor_hint():
			if (new_value == null):
				var names := new_value.sprite_frames.get_animation_names()
				var tex := new_value.sprite_frames.get_frame_texture(names[0], 0)
				if tex != null:
					if _editor_sprite != null:
						remove_child(_editor_sprite)
					_editor_sprite = Sprite2D.new()
					_editor_sprite.texture = tex
					add_child(_editor_sprite)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if Engine.is_editor_hint():
		print('running in-editor')
	pass # Replace with function body.



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _get_configuration_warnings() -> PackedStringArray:
	if _animated_sprite == null:
		return ["Characters require animated sprites to function correctly."]
	return []