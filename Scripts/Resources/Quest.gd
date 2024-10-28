class_name Quest
extends Resource

signal state_change(id: String)

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

var _parent: Array[Quest]


func _to_string() -> String:
  var next_ids: Array = next.map(func(e: Quest) -> String: return e.id)
  var parent_ids: Array = _parent.map(func(e: Quest) -> String: return e.id)
  return "%s / %s / %s\nnext: %s\nparents: %s" % [id, title, Enums.quest_state_name(state), next_ids, parent_ids]