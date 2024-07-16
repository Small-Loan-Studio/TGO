extends Node2D

# Exported variable for the label text
@export var box_label_text: String = ""

@onready var label: Label = $BoxLabel
@onready var sprite: Sprite2D = $BoxSprite

func _ready() -> void:
	update_label_text()
	center_label()

# This function ensures the label text is updated
func update_label_text() -> void:
	if label:
		label.text = box_label_text
		label.visible = true

# This function centers the label on the GrayBox
func center_label() -> void:
	if label and sprite:
		var label_size: Vector2 = label.get_minimum_size()
		var sprite_size: Vector2 = sprite.texture.get_size()
		label.position = Vector2(sprite_size.x / 2, sprite_size.y / 2)

# Ensure the label is updated during editing
func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		update_label_text()
		center_label()
		label.show()  # Ensure the label is visible in the editor
