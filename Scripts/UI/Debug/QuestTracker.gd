class_name QuestTracker
extends PanelContainer

const LINE_ITEM_SCENE = preload("res://Scenes/UI/Debug/QuestLineItem.tscn")

var _mgr: QuestManager = null
var _tracked: Array[String] = []

@onready var _quest_container := $VBoxQuests


func setup(mgr: QuestManager) -> void:
	_mgr = mgr
	_mgr.quest_updated.connect(_sync.unbind(1))
	_sync()


func _sync() -> void:
	for c: Node in _quest_container.get_children():
		_quest_container.remove_child(c)
		c.queue_free()
		_tracked.clear()

	var roots := _get_quest_roots()
	for root_quest in roots:
		_process_quest(root_quest, 0)


	for q_id in _mgr.get_active_quests():
		if !(q_id in _tracked):
			_add_questline(_mgr.quest_by_id(q_id), 0)

	if len(_tracked) == 0:
		hide()
	else:
		show()

## returns the quests being tracked that have no phase parent
func _get_quest_roots() -> Array[Quest]:
	var r: Array[Quest] = []
	for id in _mgr.get_active_quests():
		var q := _mgr.quest_by_id(id)
		if q.get_phase_parent() == null:
			r.append(q)
	return r

func _process_quest(q: Quest, indent: int, force_add: bool = false) -> void:
	print("_process_quest(%s)" % [q.id])
	if len(q.phases) > 0:
		_process_phase_parent(q, indent, force_add)
	else:
		_process_normal_quest(q, indent, force_add)

# handle adding a phased quest
func _process_phase_parent(q: Quest, indent: int, force_add: bool) -> void:
	if q.id in _tracked:
		return
	print("_process_phase_parent(%s, %d, %s)" % [q.id, indent, force_add])

	_add_questline(q, indent)

	for phase in q.phases:
		var phase_quest := phase.quest
		if phase_quest.state != Enums.QuestState.DORMANT:
			_process_quest(phase_quest, indent + 1, true)


# handle adding a non-phased quest
func _process_normal_quest(q: Quest, indent: int, force_add: bool) -> void:
	print("_process_normal_quest(%s, %d, %s)" % [q.id, indent, force_add])
	if q.state == Enums.QuestState.DORMANT:
		return

	# disable max line length for the comment alignment
	#gdlint: disable=max-line-length
	if q.is_finished():                                  # this quest is completed
		if len(q.next) == 0:                               # ...and there are no children quests
			if force_add:                                    # ...and we're adding it for phased quest reasons
				_add_questline(q, indent)

		else:                                              # ...and there are children
			# walk from the current quest until things get easy (!finished) or hard (multiple children)
			var cur := q
			while cur.is_finished() && len(q.next) == 1:
				cur = cur.next[0]
			# which situation are we in
			if !cur.is_finished():                           # ...the end of cur's chain is unfinished
				_process_quest(cur, indent, force_add)
				return

			if len(cur.next) == 0:                           # ...the end of cur's chain is just the end of the chain
				_process_quest(cur, indent, force_add)
				return

			if len(cur.next) > 1:                            # ...we've hit a state where cur has multiple children
				for cur_child in cur.next:
					_process_quest(cur_child, indent, force_add)
				return

			printerr("Should never hit this case %s -> %s" % [q.id, str(cur)])
	else:                                                # this quest is incomplete
		_add_questline(q, indent)
	#gdlint: enable=max-line-length


func _add_questline(q: Quest, indent: int) -> void:
	_tracked.append(q.id)
	var line: QuestLineItem = LINE_ITEM_SCENE.instantiate()
	line.track(q, indent)
	_quest_container.add_child(line)