extends Control

class_name Journal
signal monster_discovered(id:int)
@onready var codex_holder := find_child("codex_holder")

#Dictionary to hold every ghost and monsters, will have a seen status to know if it should be shown to player.
var beastiary : Dictionary = {
	1:{
		"visible":false,
		"name": "Eva Beatrice",
		"description":"a witch that lived 1000 years."
	}
}
#Dictionary for quests
#Quests are quite complicated so they will have their own object which will be stored in quests dictionary
#Preferably a resource extension
var quests : Dictionary = {
		1:{
			"quest_name": "Capture 3 ghosts",
			"description" :"You have heard banshees are attacking villagers, banish them",
			"requirements" : {"Ghosts" : 3},
			"reward" : "Something"
		},
	}
func load_beastiary() -> void:
	
	
	return
func create_quest(id:int,quest_name:String,description:String,requirements:Dictionary,reward:String) -> Quest:
		var quest  := Quest.new()
		quest.id = id
		quest.quest_name = quest_name
		quest.description = description
		quest.requirements = requirements
		quest.reward = reward
		return quest
func _on_monster_encounter(id:int) ->void:
	beastiary[id]["visible"] = true
	monster_discovered.emit(id)
	return
class Quest:
	var id : int
	var quest_name : String
	var description : String
	var requirements : Dictionary
	var reward : String 
	
	
