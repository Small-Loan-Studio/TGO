class_name InventoryManager
extends Node

var _inventories: Dictionary

func get_inventory(id: String) -> Inventory:
	if _inventories.has(id):
		return _inventories[id]
	print(id + " does not have an inventory associated with it! Creating a new one")
	_inventories[id] = Inventory.new()
	return _inventories[id]


# Unsure if these will be used, placeholders
func _load() -> void:
	pass


func _save() -> void:
	pass
