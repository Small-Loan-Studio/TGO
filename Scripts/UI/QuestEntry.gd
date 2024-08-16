extends Control

signal update_quest_card(quest:Quest)
var quest : Quest
@onready var button1 : Button = $Button 
func _ready()->void:
	if quest:
		button1.text = quest.title
	return
	


func _on_button_pressed()->void:
	update_quest_card.emit(quest)
	pass # Replace with function body.
