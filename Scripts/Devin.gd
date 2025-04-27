@tool

class_name Devin
extends Character

var _ak_helper: AKHelper


func _ready() -> void:
	super._ready()
	if Engine.is_editor_hint():
		return
	_ak_helper = AKHelper.new(self)
	stats.get_stat(Enums.Stat.HEALTH).stat_changed.connect(_on_health_change)


func _on_health_change() -> void:
	var value := stats.get_stat(Enums.Stat.HEALTH).value
	_ak_helper.send_param(AK.GAME_PARAMETERS.PLAYERHEALTH_RTPC, value as float)
