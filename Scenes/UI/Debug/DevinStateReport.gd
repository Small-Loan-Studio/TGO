extends Label


func _process(_delta: float) -> void:
	var cur_state := Driver.instance().player._state_machine.cur_state()
	if cur_state != null:
		text = cur_state.name


func _on_toggle_track_state_changes(toggled_on: bool) -> void:
	Driver.instance().player._state_machine.print_state_changes = toggled_on
