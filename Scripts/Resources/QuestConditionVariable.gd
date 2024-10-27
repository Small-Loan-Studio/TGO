class_name QuestConditionVariable
extends QuestCondition

@export var variable: String
@export_enum ("is", "is net") var check: String
@export var target_value: String

func _ready() -> void:
	type = Enums.QuestConditionType.VARIABLE