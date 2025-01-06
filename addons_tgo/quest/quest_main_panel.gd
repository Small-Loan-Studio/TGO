@tool
class_name QuestMainPanel
extends Control

var _main_panel_ratio := .8


@onready var _split_container := $HSplitContainer


func _ready() -> void:
	_set_width()


func _on_resized() -> void:
	_set_width()


func _set_width() -> void:
	var width := get_rect().size.x
	if _split_container != null:
		_split_container.split_offset = (width * _main_panel_ratio) as int


func _adjust_main_panel_ratio(offset:int) -> void:
	var width := get_rect().size.x
	_main_panel_ratio = (offset as float) / width