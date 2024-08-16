extends Control

class_name Journal

@onready var journal_label : Label = $JournalMainFrame/MarginContainer/VBoxContainer/HBoxContainer2/JournalLabel
@onready var recap : Control = $JournalMainFrame/MarginContainer/VBoxContainer/RecapWindow
@onready var quests : Control = $JournalMainFrame/MarginContainer/VBoxContainer/QuestsWindow
@onready var beastiary : Control = $JournalMainFrame/MarginContainer/VBoxContainer/Beastiary
signal monster_discovered(id:int)
signal update_quest_window(tab:int)

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
func update()->void:
	_on_tab_bar_tab_changed(0)
	_on_quest_tab_bar_tab_changed(0)
	$TabBar.current_tab = 0
	quests.find_child("QuestTabBar").current_tab = 0
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

func update_quest_tab(quests:Array[Quest])->void:
	var quest_entry_card : PackedScene = preload("res://Scenes/UI/Journal/QuestEntry.tscn")
	var quest_container : Control = %JournalQuests
	var _children := quest_container.get_children()
	for child in _children:
		child.queue_free()
	for quest in quests:
		var instance : Control = quest_entry_card.instantiate()
		instance.quest = quest
		quest_container.add_child(instance)
	pass
func _on_quest_tab_bar_tab_changed(tab:int)->void:
	update_quest_window.emit(tab)
	pass # Replace with function body.
