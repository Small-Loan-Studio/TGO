@tool
class_name QuestNode
extends GraphNode

const PHASE_MARGIN_LEFT := 15
const RES_PATH := "res://addons_tgo/quest/quest_node.tscn"
const HEADER_SCENE := "res://addons_tgo/quest/quest_node_header.tscn"

@export var title_font_color: Color = Color.ANTIQUE_WHITE
@export var title_font_color_selected: Color = Color.BLACK

var id: String:
	get:
		return _data.id

var _editor: EditorInterface
var _graph_edit: QuestGraphEdit
var _data: Quest

var _id_port := 0

# How many slots are we using to track non-connectable metadata in the
# header of the node
var _dynamic_slot_start := -1

var _phase_label: Label
var _phase_slot_start := -1

# index: phase index
# value: output port id
var _phase_output_ports: Array[int] = []

var _next_label: Label
var _next_slot := -1
var _next_output_port: int = -1

@onready var _id_label := $LabelID


func _process(_delta: float) -> void:
	# this is somewhat deranged but i just want to get it working at this point.
	# I welcome some future cleanup and usage of the actual theme editing
	# to make this work
	var want_color := title_font_color
	if selected:
		want_color = title_font_color_selected
	if get_titlebar_hbox().get_child_count() > 0:
		var title_label := get_titlebar_hbox().get_child(0)
		if title_label is Label:
			title_label.add_theme_color_override("font_color", want_color)


func setup(editor: EditorInterface, qge: QuestGraphEdit) -> void:
	_editor = editor
	_graph_edit = qge
	sync()


## This removes anything that was added dynamically to the node leaving
## only the ID label behind. It also clears all slot configs and removes
## any connections originating from this node.
func reset() -> void:
	if _dynamic_slot_start == -1:
		# we can return here because this -1 indicates we haven't added any
		# slot contents yet
		return

	var to_remove := []

	# clears all slot configurations
	clear_all_slots()
	# disconnect all edges
	for conn: Dictionary in _graph_edit.connections_from(name):
		_graph_edit.disconnect_node(
			conn["from_node"], conn["from_port"], conn["to_node"], conn["to_port"]
		)
	# clear internal tracking start for ports
	_phase_output_ports.clear()
	_next_output_port = -1

	for c: Control in get_children().slice(_dynamic_slot_start):
		to_remove.append(c)

	for c: Control in to_remove:
		remove_child(c)
		c.queue_free()

	_next_label = null
	_phase_label = null
	_dynamic_slot_start = -1


## Reconstruct this GraphNode from scratch and have it reflect the current state
## of the quest
func sync() -> void:
	# fully reset/remove everything so that our sync logic can approximate simple
	reset()

	title = "  " + _data.title
	_id_label.text = "ID: %s" % [_data.id]

	# enable id input port
	set_slot_enabled_left(0, true)
	_dynamic_slot_start = 1

	_add_condition_label()
	_add_effects_label()

	if _data.phases.size() > 0:
		# adds the phase label and sets up port offset
		_phase_label = load(HEADER_SCENE).instantiate() as Label
		_phase_label.name = "LabelPhases"
		_phase_label.text = "Phases"
		add_child(_phase_label)

		_phase_slot_start = get_children().find(_phase_label) + 1

		var phase_step := 0
		for qp: QuestPhase in _data.phases:
			var empty_phase := qp == null || qp.quest == null
			# if qp == null || qp.quest == null:
			# 	# skip trying to handle an empty phase
			# 	continue

			var label := Label.new()
			if empty_phase:
				label.text = "UNCONNECTED"
			else:
				label.text = qp.quest.id
				if qp.may_fail:
					label.text += " (may fail)"

			var margin := MarginContainer.new()
			margin.add_theme_constant_override("margin_left", PHASE_MARGIN_LEFT)
			margin.add_child(label)
			add_child(margin)

			set_slot_enabled_right(_phase_slot_start + phase_step, true)
			_phase_output_ports.append(phase_step)

			if !empty_phase:
				_graph_edit.connect_node(
					name, phase_step, _graph_edit.node_by_quest_id(qp.quest.id).name, _id_port
				)

			phase_step = phase_step + 1

	_next_label = load(HEADER_SCENE).instantiate() as Label
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
			name, _next_output_port, _graph_edit.node_by_quest_id(next_quest.id).name, _id_port
		)

	var spacer := Container.new()
	spacer.custom_minimum_size.y = 5
	add_child(spacer)

	# TODO: we should probably just relint locally and report new values up :shrug:
	_graph_edit.lint()


