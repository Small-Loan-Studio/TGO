@tool
class_name LintReport
extends VBoxContainer

signal select_node(quest_id: String)

var global_errs: Array[String] = []

# Dictionary[Quest.id, Array[String]]
var quest_errs: Dictionary = {}


func add_quest_lint(q_id: String, errs: Array[String]) -> void:
	quest_errs[q_id] = errs


func lint_clear() -> void:
	global_errs = []
	quest_errs.clear()


func update_display() -> void:
	# text = ""

	for c in get_children():
		remove_child(c)

	if global_errs.size() > 0:
		add_child(LintNodeReport.from_errors(self, "Global", global_errs))

	var quest_keys := quest_errs.keys()
	quest_keys.sort()
	for q_id: String in quest_keys:
		if quest_errs[q_id].size() == 0:
			continue

		var link_name := "[url=%s]%s[/url]" % [q_id, q_id]
		add_child(LintNodeReport.from_errors(self, link_name, quest_errs[q_id]))
