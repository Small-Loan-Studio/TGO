extends Node

signal hour_passed

# time of a day, in seconds
@export var length_of_day: int = 50
var length_of_hour: int = length_of_day / 24

#keep track of current time
var current_time: int = 0
var hours_passed: int = 0

@onready var timer: Timer = $Timer


func _ready() -> void:
	timer.wait_time = length_of_hour
	#print("Current length of day: ", length_of_hour)
	#timer.start()


func _on_timer_timeout() -> void:
	hours_passed += 1
	current_time = hours_passed % 24
	#print("Time is ", current_time)
	hour_passed.emit()


func get_current_time() -> int:
	return current_time


func start_clock() -> void:
	current_time = 0
	hours_passed = 0  #might want to save total hours passed?
	timer.start()
