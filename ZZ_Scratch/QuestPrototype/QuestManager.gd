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

func _ready()->void:
	Signalbus.update_quest.connect(_on_update_quest)
	pass
@export var all_quests: Array[Quest] = []
var active_quests: Array[Quest] = []
var completed_quests: Array[Quest] = []

@onready var quest_ui : Node = get_node("../CanvasLayer/QuestUI")
@onready var journal : Node = get_node("../CanvasLayer/Journal")
@onready var popup : Node = get_node("../CanvasLayer/Pop-up")

func add_quest(quest: Quest) -> void:
	active_quests.append(quest)

func complete_quest(quest: Quest) -> void:
	active_quests.erase(quest)
	quest.is_completed = true
	completed_quests.append(quest)
	distribute_rewards(quest.rewards)
func update_objectives(quest: Quest,effected_objective :String) -> void:
	for objective in quest.objectives:
		if not objective.is_complete:
			check_objective_status(objective)
			
func distribute_rewards(rewards: Array) -> void :
	if rewards.is_empty():
		return
	else:
		pass
	
	return
func check_objective_status(objective:QuestObjective)->void:
	objective.is_complete = true
	return
func update_quest_ui()->void:
	
	pass
#TODO: Update UI when one quest is affected.
func _on_update_quest(quest_id:int,effected_objective :String = "" )-> void:
	var does_quest_exist :bool = false
	for quest in active_quests:
		if quest.quest_id == quest_id:
			update_objectives(quest,effected_objective)
			does_quest_exist = true
	if not does_quest_exist:
		for quest in all_quests:
			if quest.quest_id == quest_id:
				for pq in completed_quests:
					if pq.quest_id == quest_id:
						return
					else:
						add_quest(quest)
	pass

