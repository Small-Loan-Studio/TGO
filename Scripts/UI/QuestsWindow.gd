extends Control
@onready var quest_card := $HBoxContainer/QuestCard


func _on_journal_quests_child_entered_tree(node:Node)->void:
	node.update_quest_card.connect(_on_update_quest_card)
	pass # Replace with function body.

func _on_update_quest_card(quest:Quest)->void:
	quest_card.update(quest)
	return
