#Resource to be added in quest manager. Will hold data for quests.
extends Resource
class_name Quest

@export var quest_id: String
@export var title: String
@export var description: String
@export var is_completed: bool = false
@export var objectives: Array[QuestObjective] = []
@export var rewards: Array[QuestReward] = []
