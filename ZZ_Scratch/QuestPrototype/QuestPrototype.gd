extends Node2D

@onready var journal : Control = $CanvasLayer/Journal

func _unhandled_input(event:InputEvent)->void:
	if event is InputEventKey:
		if event.is_action_pressed(Enums.input_action_name(Enums.InputAction.OPEN_JOURNAL)) :
			if journal.visible:
				journal.hide()
			else:
				journal.show()
