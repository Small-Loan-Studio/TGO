extends Node

class_name QuestManager

@onready var quest_ui : Node = get_node("../CanvasLayer/QuestUI")
@onready var journal : Node = get_node("../CanvasLayer/Journal")
@onready var popup : Node = get_node("../CanvasLayer/Pop-up")
func _ready()->void:
	#await get_tree().process_frame
	journal.update_quest_window.connect(_on_update_quest_window)
	Signalbus.quest_update.connect(_on_update_quest)
	Dialogic.signal_event.connect(_on_dialogic_signal)
	pass
@export var all_quests: Array[Quest] = []
var active_quests: Array[Quest] = []
var completed_quests: Array[Quest] = []

func add_quest(quest: Quest) -> void:
	active_quests.append(quest)

func complete_quest(quest: Quest) -> void:
	active_quests.erase(quest)
	quest.is_completed = true
	completed_quests.append(quest)
	distribute_rewards(quest.rewards)

func update_objectives(quest: Quest,effected_objective :String,_value:int) -> void:
	var is_quest_completed :bool = true
	for objective in quest.objectives:
		if not objective.is_complete:
			check_objective_status(objective,_value)
			update_quest_ui(quest)
	for objective in quest.objectives:
		if not objective.is_complete:
			is_quest_completed = false
	if is_quest_completed:
		complete_quest(quest)
#TODO:Distribute rewards after quest is complete.
#It will be implemented after we have other systems in place.
func distribute_rewards(rewards: Array) -> void :
	if rewards.is_empty():
		return
	else:
		pass
	
	return
func check_objective_status(objective:QuestObjective,_value:int)->void:
	match objective.type:
		"Text":
			if _value == 0:
				objective.is_complete = false
				objective.status = "-"
			elif _value == 1:
				objective.is_complete = true
				objective.status = "Done"
		"Number":
			if objective.amount == _value:
				objective.is_complete = true
				objective.status = "Done"
			elif objective.amount > _value:
				objective.status = str(_value) + "/" + str(objective.amount)
	
	return
func update_quest_ui(quest:Quest)->void:
	quest_ui.show()
	quest_ui.update_quest_ui(quest)
	pass
func _on_update_quest_window(tab:int)->void:
	match tab:
		0:
			journal.update_quest_tab(active_quests)
			pass
		1:
			journal.update_quest_tab(completed_quests)
			pass
	pass
	#TODO: Update UI when one quest is affected.
func _on_update_quest(quest_id:int,effected_objective :String,value:int)-> void:
	var does_quest_exist :bool = false
	
	for quest in active_quests:
		if quest.quest_id == quest_id:
			update_objectives(quest,effected_objective,value)
			does_quest_exist = true
	if not does_quest_exist:
		for quest in all_quests:
			if quest.quest_id == quest_id:
				if completed_quests.is_empty():
					print("completed quests are empty adding quest")
					add_quest(quest)
					update_objectives(quest,effected_objective,value)
				else:
					for pq in completed_quests:
						if pq.quest_id == quest_id:
							return
						else:
							add_quest(quest)
							update_objectives(quest,effected_objective,value)
	pass

func _on_dialogic_signal(argument:String)->void:
	match argument:
		"item_taken":
			return
	pass
