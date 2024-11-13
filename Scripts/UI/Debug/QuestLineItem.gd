class_name QuestLineItem
extends HBoxContainer

@export var indent_sizing := 20

var _quest: Quest
var _indent_level: int = 0

@onready var _margin_container := $MarginContainer
@onready var _title := $MarginContainer/Title
@onready var _completed_marker := $CompletedMarker
@onready var _failed_marker := $FailedMarker


func track(q: Quest, indent_level: int = 0) -> void:
	_quest = q
	_indent_level = indent_level


func _ready() -> void:
	if _quest == null:
		printerr("Attempting to display quest summary for null")
		return

	_title.text = _quest.title
	_completed_marker.hide()
	_failed_marker.hide()

	_margin_container.add_theme_constant_override("margin_left", indent_sizing * _indent_level)

	if _quest.state == Enums.QuestState.COMPLETED:
		_completed_marker.show()
	if _quest.state == Enums.QuestState.FAILED:
		_completed_marker.show()
