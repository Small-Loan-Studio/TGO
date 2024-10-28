class_name QuestManager
extends Node

# Map<String, [Quest, path]>
var _quest_dict: Dictionary = {}


func _ready() -> void:
	_load_quests()


func _load_quests() -> void:
	_load_quests_helper(Utils.QUEST_DIR)
	print(_quest_dict)


func _load_quests_helper(cur_dir: String) -> void:
	var dir := DirAccess.open(cur_dir)
	if !dir:
		printerr("Failed to open quest dir '%s': %s" % [cur_dir, DirAccess.get_open_error()])
		return

	dir.list_dir_begin()
	var path := dir.get_next()
	while path != "":
		var abs_path := "%s/%s" % [cur_dir, path]

		if dir.current_is_dir():
			_load_quests_helper(abs_path)
		else:
			var quest_res := load(abs_path) as Quest
			if quest_res == null:
				printerr("Non quest file found at ", abs_path)
			else:
				_register_quest(quest_res, abs_path)

		path = dir.get_next()
	
	dir.list_dir_end()


func _register_quest(q: Quest, path: String) -> void:
	if q.id == "":
		printerr("Likely misconfigured quest; no id specified: " + path)
	if q.title == "":
		printerr("Likely misconfigured quest; no title specified: %s / %s" % [q.id, path])

	if _quest_dict.has(q.id):
		var old_path: String = _quest_dict[q.id][1]
		printerr("Duplicate quest IDs detected for '%s': %s & %s" % [q.id, old_path, path])
		return
	_quest_dict[q.id] = [q, path]