extends Menu


func _enter_tree() -> void:
	Driver.instance().pause(true)


func _exit_tree() -> void:
	Driver.instance().pause(false)


func _input(_event: InputEvent) -> void:
	if (
		Input
		. is_action_just_pressed(
			Enums.input_action_name(Enums.InputAction.MENU),
		)
	):
		dismiss.emit()