func _add_condition_label() -> void:
	var item_conditions := (
		_data
		. conditions
		. filter(func(c: QuestCondition) -> bool: return c is QuestConditionInventory)
		. size()
	)
	var var_conditions := (
		_data
		. conditions
		. filter(func(c: QuestCondition) -> bool: return c is QuestConditionVariable)
		. size()
	)
	var other_conditions := _data.conditions.size() - item_conditions - var_conditions

	var cond_text := []
	if item_conditions > 0:
		cond_text.append("item")
	if var_conditions > 0:
		cond_text.append("variable")
	if other_conditions > 0:
		cond_text.append("other")

	var cond_label := Label.new()
	if cond_text.size() == 0:
		cond_label.text = "Conditions: None"
	else:
		cond_label.text = "Conditions: "
		for i in range(cond_text.size()):
			cond_label.text += cond_text[i]
			if i < cond_text.size() - 1:
				cond_label.text += ", "
	add_child(cond_label)


func _add_effects_label() -> void:
	var effect_label := Label.new()
	if _data.results.size() > 0:
		effect_label.text = "Effects: Yes"
	else:
		effect_label.text = "No Effects"
	add_child(effect_label)


## Given a port number return which phase index it's associated with, if none
## returns -1
func port_phase_index(port: int) -> int:
	return _phase_output_ports.find(port)


## returns the port associated with the next quest connection
func next_port() -> int:
	return _next_output_port


## Update the underlying Quest to add a connection to the Quest represented by tgt_node.
## from_port is used to differentiate between connecting a phase step and next quest.
## Once the data structure is updated we resync this node to it which handles creating
## relevant connections for the graph.
##
## Some validation is done to ensure you can't connect multiple quests in the same phase
## sequence or next array.
func connect_quest(tgt_node: QuestNode, from_port: int) -> void:
	var phase_idx := port_phase_index(from_port)
	if phase_idx != -1:
		# check to see if the quest is already a phase
		var matches := _data.phases.filter(
			func(qp: QuestPhase) -> bool: return qp != null && qp.quest.id == tgt_node.id
		)
		if matches.size() > 0:
			printerr("Attempting to connect a quest already in phases list")
			return

		var qp := QuestPhase.new()
		qp.quest = tgt_node._data
		_data.phases[phase_idx] = qp
	elif from_port == _next_output_port:
		if _data.next.find(tgt_node._data) == -1:
			_data.next.append(tgt_node._data)
		else:
			printerr("Attempting to connect a quest already in next list")

	sync()


## Break a connection between this Quest and the one represented by node. port is
## used to determine if this is a phase or next disconnection. Once the data structure
## is updated we resync the GraphNode and that handles ensuring the connection gets
## removed.
func disconnect_quest(node: QuestNode, port: int) -> void:
	var phase_idx := port_phase_index(port)
	if phase_idx != -1:
		_data.phases[phase_idx] = null
	elif port == _next_output_port:
		var next_idx: int = _data.next.find(node._data)
		if next_idx == -1:
			printerr("Could not find expected quest in next list: ", node.id)
			return
		_data.next.remove_at(next_idx)
	else:
		printerr("Unexpected from/output port: %s.%d" % [node.id, port])
		return

	sync()


## Runs lint on the underlying Quest and returns any errors
func lint() -> Array[String]:
	if _data != null:
		return _data.lint()

	return []


## Constructs a new QuestNode  from a quest.
static func from_quest(q: Quest) -> QuestNode:
	var node := load(RES_PATH).instantiate() as QuestNode
	node._data = q
	return node
