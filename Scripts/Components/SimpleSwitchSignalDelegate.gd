class_name SimpleSwitchSignalDelegate
extends Node

var _cfg: SimpleSwitchConfig
var _poly: Polygon2D

func configure(cfg: SimpleSwitchConfig, switch_poly: Polygon2D) -> void:
	_cfg = cfg
	_poly = switch_poly

func _on_triggered(_id: String, state: bool) -> void:
	_set_activation(state)


func _set_activation(state: bool) -> void:
	if state:
		_poly.color = _cfg.active_color
	else:
		_poly.color = _cfg.default_color


