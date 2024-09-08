extends Control

@onready var quest_name_node : Label = $PanelContainer/VBoxContainer/QuestName
@onready var description_node : RichTextLabel = $PanelContainer/VBoxContainer/Description
@onready var requirements_node : VBoxContainer = $PanelContainer/VBoxContainer/Requirements
@onready var req : PackedScene = preload("res://Scenes/UI/Quest/ReqCard.tscn")

func _ready()->void:
	Signalbus.quest_updated.connect(_on_update)
	pass
	
	
func update_quest_ui(quest: Quest)->void:
	quest_name_node.text = quest.title
	description_node.text = quest.description
	for child in requirements_node.get_children():
		child.queue_free()
	for requirement : QuestObjective in quest.objectives:
		var reqcard : HBoxContainer = req.instantiate()
		requirements_node.add_child(reqcard)
		reqcard.set_text(requirement.description)
		reqcard.set_status(requirement.status)
		
	return


func _on_close_pressed()->void:
	self.hide()
	pass # Replace with function body.
func _on_update(quest:Quest)->void:
	self.show()
	update_quest_ui(quest)
	return
	
