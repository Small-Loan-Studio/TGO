extends Node2D

#I had trouble connecting to the clock in driver, so I just copied it over
#So that it is in the same scene tree and can be setup this way

const DAY_START: int = 0
const DUSK_START: int = 8
const NIGHT_START: int = 14
const DAWN_START: int = 20

var current_time: int = 0

@onready var clock: Node = $Clock
@onready var _modulate: CanvasModulate = $CanvasModulate


func _ready() -> void:
	clock.start_clock()


func setup(_driver: Driver) -> void:
	pass


func _on_clock_hour_passed() -> void:
	current_time = clock.get_current_time()
	#print("Time is ", current_time)
	if (
		current_time == DAY_START
		|| current_time == DAWN_START
		|| current_time == DUSK_START
		|| current_time == NIGHT_START
	):
		var tweener := get_tree().create_tween()
		tweener.set_parallel(true)
		tweener.tween_property(_modulate, "color", get_target(current_time), 2)


func get_target(time: int) -> Color:
	if time == DAY_START:
		#print("day start")
		return Color.WHITE
	if time == DUSK_START || current_time == DAWN_START:
		#print("twilight start")
		return Color(.5, .5, .5)
	if time == NIGHT_START:
		#print("night start")
		return Color(.08, .08, .16)

	return Color(.5, .5, .5)
