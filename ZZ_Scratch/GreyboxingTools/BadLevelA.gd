@tool
class_name BadLevelA
extends LevelBase


func level_setup() -> void:
	print("BadLevelA.level_setup")


func _on_test_a_triggered(id:String, state:bool) -> void:
	print("_on_test_a_triggered(%s, %s)" % [id, state])
