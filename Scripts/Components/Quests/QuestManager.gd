class_name QuestManager
extends Node

signal quest_updated(id: String)

const QUEST_IDX = 0
const PATH_IDX = 1

# maps from quest id to the quest and resource path
# Map<String, [Quest, path]>
var _quest_dict: Dictionary = {}

# Array of ids for quests that have phases
var _phase_starts: Array[String]

# manages the active quests
# Map<String, null>
var _active_quests: Dictionary = {}


func _ready() -> void:
	_load_quests()
	debug_print()
	# call this because it relies on peers within the Driver's scene tree to have
	# been set up. Could work around this via setup() call to explicitly inject
	# dependencies if needed. That wolud be the more designed way to do this...
	Callable(_connect_post_ready).call_deferred()


## Connect to external data sources, should be run via deferred call so that it
## can use anything in driver that gets set up during _ready
func _connect_post_ready() -> void:
	Dialogic.VAR.variable_changed.connect(_on_dialogic_var_changed)
	Driver.instance().inventory_mgr.inventory_updated.connect(_on_inventory_changed)


## saves a loaded set of quests to a target file; if the quests haven't been
## loaded prints an error and bails
##
## TODO: not implemented
func save_to_path(_dest: String) -> void:
	if len(_quest_dict.keys) == 0:
		printerr("Attempting to save an empty quest structure what are you doing")
		return
	assert(false, "Not yet implemented")


## loads quest data from a file and sets up the manager data structures + any
## necessary post-load linkages
##
## TODO: not implemented
func load_from_path(_src: String) -> void:
	# TODO: when implmenting make sure that we end up in a state where we've
	# done any necessary post hoc quest linkages are set up. In theory this
	# should be as simple as leading _quest_dict up then calling _link_quests().
	# Make sure before calling link quest you've cleared out any old quests that
	# might've been loaded incorrectly by default in the _ready path.
	assert(false, "Not yet implemented")


## Gets a quest by its id, id will be ca
func quest_by_id(id: String) -> Quest:
	id = id.to_lower()
	if _quest_dict.has(id):
		return _quest_dict[id][QUEST_IDX]
	return null


## Processes all defined quests and builds the necessary data structures for
## tracking quest state
func _load_quests() -> void:
	_load_quests_helper(Utils.QUEST_DIR)
	_link_quests()


## recursive helper function for _load_quests
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

	var canonicalized_id := q.id.to_lower()
	if _quest_dict.has(canonicalized_id):
		var old_path: String = _quest_dict[canonicalized_id][PATH_IDX]
		printerr("Duplicate quest IDs detected for '%s': %s & %s" % [q.id, old_path, path])
		return
	_quest_dict[canonicalized_id] = [q, path]


## walks the list of defined quests establishing parent links, pulling out all
## the quests that are phase parents, setting the quest manager reference, and
## connecting to the quest signals as needed
func _link_quests() -> void:
	for k: String in _quest_dict.keys():
		# pull out the quests with phases
		var q: Quest = _quest_dict[k][QUEST_IDX]
		q.state_change.connect(_on_quest_state_changed)
		if len(q.phases) > 0:
			_phase_starts.append(k)

		# link children/parents
		_link_children_of(q)


## helper for _link_quests
func _link_children_of(q: Quest) -> void:
	q._mgr = self

	for idx in len(q.phases):
		var phase := q.phases[idx]
		phase.phase_index = idx
		if phase.quest == null:
			printerr("What are you doing, this is an invalid quest phase")
		else:
			phase.quest._phase_parent = q

	for c: Quest in q.next:
		c._parent.append(q)
		_link_children_of(c)


## Handles routing variable changes to the active quests
func _on_dialogic_var_changed(info: Dictionary) -> void:
	if !info.has("variable") || !info.has("new_value"):
		printerr("variable changed signal must contain both variable and new_value: " , info)
		return
	var variable: String = info["variable"]
	var value: Variant = info["new_value"]

	print("variable_changed: %s -> %s" % [variable, str(value)])

	# TODO: for now just reevaluate all quests on any variable change
	_eval_active_quests()


## Handles routing inventory updates to the active quests
func _on_inventory_changed(id: String) -> void:
	print("%s inventory updated" % [id])
	print("    ", Driver.instance().inventory_mgr.get_inventory(id))

	# TODO: for now just reevaluate all quests on any inventory change
	_eval_active_quests()


func _eval_active_quests() -> void:
	for id: String in _active_quests.keys():
		var q := quest_by_id(id)
		if q.evaluate():
			print("%s quest completed" % [q.id])
		else:
			print("%s not completed yet" % [q.id])


func _on_quest_state_changed(
	quest_id: String, _old_state: Enums.QuestState, new_state: Enums.QuestState) -> void:
	var canonicalized_id := quest_id.to_lower()
	match new_state:
		Enums.QuestState.ACTIVE:
			_add_active_quest(canonicalized_id)

		Enums.QuestState.COMPLETED:
			_active_quests.erase(canonicalized_id)
			_process_completed_quest(canonicalized_id)

		Enums.QuestState.FAILED:
			_active_quests.erase(canonicalized_id)
			_process_completed_quest(canonicalized_id)

	quest_updated.emit(quest_id)


func get_active_quests() -> Array[String]:
	var r: Array[String] = []
	for k: String in _active_quests.keys():
		r.append(k)
	return r

func start_quest(id: String) -> bool:
	var q := quest_by_id(id)
	if q == null:
		printerr("Unable to locate quest: ", id)
		return false
	if !q.mark_active():
		printerr("Unable to start quest: ", id)
		return false
	return true


func _add_active_quest(id: String) -> void:
	_active_quests[id] = null
	var q := quest_by_id(id)
	if len(q.phases) > 0:
		# check to see if this quest has phases to start as well
		q.phases[0].quest.mark_active()

	await get_tree().create_timer(2.5).timeout
	_eval_active_quests()


## resolve what happens when a quset is completed. This primarily focuses on
## activating the next in sequence for chains and phased parents. Currently
## only propagates failure up to phased parents.
func _process_completed_quest(id: String) -> void:
	var q := quest_by_id(id)
	if q == null:
		return

	var phase_parent := q.get_phase_parent()

	if q.state == Enums.QuestState.FAILED:
		# In a failed state we trigger the phased parent to evaluate itself in case
		# it should fail. Not that we *do not* check if the phase may_fail is set
		# meaning we won't advance the quest sequence automatically even though the
		# phase parent will not fail itself.
		if phase_parent != null:
			phase_parent.evaluate()
		return

	for q_next: Quest in q.next:
		if !q_next.manual_start:
			q_next.mark_active()
		return

	# if we didn't have further quests in that chain to activate look for
	# additional quests in a potential phased parent

	if phase_parent != null:
		var idx := 0
		# look through all phases from the parent until we find one that isn't
		# completed or we run off the end of the list
		while idx < len(phase_parent.phases) && phase_parent.phases[idx].quest.is_finished():
			idx = idx + 1

		if idx == len(phase_parent.phases):
			# all phases of the phase_parent are finished
			phase_parent.evaluate()
		else:
			# we have found a phase that isn't finished so activate it
			var next_quest_phase := phase_parent.phases[idx]
			if next_quest_phase.quest.state != Enums.QuestState.ACTIVE:
				next_quest_phase.quest.mark_active()

func debug_print() -> void:
	print("Quest Status:")
	for k: String in _quest_dict.keys():
		print("  %s -> %s" % [k, Enums.quest_state_name(quest_by_id(k).state)])