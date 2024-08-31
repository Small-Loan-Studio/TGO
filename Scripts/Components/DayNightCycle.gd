extends Node

@export var day_start: int = 8
@export var dusk_start: int = 16
@export var night_start: int = 20
@export var dawn_start: int = 6

@export var day_color: Color = Color.WHITE
@export var dusk_color: Color = Color(.5, .5, .5)
@export var night_color: Color = Color(.08, .08, .16)

var current_time: int = day_start

@onready var clock: Node = $Clock
@onready var _modulate: CanvasModulate = $CanvasModulate


func _ready() -> void:
	clock.set_time(day_start)
	clock.start_clock()


func setup(_driver: Driver) -> void:
	pass


func _on_clock_hour_passed() -> void:
	current_time = clock.get_current_time()
	print("Time is ", current_time)
	if (
		current_time == day_start
		|| current_time == dawn_start
		|| current_time == dusk_start
		|| current_time == night_start
	):
		var tweener := get_tree().create_tween()
		tweener.tween_property(_modulate, "color", _get_target(current_time), 2)


func _get_target(time: int) -> Color:
	if time == day_start:
		print("day start")
		return day_color
	if time == dusk_start || current_time == dawn_start:
		print("twilight start")
		return dusk_color
	if time == night_start:
		print("night start")
		return night_color

	return Color(.5, .5, .5)  #this shouldn't be reached


func set_hour(time: int) -> void:
	#first check how dark it should be based on given time
	if time > 23:
		return
	var tweener := get_tree().create_tween()
	if time >= day_start && time < dusk_start:
		tweener.tween_property(_modulate, "color", day_color, 2)
	elif (time >= dusk_start && time < night_start) || (time >= dawn_start && time < day_start):
		tweener.tween_property(_modulate, "color", dusk_color, 2)
	elif time >= night_start || time < dawn_start:
		tweener.tween_property(_modulate, "color", night_color, 2)
	else:
		return

	#change time in the clock
	clock.set_time(time)


func pause(pause: bool) -> void:
	if pause:
		print("pausing time")
		clock.stop()
	else:
		print("unpausing time")
		clock.start()


func is_paused() -> bool:
	return clock.is_stopped()


func get_day_start() -> int:
	return day_start


func _unhandled_input(_event: InputEvent) -> void:
	if _event.is_action_pressed("pause_time"):
		#just cycles through paused -> unpaused
		pause(!is_paused())
