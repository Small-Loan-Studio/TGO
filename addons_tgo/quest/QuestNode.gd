@tool
class_name QuestNode
extends GraphNode

const RES_PATH := "res://addons_tgo/quest/quest_node.tscn"

var _editor: EditorInterface
var _data: Quest

var id: String:
	get:
		return _data.id

@onready var _id_label := $LabelID
@onready var _phase_label := $PhasesLabel


func setup(editor: EditorInterface, quest_table: Dictionary) -> void:
	_editor = editor
	title = _data.title
	_id_label.text = "ID: %s" % [_data.id]
	if _data.phases.size() == 0:
		_phase_label.hide()
	else:
		var slot_offset := 2
		var phase_step := 0
		for qp: QuestPhase in _data.phases:
			var label := Label.new()
			label.text = qp.quest.id + " (mf: %s)" % [qp.may_fail]
			add_child(label)
			set_slot_enabled_right(slot_offset + phase_step, true)
			phase_step = phase_step + 1

func _sync_width() -> void:
	queue_redraw()



static func from_quest(q: Quest) -> QuestNode:
	var node := load(RES_PATH).instantiate() as QuestNode
	node._data = q
	return node