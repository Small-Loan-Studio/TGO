@tool
extends RichTextLabel

var global_errs: Array[String] = []

# Dictionary[Quest.id, Array[String]]
var quest_errs: Dictionary = {}

func add_quest_lint(q_id: String, errs: Array[String]) -> void:
	quest_errs[q_id] = errs

func lint_clear() -> void:
	global_errs = []
	quest_errs.clear()

func update_display() -> void:
	text = ""

	for e: String in global_errs:
		text += e + "\n"

	for q_id: String in quest_errs.keys():
		if quest_errs[q_id].size() == 0:
			continue

		text += "[b]%s[b]\n[ul]" % [q_id]
		for err: String in quest_errs[q_id]:
			text += err + "\n"
		text += "[/ul]\n"

func _on_meta_clicked(meta: Variant) -> void:
	print(typeof(meta))
	print(TYPE_STRING)
	print(meta)