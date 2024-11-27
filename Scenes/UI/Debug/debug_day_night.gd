class_name DebugDayNight
extends HBoxContainer

var _dncycle: DayNightCycle

@onready var _pause_btn: Button = $PauseTime
@onready var _clock: Label = $Clock


func setup(dnc: DayNightCycle) -> void:
	_dncycle = dnc
	_dncycle.clock.time_changed.connect(_on_time_change)


func _on_time_change() -> void:
	_clock.text = "HR: %02d" % [_dncycle.clock.get_current_time()]


func _on_pause_pressed() -> void:
	if _dncycle.is_paused():
		_dncycle.pause(false)
		_pause_btn.text = "Pause"
	else:
		_dncycle.pause(true)
		_pause_btn.text = "Unpause"


func _on_day_pressed() -> void:
	_dncycle.set_hour(_dncycle.day_start)


func _on_dusk_pressed() -> void:
	_dncycle.set_hour(_dncycle.dusk_start)


func _on_night_pressed() -> void:
	_dncycle.set_hour(_dncycle.night_start)
