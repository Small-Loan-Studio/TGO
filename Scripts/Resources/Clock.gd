class_name Clock
extends Node

signal time_changed

# time of a day, in seconds
@export var length_of_day: int = 50
var length_of_hour: int = length_of_day / 24

# keep track of current time
var current_time: int = 0

@onready var timer: Timer = $Timer


func _ready() -> void:
	timer.wait_time = length_of_hour


func _on_timer_timeout() -> void:
	current_time = (current_time + 1) % 24
	time_changed.emit()


func get_current_time() -> int:
	return current_time


func set_time(time: int) -> void:
	current_time = time
	time_changed.emit()


func start_clock() -> void:
	timer.start()


func pause() -> void:
	timer.paused = true


func paused() -> bool:
	return timer.paused


func start() -> void:
	if timer.paused:
		timer.paused = false
	else:
		timer.start()
