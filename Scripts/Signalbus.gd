extends Node
# I added a Signalbus to make it possible 
# to update anyquest from any npc or space or interactable
# It will stay like this until we find a better way.
signal quest_update(quest_id:int,update_objective:int,value:int)
signal quest_updated(quest:Quest)
