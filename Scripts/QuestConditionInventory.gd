class_name QuestConditionInventory
extends QuestCondition

@export var inventory_id: String
@export_enum("has", "does not have") var check: String = "has"
@export var target_item: Item

func _ready() -> void:
	type = Enums.QuestConditionType.INVENTORY