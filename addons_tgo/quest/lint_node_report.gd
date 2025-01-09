@tool
class_name LintNodeReport
extends VBoxContainer

const SCENE := preload("res://addons_tgo/quest/lint_node_report.tscn")

var _report: LintReport

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
		if is_err:
			report._errors_header.show()
			report._errors_section.show()
			report._errors_section.add_child(l)
		else:
			report._warnings_header.show()
			report._warnings_section.show()
			report._warnings_section.add_child(l)

	return report
