extends Node

@export var DAY_START: int = 8
@export var DUSK_START: int = 16
@export var NIGHT_START: int = 20
@export var DAWN_START: int = 6

@export var DAY_COLOR: Color = Color.WHITE
@export var DUSK_COLOR: Color = Color(.5, .5, .5)
@export var NIGHT_COLOR: Color = Color(.08, .08, .16)


var current_time: int = DAY_START

@onready var clock: Node = $Clock
@onready var _modulate: CanvasModulate = $CanvasModulate


func _ready() -> void:
	clock.set_time(DAY_START)
	clock.start_clock()


func setup(_driver: Driver) -> void:
	pass


func _on_clock_hour_passed() -> void:
	current_time = clock.get_current_time()
	print("Time is ", current_time)
	if (
		current_time == DAY_START
		|| current_time == DAWN_START
		|| current_time == DUSK_START
		|| current_time == NIGHT_START
	):
		var tweener := get_tree().create_tween()
		tweener.set_parallel(true)
		tweener.tween_property(_modulate, "color", _get_target(current_time), 2)


func _get_target(time: int) -> Color:
	if time == DAY_START:
		print("day start")
		return DAY_COLOR
	if time == DUSK_START || current_time == DAWN_START:
		print("twilight start")
		return DUSK_COLOR
	if time == NIGHT_START:
		print("night start")
		return NIGHT_COLOR

	return Color(.5, .5, .5) #this shouldn't be reached	


func set_hour(time: int) -> void:
	#first check how dark it should be based on given time
	if(time > 23):
		return
	var tweener := get_tree().create_tween()
	tweener.set_parallel(true)
	if(time >= DAY_START && time < DUSK_START):
		tweener.tween_property(_modulate, "color", DAY_COLOR, 2)
	elif((time >= DUSK_START && time<NIGHT_START) || (time >=DAWN_START && time<DAY_START)):
		tweener.tween_property(_modulate, "color", DUSK_COLOR, 2)
	elif(time>=NIGHT_START || time<DAWN_START):
		tweener.tween_property(_modulate, "color", NIGHT_COLOR, 2)
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
	return DAY_START


func _unhandled_input(_event: InputEvent) -> void:
	if _event.is_action_pressed("pause_time"):
		#just cycles through paused -> unpaused
		pause(!is_paused())
