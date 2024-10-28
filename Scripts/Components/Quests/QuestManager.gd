class_name QuestManager
extends Node

# maps from quest id to the quest and resource path
# Map<String, [Quest, path]>
var _quest_dict: Dictionary = {}

# Array of ids for quests that have phases
var _phase_starts: Array[String]


func _ready() -> void:
	_load_quests()


func _load_quests() -> void:
	_load_quests_helper(Utils.QUEST_DIR)
	_link_quests()
	_debug_print()


func _debug_print() -> void:
	print("Quest structure:")
	for k: String in _quest_dict.keys():
		print(_quest_dict[k][0])
		print("------")

	print("Phase start quests:")
	for k: String in _phase_starts:
		print(k)


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


func _link_quests() -> void:
	for k: String in _quest_dict.keys():
		# pull out the quests with phases
		var q: Quest = _quest_dict[k][0]
		if len(q.phases) > 0:
			_phase_starts.append(k)

		# link children/parents
		_link_children_of(q)

func _link_children_of(q: Quest) -> void:
	for c: Quest in q.next:
		c._parent.append(q)
		_link_children_of(c)