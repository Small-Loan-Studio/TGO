@tool
class_name QuestMainPanel
extends Control

var _main_panel_ratio := .8
var _editor: EditorInterface
var _first_load := true

@onready var _split_container := $VBoxContainer/HSplitContainer
@onready var _graph_edit: QuestGraphEdit = $VBoxContainer/HSplitContainer/QuestGraphEdit


func _lint_report() -> LintReport:
	return %LintReport


func _ready() -> void:
	_set_width()


func setup(editor: EditorInterface) -> void:
	_editor = editor
	_graph_edit.setup(editor)


func _on_resized() -> void:
	_set_width()


func _set_width() -> void:
	var width := get_rect().size.x
	if _split_container != null:
		_split_container.split_offset = (width * _main_panel_ratio) as int


func _adjust_main_panel_ratio(offset: int) -> void:
	var width := get_rect().size.x
	_main_panel_ratio = (offset as float) / width

	if _lint_report() != null:
		_lint_report().trickle_width(((1 - _main_panel_ratio) * width) as int)


func _on_visibility_changed() -> void:
	if visible && _graph_edit != null && _first_load:
		_first_load = false
		await get_tree().create_timer(0.05).timeout
		_graph_edit.do_layout()


func _set_show_errors(on: bool) -> void:
	_lint_report().show_errors = on


func _set_show_warnings(on: bool) -> void:
	_lint_report().show_warnings = on
