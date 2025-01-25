class_name DebugDayNight
extends HBoxContainer

var _dncycle: DayNightCycle

@onready var _pause_btn: Button = $PauseTime
@onready var _clock: Label = $Clock


func setup(dnc: DayNightCycle) -> void:
	_dncycle = dnc
	_dncycle.time_changed.connect(_on_time_change)


func _on_time_change() -> void:
	_clock.text = "HR: %s" % [_dncycle.time_str()]


func _on_pause_pressed() -> void:
	if _dncycle.is_paused():
		_dncycle.pause(false)
		_pause_btn.text = "Pause"
	else:
		_dncycle.pause(true)
		_pause_btn.text = "Unpause"


func _on_day_pressed() -> void:
	_dncycle.set_hour(_dncycle.day_start_h, true)


func _on_dusk_pressed() -> void:
	_dncycle.set_hour(_dncycle.dusk_start_h, true)


func _on_night_pressed() -> void:
	_dncycle.set_hour(_dncycle.night_start_h, true)
