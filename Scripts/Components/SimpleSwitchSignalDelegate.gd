class_name SimpleSwitchSignalDelegate
extends Node

var _cfg: SimpleSwitchConfig
var _poly: Polygon2D


func configure(cfg: SimpleSwitchConfig, switch_poly: Polygon2D) -> void:
	_cfg = cfg
	_poly = switch_poly
	if !_cfg.triggered.is_connected(_on_triggered):
		_cfg.triggered.connect(_on_triggered)

	## set initial pressed state based on the current state of the switch
	set_activation(cfg.is_pressed)


func _on_triggered(_id: String, state: bool) -> void:
	set_activation(state)


func set_activation(state: bool) -> void:
	if state:
		_poly.color = _cfg.active_color
	else:
		_poly.color = _cfg.default_color
