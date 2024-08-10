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

func load_beastiary() -> void:
	
	
	return
func _on_monster_encounter(id:int) ->void:
	beastiary[id]["visible"] = true
	monster_discovered.emit(id)
	return
