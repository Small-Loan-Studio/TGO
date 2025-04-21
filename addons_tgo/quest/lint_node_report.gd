@tool
class_name LintNodeReport
extends VBoxContainer

const SCENE := preload("res://addons_tgo/quest/lint_node_report.tscn")

var show_warnings: bool = true:
	set(v):
		show_warnings = v
		_sync_vis()

var show_errors: bool = true:
	set(v):
		show_errors = v
		_sync_vis()

var _report: LintReport

# all the accessors below use this style instead of @onready bc we need it
# to work reliably in @tool mode.

var _node_label: RichTextLabel:
	get:
		return $NodeLabel

var _errors_header: Label:
	get:
		return $ErrorsHeader

var _errors_section: VBoxContainer:
	get:
		return $ErrorsMargin/VBox

var _warnings_header: Label:
	get:
		return $WarningsHeader

var _warnings_section: VBoxContainer:
	get:
		return $WarningsMargin/VBox


func _sync_vis() -> void:
	var has_errors := _errors_section.get_child_count() > 0
	var has_warnings := _warnings_section.get_child_count() > 0
	if has_errors:
		_errors_header.visible = show_errors
		_errors_section.visible = show_errors
	if has_warnings:
		_warnings_header.visible = show_warnings
		_warnings_section.visible = show_warnings

	visible = (has_errors && show_errors) || (has_warnings && show_warnings)
	if !visible:
		size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	else:
		size_flags_vertical = Control.SIZE_FILL


func reflow_width(x: int) -> void:
	custom_minimum_size.x = x


func _on_node_clicked(meta: Variant) -> void:
	_report.select_node.emit(meta as String)


static func from_errors(
	report_ref: LintReport, name: String, errors: Array[String]
) -> LintNodeReport:
	var report := SCENE.instantiate() as LintNodeReport

	report._report = report_ref
	report._node_label.text = name
	report._errors_header.hide()
	report._errors_section.hide()
	report._warnings_header.hide()
	report._warnings_section.hide()

	for err in errors:
		var parts := err.split(":", false, 1)
		var is_err: bool = parts[0].strip_edges() == "E"
		var msg: String = parts[1].strip_edges()

		var l := Label.new()
		l.text = msg
		l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		l.custom_minimum_size.x = report.size.x
		if is_err:
			report._errors_header.show()
			report._errors_section.show()
			report._errors_section.add_child(l)
		else:
			report._warnings_header.show()
			report._warnings_section.show()
			report._warnings_section.add_child(l)

	return report
