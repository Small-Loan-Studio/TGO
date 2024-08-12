@tool
extends Node2D

@export var item: Item

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var instance: Node2D = item.scene.instantiate()
	add_child(instance)
