class_name InventoryManager
extends Node

var _inventories: Dictionary


# This might change in the future depending on how we decide to do Saving and Loading!
func register(id: String, data: Inventory = Inventory.new()) -> Inventory:
	# This is not the same between sessions, not a valid target for saving or loading data
	# Should work fine as a general test
	if _inventories.has(id):
		printerr(id + " already has an inventory associated with it!")
		return data
	_inventories[id] = data
	print("Registered Inventory " + str(id))
	return data


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
