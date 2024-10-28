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