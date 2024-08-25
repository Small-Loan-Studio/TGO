extends Node

class_name QuestManager

@onready var quest_ui : Node = get_node("../CanvasLayer/QuestUI")
@onready var journal : Node = get_node("../CanvasLayer/Journal")
@onready var popup : Node = get_node("../CanvasLayer/Pop-up")

@export var chain_quests: Array[ChainQuest] = []
@export var all_quests: Array[Quest] = []
var active_quests: Array[Quest] = []
var completed_quests: Array[Quest] = []

func _ready()->void:
	#await get_tree().process_frame
	journal.update_quest_window.connect(_on_update_quest_window)
	Signalbus.quest_update.connect(_on_update_quest)
	Dialogic.signal_event.connect(_on_dialogic_signal)
	pass

func add_quest(quest: Quest) -> void:
	active_quests.append(quest)

func complete_quest(quest: Quest) -> void:
	active_quests.erase(quest)
	quest.is_completed = true
	for chain_quest in chain_quests:
		for i in chain_quest.quests.size():
			if chain_quest.quests[i].title == quest.title:
				if i+1  < chain_quest.quests.size():
					print(str(i) + " out" + str(chain_quest.quests.size()))
					active_quests.append(chain_quest.quests[i+1])
				else:
					print("Chain quest completed.")
	completed_quests.append(quest)
	distribute_rewards(quest.rewards)

func update_objectives(quest: Quest,effected_objective_id :int,_value:int) -> void:
	var is_quest_completed :bool = true
	if not quest.objectives[effected_objective_id].is_complete:
		check_objective_status(quest.objectives[effected_objective_id],_value)
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
func _on_update_quest(quest_id:int,effected_objective_id :int,value:int)-> void:
	var does_quest_exist :bool = false
	for quest in active_quests:
		if quest.quest_id == quest_id:
			update_objectives(quest,effected_objective_id,value)
			does_quest_exist = true
	if not does_quest_exist:
		for quest in all_quests:
			if quest.quest_id == quest_id:
				if completed_quests.is_empty():
					print("completed quests are empty adding quest")
					add_quest(quest)
					update_objectives(quest,effected_objective_id,value)
				else:
					for pq in completed_quests:
						if pq.quest_id == quest_id:
							return
						else:
							add_quest(quest)
							update_objectives(quest,effected_objective_id,value)
	pass

func _on_dialogic_signal(argument:String)->void:
	match argument:
		"item_taken":
			return
	pass
