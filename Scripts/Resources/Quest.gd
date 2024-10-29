class_name Quest
extends Resource


signal state_change(id: String, context: Dictionary)


@export var id: String
@export var title: String
@export var description: String

@export var manual_start: bool = false
@export var state: Enums.QuestState
@export var conditions: Array[QuestCondition]

@export_category("Quest line structure")
@export var phases: Array[QuestPhase]
@export var results: Array[Effect]
@export var next: Array[Quest]

var _mgr: QuestManager

# Set during Quest linking if this quest is part of a phased parent
var _phase_parent: Quest

# Set during Quest linking if this quest is a child of some other Quest
var _parent: Array[Quest]


func get_phase_parent() -> Quest:
  # TODO: what to do if there are multiple parents with multiple phase parents
  # (lol maybe don't set that situation up dumbass / maybe we need to lint for it)
  return null



func _to_string() -> String:
  var next_ids: Array = next.map(func(e: Quest) -> String: return e.id)
  var parent_ids: Array = _parent.map(func(e: Quest) -> String: return e.id)
  return "%s / %s / %s\nnext: %s\nparents: %s" % [id, title, Enums.quest_state_name(state), next_ids, parent_ids]