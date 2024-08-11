extends Control

@onready var quest_name_node : Label = $PanelContainer/VBoxContainer/QuestName
@onready var description_node : RichTextLabel = $PanelContainer/VBoxContainer/Description
@onready var requirements_node : VBoxContainer = $PanelContainer/VBoxContainer/Requirements

func update_quest_ui(quest: Quest)->void:
	quest_name_node.text = quest.title
	description_node.text = quest.description
	
	for child in requirements_node.get_children():
		child.queue_free()
	for requirement : QuestObjective in quest.objectives:
		var reqcard : ReqCard = ReqCard.new()
		reqcard.set_text(requirement.description)
		reqcard.set_status(requirement.status)
		requirements_node.add_child(reqcard)
	return
