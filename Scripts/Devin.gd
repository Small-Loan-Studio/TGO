@tool

class_name Devin
extends Character

@onready var _lamp: Lamp = $Lamp

func _physics_process(delta: float) -> void:
	# ignore private method call because we need Character's physics logic as well
	# gdlint:ignore = private-method-call
	super._physics_process(delta)
	if _lamp != null:
		_lamp.face(_facing)


func _on_interaction_sensor_entered(area: Area2D) -> void:
	if area is Interactable:
		print('found interactable ' + area.name + ' / ' + area.get_parent().name)

func _on_interaction_sensor_exited(area: Area2D) -> void:
	if area is Interactable:
		print('lost interactable ' + area.name + ' / ' + area.get_parent().name)