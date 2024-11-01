class_name QuestTracker
extends PanelContainer

const LINE_ITEM_SCENE = preload("res://Scenes/UI/Debug/QuestLineItem.tscn")

@onready var _quest_container := $VBoxQuests

var _mgr: QuestManager = null
var _tracked: Array[String] = []

func setup(mgr: QuestManager) -> void:
	_mgr = mgr
	_mgr.quest_updated.connect(_sync.unbind(1))
	_sync()


func _sync() -> void:
	for c: Node in _quest_container.get_children():
		_quest_container.remove_child(c)
		c.queue_free()
		_tracked.clear()

	var i := 0

	var roots := _get_quest_roots()
	for root_quest in roots:
		_add_quest(root_quest, 0)


	for q_id in _mgr.get_active_quests():
		var quest_line: QuestLineItem = LINE_ITEM_SCENE.instantiate()
		var q := _mgr.quest_by_id(q_id)
		quest_line.track(q, i)
		_quest_container.add_child(quest_line)
		i = i + 1


## returns the quests being tracked that have no phase parent; this could be
## because
func _get_quest_roots() -> Array[Quest]:
	var r: Array[Quest] = []
	for id in _mgr.get_active_quests():
		var q := _mgr.quest_by_id(id)
		if q.get_phase_parent() == null:
			r.append(q)
	return r


func _add_quest(q: Quest, indent: int) -> void:
	if q.id in _tracked:
		return

	_tracked.append(q.id)
	var quest_line: QuestLineItem = LINE_ITEM_SCENE.instantiate()
	quest_line.track(q, indent)
	_quest_container.add_child(quest_line)

	# if len(q.phases) > 0:
	for q_phase in q.phases:
		var phase_quest := q_phase.quest
		if phase_quest != null:
			if len(phase_quest.next) == 0:
				# this is not a phased chain, just treat it normally
				_add_quest(phase_quest, indent + 1)
			else:
				# this is a phased chain, get the first incomplete quest (or last quest)
				var candidates: Array[Quest] = []
				for phase_quest_next in phase_quest.next:
					if !phase_quest_next.is_finished():
						candidates.append(phase_quest_next)

func _process_quest(q: Quest, indent: int) -> void:
	if len(q.phases) > 0:
		_process_phase_parent(q, indent)
	else:
		_process_normal_quest(q, indent)

func _process_phase_parent(q: Quest, indent: int) -> void:
	if q.id in _tracked:
		return

	_add_questline(q, indent)

	for phase in q.phases:
		var phase_quest := phase.quest
		_process_quest(phase_quest, indent + 1)


func _process_normal_quest(q: Quest, indent: int) -> void:
	pass


func _add_questline(q: Quest, indent: int) -> void:
	_tracked.append(q.id)
	var line: QuestLineItem = LINE_ITEM_SCENE.instantiate()
	line.track(q, indent)
	_quest_container.add_child(line)