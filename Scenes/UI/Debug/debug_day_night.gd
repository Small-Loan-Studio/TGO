class_name DebugDayNight
extends HBoxContainer

var _dncycle: DayNightCycle

@onready var _pause_btn: Button = $PauseTime
@onready var _clock: Label = $Clock


func setup(dnc: DayNightCycle) -> void:
	_dncycle = dnc
	_dncycle.time_changed.connect(_on_time_change)
	_sync_pause_ui()


func _sync_pause_ui() -> void:
	if _dncycle.is_paused():
		_pause_btn.text = "Unpause"
	else:
		_pause_btn.text = "Pause"

func _on_time_change() -> void:
	_clock.text = "HR: %s" % [_dncycle.time_str()]


func _on_pause_pressed() -> void:
	if _dncycle.is_paused():
		_dncycle.pause(false)
	else:
		_dncycle.pause(true)
	_sync_pause_ui()

func _on_day_pressed() -> void:
	_dncycle.set_time_sec(_dncycle.day_start_s, true)


func _on_dusk_pressed() -> void:
	_dncycle.set_time_sec(_dncycle.dusk_start_s, true)


func _on_night_pressed() -> void:
	_dncycle.set_time_sec(_dncycle.night_start_s, true)
