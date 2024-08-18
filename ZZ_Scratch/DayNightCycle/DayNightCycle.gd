extends Node2D

#I had trouble connecting to the clock in driver, so I just copied it over
#So that it is in the same scene tree and can be setup this way
@onready var clock: Node = $Clock
@onready var _modulate: CanvasModulate = $CanvasModulate

var current_time: int = 0
const day_start: int = 0
const dusk_start: int = 8
const night_start: int = 14
const dawn_start: int = 20

func _ready() -> void:
	clock.start_clock()
	

func setup(_driver: Driver) -> void:
	pass


func _on_clock_hour_passed() -> void:
	current_time = clock.get_current_time()
	#print("Time is ", current_time)
	
	if(current_time == day_start || current_time == dawn_start || current_time == dusk_start || current_time == night_start):
		var tweener := get_tree().create_tween()
		tweener.set_parallel(true)
		tweener.tween_property(_modulate, "color", get_target(current_time), 2)
		
func get_target(time: int) -> Color:
	if(time == day_start):
		#print("day start")
		return Color.WHITE
	elif(time == dusk_start || current_time == dawn_start):
		#print("twilight start")
		return Color(.5, .5, .5)
	elif(time == night_start):
		#print("night start")
		return Color(.08, .08, .16)
	else:
		#print("Entered get_target but no valid target?")
		return Color(.5, .5, .5)
