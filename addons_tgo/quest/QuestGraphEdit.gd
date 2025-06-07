@tool
class_name QuestGraphEdit
extends GraphEdit

@export var _lint_report: LintReport
@export var _quest_id_dlg: QuestIDPanel

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

# nominally a debounce marker but really we're setting this on selection and
# immediately after a sync bc of a property_edited thing
var _debounce_mark_msec: int = 0
# how long to wait before forcing a sync after an edit has been made... sorta
# see above
var _debounce_wait_msec: int = 500

# captures lint errors not associated with a single node
var _global_errs: Array[String] = []

var _editor: EditorInterface


func _ready() -> void:
	var hbox := get_menu_hbox()

	var refresh := Button.new()
	refresh.text = "Reload"
	refresh.pressed.connect(full_reset)
	hbox.add_child(refresh)

	var save_layout := Button.new()
	save_layout.text = "Save Layout"
	save_layout.pressed.connect(_save_layout)
	hbox.add_child(save_layout)

	var load_layout := Button.new()
	load_layout.text = "Load Layout"
	load_layout.pressed.connect(do_layout)
	hbox.add_child(load_layout)

	_global_errs = _refresh_quests()


# dump all quest state, all corresponding nodes, and any registered connections
func _reset() -> void:
	_quests.clear()
	clear_connections()
	for c in get_children():
		if c is QuestNode:
			remove_child(c)
			c.queue_free()
	lint()


# dump internal state and reload / re-lint to capture changes made that we
# didn't catch via signal or whatever
func full_reset() -> void:
	_reset()
	_global_errs = _refresh_quests()
	_setup()


func setup(editor: EditorInterface) -> void:
	_editor = editor

	# we use this to track when a property is changed to an edited quest
	# some attention to detail is needed though as this is fired regardless
	# of the quest visualizer being focused so it may not be an object we
	# care about
	# TODO: This doesn't seem to work for changes nested into the edited
	# object, we may need to straight up poll instead of relying on a signal
	# to indicate changes
	if !EditorInterface.get_inspector().property_edited.is_connected(_edited_object_changed):
		EditorInterface.get_inspector().property_edited.connect(_edited_object_changed)

	_setup()


# adds known quests to the graph container, sets up the QuestNode (c.f.
# [[QuestNode.setup]]), and then initiaties a layout
func _setup() -> void:
	# this is a list of nodes to setup, we don't do this when added because
	# it will try to create links to other nodes which may not tracked in
	# the graph yet
	var to_sync := []

	for q: Quest in _quests.values():
		var node := QuestNode.from_quest(q)
		add_child(node)
		to_sync.push_back(node)

	for qn: QuestNode in to_sync:
		qn.setup(_editor, self)

	do_layout()


# checks teh resource path for a saved layout and use it if found.
# if none exists, and for nodes that are not included uses the default
# algo
func do_layout() -> void:
	var layout := QuestLayout.load()
	var positions_dict := {}
	var last_offset := Vector2(0, 0)

	if layout != null:
		zoom = layout.zoom
		positions_dict = layout.positions
		last_offset = layout.scroll_offset

	if positions_dict.size() > 0:
		for id: String in positions_dict.keys():
			var quest_node := node_by_quest_id(id)
			if quest_node == null:
				printerr("Skipping position for deleted quest: ", id)
				continue
			quest_node.set_position_offset(positions_dict[id])

	# only do this if there are un-positioned nodes or it'll do a full layout
	if positions_dict.size() < _quests.size():
		for c in get_children():
			if c is QuestNode:
				c.selected = !positions_dict.has(c.id)
		arrange_nodes()
		deselect_all_quests()

	scroll_offset = last_offset


func _save_layout() -> void:
	var nodes: Array[QuestNode] = []
	for c in get_children():
		if c is QuestNode:
			nodes.append(c)
	QuestLayout.save(zoom, scroll_offset, nodes)


func _force_sync_edits() -> void:
	_debounce_mark_msec = 0

	# update quest dictionary to node id changing
	if _last_edited_id != _edited_node.id:
		if _last_edited_id != "":
			_quests.erase(_last_edited_id)
		if _edited_node.id != "":
			if _quests.has(_edited_node.id) && _quests[_edited_node.id] != _edited_node._data:
				# TODO: it is probably not too hard to *not* do this but I don't
				# have cycles to think about it rn
				printerr(
					(
						"You're overwriting an existing node in quest state tracking, things"
						+ "will be weird. Suggest change to a unique ID and reload."
					)
				)
			_quests[_edited_node.id] = _edited_node._data
		_last_edited_id = _edited_node.id

	_edited_node.sync()


func _edited_object_changed(_prop: String) -> void:
	if !visible:
		# don't worry about things if the quest visualization isn't focused
		return
	_debounce_mark_msec = Time.get_ticks_msec()


# loads quests from disk, returns an array of errors
func _refresh_quests() -> Array[String]:
	var errs: Array[String] = []

	var quest_paths := Utils.walk_directory(
		Utils.QUEST_DIR, func(s: String) -> bool: return s.ends_with(".tres")
	)
	for path in quest_paths:
		var quest := ResourceLoader.load(Utils.QUEST_DIR.path_join(path)) as Quest
		if quest != null:
			if _quests.has(quest.id):
				(
					errs
					. append(
						(
							"E: Global (%s): multiple quests with ID '%s', only the first was registered"
							% [path, quest.id]
						)
					)
				)
			else:
				_quests[quest.id] = quest
	return errs


