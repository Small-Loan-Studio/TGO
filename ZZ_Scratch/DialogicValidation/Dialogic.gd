extends Node2D


func setup(_driver: Driver) -> void:
	pass


func _on_pressed() -> void:
	Dialogic.start("res://ZZ_Scratch/DialogicValidation/test_timeline.dtl")
