extends Label


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	text = Driver.instance().player._state_machine.cur_state().name


func _on_toggle_track_state_changes(toggled_on: bool) -> void:
	Driver.instance().player._state_machine.print_state_changes = toggled_on