func _node_selected(node: Node) -> void:
	if node is QuestNode:
		if node.id in _selected_nodes:
			return
		_selected_nodes.push_back(node.name)
	_update_selection()


func _node_deselected(_node: Node) -> void:
	_selected_nodes.clear()
	_selected_nodes.assign(get_selected_nodes().map(func(n: QuestNode) -> String: return n.name))
	_update_selection()


func _update_selection() -> void:
	if _selected_nodes.size() == 1:
		var quest_node: QuestNode = get_node(_selected_nodes[0])
		_edited_node = quest_node
		_last_edited_id = _edited_node.id
		# workaround to handle property_edited signal not triggering for nested
		# objects
		_debounce_mark_msec = Time.get_ticks_msec()
		EditorInterface.edit_resource(_quests[quest_node._data.id])
	else:
		EditorInterface.edit_node(null)
		if _edited_node != null:
			_force_sync_edits()
			_edited_node = null
			_last_edited_id = ""


func _process(_delta: float) -> void:
	if _edited_node != null && _debounce_mark_msec != 0:
		var now := Time.get_ticks_msec()
		if (now - _debounce_mark_msec) > _debounce_wait_msec:
			_force_sync_edits()
			# workaround to handle property_edited signal doesn't trigger for
			# nested objects
			_debounce_mark_msec = now


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


## Query connection list and return all outbound connections from the
## specified node.
func connections_from(node: StringName) -> Array[Dictionary]:
	var list := get_connection_list().filter(
		func(d: Dictionary) -> bool: return d["from_node"] == node
	)
	var r: Array[Dictionary] = []
	r.assign(list)
	return r


func _on_connect_request(
	from_node: StringName, from_port: int, to_node: StringName, to_port: int
) -> void:
	var from: QuestNode = get_node(str(from_node))
	var to: QuestNode = get_node(str(to_node))
	# print("_on_connect_request: %s.%d -> %s.%d" % [ from.id, from_port, to.id, to_port])

	if to_port != 0:
		printerr("Unexpected port pair %d -> %d" % [from, to_port])
		return

	from.connect_quest(to, from_port)


func _on_disconnect_request(
	src_node: StringName, src_port: int, tgt_node: StringName, tgt_port: int
) -> void:
	var src: QuestNode = get_node(str(src_node))
	var tgt: QuestNode = get_node(str(tgt_node))
	# print("_on_disconnect_request: %s.%d -> %s.%d" % [src.id, src_port, tgt.id, tgt_port])

	if tgt_port != 0:
		printerr("Unexpected port pair %d -> %d" % [src_port, tgt_port])
		return

	src.disconnect_quest(tgt, src_port)


# TODO: this needs cleanup but ~works so I'm leaving it in
func _on_connection_to_empty(
	from_node: StringName, from_port: int, release_position: Vector2
) -> void:
	_quest_id_dlg.display(get_global_mouse_position())
	var new_quest_data: Array[String] = await _quest_id_dlg.completed
	if new_quest_data == []:
		return

	var new_quest_id := new_quest_data[0]
	var new_quest_title := new_quest_data[1]

	var tag_count := 0
	var path := Utils.QUEST_DIR.path_join("%s%s.tres" % [new_quest_id, ""])
	while true:
		if !FileAccess.file_exists(path):
			break
		tag_count += 1
		path = Utils.QUEST_DIR.path_join("%s_%d.tres" % [new_quest_id, tag_count])

	var q := Quest.new()
	q.id = new_quest_id
	q.title = new_quest_title
	ResourceSaver.save(q, path)

	# Load quest back in from disk otherwise we'll be working with a local
	# instance of the resource
	q = ResourceLoader.load(path) as Quest

	_quests[new_quest_id] = q
	var node := QuestNode.from_quest(q)
	add_child(node)
	node.setup(_editor, self)
	node.set_position_offset((scroll_offset + release_position) / zoom)

	get_node(str(from_node)).connect_quest(node, from_port)


## runs lint on all known quests and refreshes the list report with that data.
## Notably tihs does *not* re-run global lint errors since that is mostly checking
## for id collisions which we can really only tell when loading from disk
func lint() -> void:
	_lint_report.lint_clear()
	_lint_report.global_errs = _global_errs.duplicate()
	for q_id: String in _quests.keys():
		_lint_report.add_quest_lint(q_id, _quests[q_id].lint())
	for id: String in _quests:
		if detect_cycle(_quests[id]):
			_lint_report.global_errs.append("E: Cycle detected in quest graph")
			break
	_lint_report.update_display()


func detect_cycle(quest: Quest) -> bool:
	var visited := {}
	visit_nodes(quest, visited)
	return len(visited[quest.id]) > 0


func visit_nodes(quest: Quest, visited: Dictionary) -> void:
	if quest.id in visited:
		return
	visited[quest.id] = {}
	for q: Quest in quest.next:
		visit_nodes(q, visited)
		visited[q.id][quest.id] = true
	for p: QuestPhase in quest.phases:
		if p == null || p.quest == null:
			continue
		visit_nodes(p.quest, visited)
		visited[p.quest.id][quest.id] = true


## centers the display on a specific node looked up by quest id
func _focus_node(quest_id: String) -> void:
	var node := node_by_quest_id(quest_id)
	if node == null:
		printerr("Unable to find quest for focus: ", quest_id)
		return
	deselect_all_quests()
	node.selected = true

	var width := get_rect().size.x / 2
	var height := get_rect().size.y / 2

	scroll_offset = node.get_position_offset() - Vector2(width, height)
