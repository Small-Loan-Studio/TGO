extends Node2D

var _state: int = 0

@onready var _modulate: CanvasModulate = $CanvasModulate
@onready var _light_level_label: Label = $CanvasLayer/Label2

func _ready() -> void:
	if !_modulate.visible:
		_modulate.visible = true


func setup(_driver: Driver) -> void:
	pass


func _unhandled_input(_event: InputEvent) -> void:
	if _event.is_action_pressed('ui_accept'):
		_state = (_state + 1) % 4
		var t := get_tree().create_tween()
		t.set_parallel(true)
		t.tween_property(_modulate, 'color', get_target(_state), 2)
		# This is hideous and for demo purposes only kill it with fire and refactor
		# something if you're inclined to use it.
		t.tween_property(
			$Player.get_node('Lamp'),
			'energy',
			get_energy_target(_state),
			2)
	if _event.is_action_pressed("ui_text_completion_replace"):
		var lamp: Lamp = $Player/Lamp
		var cur_level := lamp.light_level
		lamp.light_level = ((lamp.light_level) + 1) % Enums.LightLevel.size()
		lamp.energy = get_energy_target(_state)
		_light_level_label.text = 'Light Level: ' + Enums.light_level_name(lamp.light_level)


func get_target(state: int) -> Color:
	match state:
		0:
			return Color(.08, .08, .16)
		1:
			return Color(.5, .5, .5)
		2:
			return Color.WHITE
	return Color(.5, .5, .5)


func get_energy_target(state: int) -> float:
	match state:
		0:
			return .9
		1:
			return .5
		2:
			return 0
	return .5
