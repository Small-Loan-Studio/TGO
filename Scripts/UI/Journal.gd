extends Control

class_name Journal

#Dictionary to hold every ghost and monsters, will have a seen status to know if it should be shown to player.
var bestiary : Dictionary = {}
#Dictionary for quests
#Quests are quite complicated so they will have their own object which will be stored in quests dictionary
#Preferably a resource extension
var quests : Array 
#{
	#1:{
		#quest_name: "Capture 3 ghosts",
		#description :"You have heard banshees are attacking villagers, banish them",
		#requirements : {"Ghosts" : 3},
		#reward : "Something"
	#},
#}
func create_quest(id:int,quest_name:String,description:String,requirements:Dictionary,reward:String) -> Quest:
		var quest  := Quest.new()
		quest.id = id
		quest.quest_name = quest_name
		quest.description = description
		quest.requirements = requirements
		quest.reward = reward
		return quest
class Quest:
	var id : int
	var quest_name : String
	var description : String
	var requirements : Dictionary
	var reward : String 
	
	
