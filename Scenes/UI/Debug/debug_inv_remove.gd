class_name DebugInvRemove
extends HBoxContainer

@onready var _inventory: Inventory

func setup(inv: Inventory) -> void:
	_inventory = inv

func _on_button_pressed() -> void:
	_inventory.remove_by_id("QUEST_KEY", 1)
