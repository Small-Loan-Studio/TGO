extends Node

class_name QuestManager

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
var all_quests: Array[Quest] = []
var active_quests: Array[Quest] = []
var completed_quests: Array[Quest] = []

func add_quest(quest: Quest) -> void:
	active_quests.append(quest)

func complete_quest(quest: Quest) -> void:
	active_quests.erase(quest)
	quest.is_completed = true
	completed_quests.append(quest)
	distribute_rewards(quest.rewards)
func update_objectives(quest: Quest) -> void:
	for objective in quest.objectives:
		if not objective.is_complete:
			check_objective_status(objective)
			
func distribute_rewards(rewards: Array) -> void :
	
	return
func check_objective_status(objective:QuestObjective)->void:
	return
