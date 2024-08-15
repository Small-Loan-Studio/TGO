extends Control

class_name Journal
@onready var journal_label : Label = $JournalMainFrame/MarginContainer/VBoxContainer/HBoxContainer2/JournalLabel
@onready var recap : Control = $JournalMainFrame/MarginContainer/VBoxContainer/Recap
@onready var quests : Control = $JournalMainFrame/MarginContainer/VBoxContainer/Quests
@onready var beastiary : Control = $JournalMainFrame/MarginContainer/VBoxContainer/Beastiary
signal monster_discovered(id:int)
@onready var codex_holder := find_child("codex_holder")

#Dictionary to hold every ghost and monsters, will have a seen status to know if it should be shown to player.
#Dictionary for quests
#Quests are quite complicated so they will have their own object which will be stored in quests dictionary
#Preferably a resource extension
#This data below is for testing

func load_beastiary() -> void:
	
	
	return
func _on_monster_encounter(id:int) ->void:
	monster_discovered.emit(id)
	return


func _on_close_pressed()->void:
	self.hide()
	pass # Replace with function body.

func show_one_and_hide_others(tab:int)->void:
	var array : Array = [recap,quests,beastiary]
	for item : Control in array:
		item.hide()
	array[tab].show()
	
	return
func _on_tab_bar_tab_changed(tab:int)->void:
	match tab:
		0:
			journal_label.text = "Recap"
		1:
			journal_label.text = "Quests"
		2:
			journal_label.text = "Beastiary"
	show_one_and_hide_others(tab)
	pass # Replace with function body.
