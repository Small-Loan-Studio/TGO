@tool
class_name QuestNode
extends GraphNode

const RES_PATH := "res://addons_tgo/quest/quest_node.tscn"

var _editor: EditorInterface
var _graph_edit: QuestGraphEdit
var _data: Quest

var id: String:
	get:
		return _data.id

@onready var _id_label := $LabelID
@onready var _phase_label := $LabelPhases


func setup(editor: EditorInterface, qge: QuestGraphEdit) -> void:
	_editor = editor
	_graph_edit = qge
	sync()

func sync() -> void:
	title = _data.title
	_id_label.text = "ID: %s" % [_data.id]

	var to_remove := []

	clear_all_slots()
	for c in get_children():
		if c.name == "LabelID":
			continue
		if c.name == "LabelPhases":
			continue
		to_remove.append(c)

	for c: Control in to_remove:
		remove_child(c)
		c.queue_free()

	# enable id input port
	set_slot_enabled_left(0, true)

	if _data.phases.size() == 0:
		_phase_label.hide()
	else:
		_phase_label.show()
		var slot_offset := 2
		var phase_step := 0
		for qp: QuestPhase in _data.phases:
			var label := Label.new()
			label.text = qp.quest.id + " (mf: %s)" % [qp.may_fail]
			add_child(label)
			set_slot_enabled_right(slot_offset + phase_step, true)

			# TODO: ffff, remove magic numbers, add in some consts to get
			# approximately stable/readable lookups
			_graph_edit.connect_node(
				name, # the name of this node (connect from)
				phase_step, # the current phase port index
				_graph_edit.node_by_quest_id(qp.quest.id).name, # the name of the target node
				0) # the target port, 0 because id is always the first port

			phase_step = phase_step + 1

func _sync_width() -> void:
	queue_redraw()


static func from_quest(q: Quest) -> QuestNode:
	var node := load(RES_PATH).instantiate() as QuestNode
	node._data = q
	return node