class_name QuestManager
extends Node

# Map<String, Quest>
var _quest_dict: Dictionary = {}


func _ready() -> void:
	_load_quests()


func _load_quests() -> void:
	_load_quests_helper(Utils.QUEST_DIR)


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
			print("%s -> %s" % [path, abs_path])
			var quest_res := load(abs_path) as Quest
			print(quest_res)

		path = dir.get_next()
	
	dir.list_dir_end()