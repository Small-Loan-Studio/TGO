class_name QuestManager
extends Node

# maps from quest id to the quest and resource path
# Map<String, [Quest, path]>
var _quest_dict: Dictionary = {}

# Array of ids for quests that have phases
var _phase_starts: Array[String]


func _ready() -> void:
	_load_quests()
	debug_print()
	# call this because it relies on peers within the Driver's scene tree to have
	# been set up. Could work around this via setup() call to explicitly inject
	# dependencies if needed. That wolud be the more reasonable way to do this...
	Callable(_connect_post_ready).call_deferred()


## Connect to external data sources
func _connect_post_ready() -> void:
	Dialogic.VAR.variable_changed.connect(_on_dialogic_var_changed)
	Driver.instance().inventory_mgr.inventory_updated.connect(_on_inventory_changed)


func _on_dialogic_var_changed(info: Dictionary) -> void:
	if !info.has("variable") || !info.has("new_value"):
		printerr("variable changed signal must contain both variable and new_value: " , info)
		return
	var variable: String = info["variable"]
	var value: Variant = info["new_value"]

	print("variable_changed: %s -> %s" % [variable, str(value)])


func _on_inventory_changed(id: String) -> void:
	print("%s inventory updated" % [id])
	print(Driver.instance().inventory_mgr.get_inventory(id))


## saves a loaded set of quests to a target file; if the quests haven't been
## loaded prints an error and bails
##
## TODO: not implemented
func save_to_path(dest: String) -> void:
	if len(_quest_dict.keys) == 0:
		printerr("Attempting to save an empty quest structure what are you doing")
		return
	assert(false, "Not yet implemented")


## loads quest data from a file and sets up the manager data structures + any
## necessary post-load linkages
##
## TODO: not implemented
func load_from_path(src: String) -> void:
	assert(false, "Not yet implemented")

## Processes all defined quests and builds the necessary data structures for
## tracking quest state
func _load_quests() -> void:
	_load_quests_helper(Utils.QUEST_DIR)
	_link_quests()


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


## walks the list of defined quests establishing parent links, pulling out all
## the quests that are phase parents, and setting the quest manager reference
func _link_quests() -> void:
	for k: String in _quest_dict.keys():
		# pull out the quests with phases
		var q: Quest = _quest_dict[k][0]
		if len(q.phases) > 0:
			_phase_starts.append(k)

		# link children/parents
		_link_children_of(q)


## helper for _link_quests
func _link_children_of(q: Quest) -> void:
	q._mgr = self

	for p: QuestPhase in q.phases:
		if p.quest == null:
			printerr("What are you doing, this is an invalid quest phase")
		else:
			p.quest._phase_parent = q

	for c: Quest in q.next:
		c._parent.append(q)
		_link_children_of(c)


func debug_print() -> void:
	print("Quest structure:")
	for k: String in _quest_dict.keys():
		print(_quest_dict[k][0])
		print("------")

	print("Phase start quests:")
	for k: String in _phase_starts:
		print(k)
