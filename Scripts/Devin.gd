@tool

class_name Devin
extends Character

## If set this will hide the lamp sensor radius while in editor. Has no effect
## during gameplay.
@export var editor_hide_lamp_sensors: bool:
	set = _set_editor_hide_lamp,
	get = _get_editor_hide_lamp

## Unique ID not shared by any other object for use in other systems (only Inventory atm)
var id: String = "Devin"

@onready var _lamp: Lamp = $Lamp

func _physics_process(delta: float) -> void:
	# ignore private method call because we need Character's physics logic as well
	# gdlint:ignore = private-method-call
	super._physics_process(delta)
	if _lamp != null:
		_lamp.face(_facing)


func _set_editor_hide_lamp(new_v: bool) -> void:
	editor_hide_lamp_sensors = new_v
	if Engine.is_editor_hint():
		# Reaching into the lamp here is bad practice. Letting it slide because this is
		# only ever run in the editor so it didn't make a ton of sense to expose this
		# as a configuration on the Lamp that could be more broadly used.
		var lamp: Node2D = null
		for c in get_children(true):
			if c.name == "Lamp":
				lamp = c
		if lamp != null:
			$Lamp/Beam.visible = !editor_hide_lamp_sensors
			$Lamp/Beam2.visible = !editor_hide_lamp_sensors
			$Lamp/Beam3.visible = !editor_hide_lamp_sensors


func _get_editor_hide_lamp() -> bool:
	return editor_hide_lamp_sensors
