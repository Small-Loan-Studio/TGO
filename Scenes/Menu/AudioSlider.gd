class_name AudioSlider
extends MarginContainer

## Which audio bus does this slider bind
@export var bus: Enums.AudioBus

var is_active: bool = false:
	set(v):
		is_active = v
		_update_active(v)

var _am: AudioManager

@onready var _label: Label = $HBoxContainer/Label
@onready var _slider: HSlider = $HBoxContainer/BusSlider
@onready var _marker: TextureRect = $HBoxContainer/TextureRect


func _ready() -> void:
	# start disabled and let our embedding control handle when we react to changes
	process_mode = Node.PROCESS_MODE_DISABLED
	_slider.value_changed.connect(_update_level.unbind(1))


func init(am: AudioManager) -> void:
	_am = am
	print("%s.init; setting value to: %f" %[name,_am.get_level(bus)])
	_slider.value = _am.get_level(bus)


func _update_active(active: bool) -> void:
	if active:
		_marker.modulate = Color.WHITE
	else:
		var c := Color.WHITE
		c.a = .2
		_marker.modulate = c


func _process(_delta: float) -> void:
	if !is_active:
		return

	if Input.is_action_just_pressed(Enums.input_action_name(Enums.InputAction.RIGHT)):
		level_up()
	if Input.is_action_just_pressed(Enums.input_action_name(Enums.InputAction.LEFT)):
		level_down()


func label_width() -> int:
	return int(_label.size.x)


func set_label_width(x: int) -> void:
	_label.custom_minimum_size.x = x


func level_up() -> void:
	_slider.value += _slider.step


func level_down() -> void:
	_slider.value -= _slider.step


func _update_level() -> void:
	_am.set_level(bus, _slider.value)
