class_name DayNightCycle
extends Node

signal time_changed

@export var dawn_start_h: int = 6
@export var day_start_h: int = 8
@export var dusk_start_h: int = 16
@export var night_start_h: int = 20

@export var day_color: Color = Color.WHITE
@export var dusk_color: Color = Color(.5, .5, .5)
@export var night_color: Color = Color(.08, .08, .16)

## How long will it take to progress a full 24h, in seconds
@export var day_length_seconds := 600:
	set(v):
		day_length_seconds = v
		_update_tick_time()

## When we hit a time-of-day boundary how many in-game hours should we take
## to transition the lighting; 0 is instant, 2 is 2 hours, e.g. 4p to 6p
@export var transition_time_game_hours := 1.5
@export var day_autostart: bool

## returns time in seconds
var current_time: int:
	get:
		return _time.get_time()

var _time: DNClock
var _timer: Timer
var _overlay_tween: Tween
var _dilated_secs_per_tick: int = 0
var _tick_rate := .2
var _txn_wall_sec: int:
	get:
		var sec_per_wall_sec := _dilated_secs_per_tick / _tick_rate
		var wall_sec := int(transition_time_game_hours * 60 * 60 / sec_per_wall_sec)
		return wall_sec

@onready var dawn_start_s := DNClock.hms_to_sec(dawn_start_h, 0, 0)
@onready var day_start_s := DNClock.hms_to_sec(day_start_h, 0, 0)
@onready var dusk_start_s := DNClock.hms_to_sec(dusk_start_h, 0, 0)
@onready var night_start_s := DNClock.hms_to_sec(night_start_h, 0, 0)
@onready var _modulate: CanvasModulate = $CanvasModulate


func _ready() -> void:
	_time = DNClock.new()
	_time.set_time_hm(day_start_h, 0)

	_timer = Timer.new()
	_timer.wait_time = _tick_rate
	_timer.timeout.connect(_on_tick)
	_timer.autostart = day_autostart
	_timer.paused = false
	add_child(_timer)


func _process(_delta: float) -> void:
	# print(_timer.is_stopped())
	# print(_timer.paused)
	pass


func setup(_driver: Driver) -> void:
	pass


func _update_tick_time() -> void:
	var day_in_sec := 24 * 60 * 60
	var day_secs_per_tick := float(day_in_sec) / day_length_seconds
	_dilated_secs_per_tick = int(_tick_rate * day_secs_per_tick)


func _day_segment() -> String:
	var ts := _time.get_time()
	if ts < dawn_start_s:
		return "night"
	if ts < day_start_s:
		return "dawn"
	if ts < dusk_start_s:
		return "day"
	if ts < night_start_s:
		return "dusk"
	return "night"


func _get_target_color(time: int) -> Color:
	if time < dawn_start_s:
		return night_color
	if time < day_start_s:
		return dusk_color
	if time < dusk_start_s:
		return day_color
	if time < night_start_s:
		return dusk_color
	return night_color


## sets the game time in seconds since start of the day
func set_time_sec(time: int, immediate: bool = false) -> void:
	_time.set_time_sec(time)
	_begin_tween(immediate)


func _begin_tween(immediate: bool = false) -> void:
	var tween_speed := _txn_wall_sec
	if immediate:
		tween_speed = 0

	if _overlay_tween != null && _overlay_tween.is_running():
		_overlay_tween.kill()

	var tgt := _get_target_color(_time.get_time())
	if tgt == _modulate.color:
		return

	_overlay_tween = get_tree().create_tween()
	_overlay_tween.tween_property(_modulate, "color", tgt, tween_speed)


func pause(should_pause: bool) -> void:
	if should_pause:
		_timer.paused = true
		if _overlay_tween != null && _overlay_tween.is_running():
			_overlay_tween.pause()
	else:
		_timer.paused = false
		if _timer.is_stopped():
			_timer.start()
		if _overlay_tween != null && !_overlay_tween.is_running():
			_overlay_tween.play()


func is_paused() -> bool:
	return _timer.paused || _timer.is_stopped()


func _on_tick() -> void:
	var old_s := _day_segment()
	_time.advance_secs(_dilated_secs_per_tick)
	var new_s := _day_segment()
	if old_s != new_s:
		_begin_tween()

	time_changed.emit()


func time_str() -> String:
	return _time.get_hm_time()


class DNClock:
	extends RefCounted

	static var _sec_per_hour := 60 * 60
	static var _sec_per_min := 60
	var _tally := 0

	static func sec_to_hms(s: int) -> Array[int]:
		var hms: Array[int] = [0, 0, 0]

		if s > 24 * _sec_per_hour:
			s -= 24 * _sec_per_hour

		var hours := s / _sec_per_hour
		s -= (hours * _sec_per_hour)
		if hours > 0:
			hms[0] = hours

		if s > 0:
			var minutes := s / _sec_per_min
			s -= (minutes * _sec_per_min)
			if minutes > 0:
				hms[1] = minutes

		if s > 0:
			hms[2] = s

		if hms[2] > 59:
			hms[2] -= 60
			hms[1] += 1
		if hms[1] > 59:
			hms[1] -= 60
			hms[0] += 1
		if hms[0] > 23:
			hms[0] = 0

		return hms

	static func hms_to_sec(h: int, m: int, s: int) -> int:
		return s + m * 60 + h * 60 * 60

	func advance_secs(count: int) -> void:
		_tally += count
		if _tally > 24 * _sec_per_hour:
			_tally -= 24 * _sec_per_hour

	func set_time_hm(hour: int, minute: int) -> void:
		set_time_sec(hour * _sec_per_hour + minute * _sec_per_min)

	func set_time_sec(sec: int) -> void:
		_tally = 0
		advance_secs(sec)

	func get_time() -> int:
		return _tally

	func get_time_hms() -> Array[int]:
		return DNClock.sec_to_hms(_tally)

	func get_hm_time() -> String:
		var hms := DNClock.sec_to_hms(_tally)
		return "%02d:%02d" % [hms[0], hms[1]]

	func _to_string() -> String:
		return "%02d:%02d:%02d" % DNClock.sec_to_hms(_tally)
