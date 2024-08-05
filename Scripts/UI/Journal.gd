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
#This data below is for testing
var quests : Dictionary = {
		1:{
			"quest_name": "Find your way out",
			"description" :"Escape the underground",
			"segments":{
				0:{
					"name":"Find your way out.",
					"description":"It's so dark. I need to find some kind of light.",
					"requirements":{
						0 : "Find light source."
					},
				},
				1:{
					"name":"Investigate your surroundings.",
					"description":"I have found a light source, where the bloody hell I am.",
					"requirements":{
						0: "Find an exit"
					}
				},
				2:{
					"name":"Open the door.",
					"description":"This door seems to be locked. Maybe I can open it with my lockpick",
					"requirements":{
						0:"Use your lockpick to open closed door."
					}
				},
				3:{
					"name":"Find the exit.",
					"description":"I successfully opened the door now where is the exit.",
					"requirements":{
						0:"Find the exit."
					}
				}
				
			},
			"reward" : "Something"
		},
	}
func load_beastiary() -> void:
	
	
	return
func create_quest(id:int,quest_name:String,description:String,segments : Dictionary,requirements:Dictionary,reward:String) -> Quest:
		var quest  := Quest.new()
		quest.id = id
		quest.quest_name = quest_name
		quest.description = description
		quest.requirements = requirements
		quest.segments = segments
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
	var segments : Dictionary
	var reward : String 
	
	
