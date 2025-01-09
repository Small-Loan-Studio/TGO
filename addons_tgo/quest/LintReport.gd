@tool
class_name LintReport
extends VBoxContainer

## emitted when the user clicks on a quest id its lint error block
## the name is taken from the q_id passed in via [[add_quest_lint]]
signal select_node(quest_id: String)

## any global errors not bound to a specific quest
var global_errs: Array[String] = []

# Dictionary[Quest.id, Array[String]]
var quest_errs: Dictionary = {}


## updates the lint errors for a given quest id
func add_quest_lint(q_id: String, errs: Array[String]) -> void:
	quest_errs[q_id] = errs


## clears all lint errors that are tracked and removes all display nodes
func lint_clear() -> void:
	global_errs = []
	quest_errs.clear()
	for c in get_children():
		remove_child(c)


## refresh the displayed errors with whatever the we're currently tracking in
## global_errs and quest_errs
func update_display() -> void:
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
