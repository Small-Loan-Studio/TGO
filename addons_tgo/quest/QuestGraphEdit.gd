@tool
class_name QuestGraphEdit
extends GraphEdit


# Map[Quest.id, Quest]
var _quests := {}

## tracks which nodes are selected in the edit view for determining which gets
## focus in the inspector panel, contains the node name as added to the container
var _selected_nodes: Array[String] = []

# this is the id of the last node that was selected; needs to be cached
# separately because the underlying quest id can be edited and in that
# case we need to refresh the mapping in _quests
var _last_edited_id: String

# this is the currently edited node, null if no node is being edited
var _edited_node: QuestNode

var _debounce_mark_msec: int = 0
var _debounce_wait_msec: int = 500

var _editor: EditorInterface

func _ready() -> void:
	_refresh_quests()


func setup(editor: EditorInterface) -> void:
	_editor = editor

	# we use this to track when a property is changed to an edited quest
	# some attention to detail is needed though as this is fired regardless
	# of the quest visualizer being focused so it may not be an object we
	# care about
	# TODO: This doesn't seem to work for changes nested into the edited
	# object, we may need to straight up poll instead of relying on a signal
	# to indicate changes
	_editor.get_inspector().property_edited.connect(_edited_object_changed)

	# this is a lists of nodes to setup, we don't do this when added because
	# it creates links to other nodes which may not tracked in the graph yet
	var to_sync := []
	for q: Quest in _quests.values():
		var node := QuestNode.from_quest(q)
		add_child(node)
		to_sync.push_back(node)

	for qn: QuestNode in to_sync:
		qn.setup(_editor, self)

	_do_layout()


func _do_layout() -> void:
	if false:
		# TODO: check for persisted layout
		pass
	else:
		select_all_quests()
		arrange_nodes()
		deselect_all_quests()


func _force_sync_edits() -> void:
	_debounce_mark_msec = 0

	# update quest dictionary to node id changing
	if _last_edited_id != _edited_node.id:
		if _last_edited_id != "":
			_quests.erase(_last_edited_id)
		if _edited_node.id != "":
			_quests[_edited_node.id] = _edited_node._data
		_last_edited_id = _edited_node.id

	_edited_node.sync()


func _edited_object_changed(prop: String) -> void:
	if !visible:
		# don't worry about things if the quest visualization isn't focused
		return
	_debounce_mark_msec = Time.get_ticks_msec()


func _refresh_quests() -> void:
	var quest_paths := Utils.walk_directory(Utils.QUEST_DIR, func(s: String) -> bool: return s.ends_with(".tres"))
	for path in quest_paths:
		var quest := ResourceLoader.load(Utils.QUEST_DIR.path_join(path)) as Quest
		if quest != null:
			_quests[quest.id] = quest

func _on_visibility_changed() -> void:
	if visible:
		for c in get_children():
			if c is QuestNode:
				c._sync_width()

func _node_selected(node: Node) -> void:
	if node is QuestNode:
		if node.id in _selected_nodes:
			return
		_selected_nodes.push_back(node.name)
	_update_selection()

func _node_deselected(node: Node) -> void:
	_selected_nodes.clear()
	_selected_nodes.assign(get_selected_nodes().map(func(n: QuestNode) -> String: return n.name))
	_update_selection()

func _update_selection() -> void:
	if _selected_nodes.size() == 1:
		var quest_node: QuestNode = get_node(_selected_nodes[0])
		_edited_node = quest_node
		_last_edited_id = _edited_node.id
		_editor.edit_resource(_quests[quest_node._data.id])
	else:
		_editor.edit_node(null)
		if _edited_node != null:
			_force_sync_edits()
			_edited_node = null
			_last_edited_id = ""


func _process(_delta: float) -> void:
	var now := Time.get_ticks_msec()
	if _edited_node != null && _debounce_mark_msec != 0:
		var del := now - _debounce_mark_msec
		if del > _debounce_wait_msec:
			_force_sync_edits()


func get_selected_nodes() -> Array[QuestNode]:
	var nodes: Array[QuestNode] = []
	for c in get_children():
		if c is QuestNode && c.selected:
			nodes.append(c)
	return nodes


func node_by_quest_id(id: String) -> QuestNode:
	for c in get_children():
		if c is QuestNode && c._data.id == id:
			return c
	return null


func select_all_quests() -> void:
	_selected_nodes.clear()
	for c in get_children():
		if c is QuestNode:
			c.selected = true
			_selected_nodes.push_back(c.name)


func deselect_all_quests() -> void:
	_selected_nodes.clear()
	for c in get_children():
		if c is QuestNode:
			c.selected = false