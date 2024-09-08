extends Resource
class_name QuestObjective

@export var description: String
@export_enum("Text","Number") var type:String
@export var status: String
@export var amount : int
@export var is_complete: bool = false
