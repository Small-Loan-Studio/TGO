@tool
class_name QuestNode
extends GraphNode

# How many slots are used to track meta data
const HEADER_SLOT_OFFSET := 1
const RES_PATH := "res://addons_tgo/quest/quest_node.tscn"
const LABEL_SCENE := "res://addons_tgo/quest/quest_node_header.tscn"

var _editor: EditorInterface
var _graph_edit: QuestGraphEdit
var _data: Quest

var _id_port := 0

var _phase_label: Label
var _phase_slot_start := -1
var _phase_output_ports: Array[int] = []

var _next_label: Label
var _next_slot := -1
var _next_output_port: int = -1

var id: String:
	get:
		return _data.id

@onready var _id_label := $LabelID


func setup(editor: EditorInterface, qge: QuestGraphEdit) -> void:
	_editor = editor
	_graph_edit = qge
	sync()

func sync() -> void:
	title = _data.title
	_id_label.text = "ID: %s" % [_data.id]

	var to_remove := []

	# clears all slot configurations
	clear_all_slots()
	# disconnect all edges
	for conn: Dictionary in _graph_edit.connections_from(name):
		_graph_edit.disconnect_node(
			conn["from_node"],
			conn["from_port"],
			conn["to_node"],
			conn["to_port"])
	# clear internal tracking start for ports
	_phase_output_ports.clear()
	_next_output_port = -1

	# TODO: clearing a connection between two nodes is a trash fire, we have no
	# way to easily look up an connection given source and port so we need to
	# track that in the GraphNode itself... which we need to do to resync the
	# connections in the event an edit removed a linkage between this node and
	# some other quest. jfc

	for c: Control in get_children().slice(HEADER_SLOT_OFFSET):
		to_remove.append(c)

	for c: Control in to_remove:
		remove_child(c)
		c.queue_free()

	_next_label = null
	_phase_label = null

	# enable id input port
	set_slot_enabled_left(0, true)

	if _data.phases.size() == 0:
		if _phase_label != null:
			remove_child(_phase_label)
			_phase_label.queue_free()
			_phase_label = null
			_phase_slot_start = -1
	else:
		# adds the phase label and sets up port offset
		_phase_label = load(LABEL_SCENE).instantiate() as Label
		_phase_label.name = "LabelPhases"
		_phase_label.text = "Phases"
		add_child(_phase_label)

		_phase_slot_start = get_children().find(_phase_label) + 1

		var phase_step := 0
		for qp: QuestPhase in _data.phases:
			if qp == null || qp.quest == null:
				# skip trying to handle an empty phase
				continue

			var label := Label.new()
			label.text = qp.quest.id
			if qp.may_fail:
				label.text += " (may fail)"
			add_child(label)
			set_slot_enabled_right(_phase_slot_start + phase_step, true)
			_phase_output_ports.append(phase_step)

			_graph_edit.connect_node(
				name, phase_step, _graph_edit.node_by_quest_id(qp.quest.id).name, _id_port)

			phase_step = phase_step + 1

	_next_label = load(LABEL_SCENE).instantiate() as Label
	_next_label.name = "LabelNext"
	_next_label.text = "Next Quest"
	add_child(_next_label)
	_next_slot = get_children().find(_next_label)
	set_slot_enabled_right(_next_slot, true)
	_next_output_port = _phase_output_ports.size()

	for next_quest in _data.next:
		if next_quest == null || next_quest.id == "":
			continue
		_graph_edit.connect_node(
			name, _next_output_port, _graph_edit.node_by_quest_id(next_quest.id).name, _id_port)


func _sync_width() -> void:
	queue_redraw()


static func from_quest(q: Quest) -> QuestNode:
	var node := load(RES_PATH).instantiate() as QuestNode
	node._data = q
	return node