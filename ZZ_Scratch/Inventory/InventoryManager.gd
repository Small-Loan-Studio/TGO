class_name InventoryManager
extends Node

var inventories: Dictionary

# This might change in the future depending on how we decide to do Saving and Loading!
func register(actor: Node, data: Inventory = Inventory.new()) -> Inventory:
	# This is not the same between sessions, not a valid target for saving or loading data
	# Should work fine as a general test
	var id: int = actor.get_instance_id()
	if inventories.has(id):
		printerr(str(id) + " already has an inventory associated with it!")
		return data
	else:
		inventories[id] = data
		print("Registered Inventory " + str(id))
		return data

func get_inventory(actor: Node) -> Inventory:
	var id: int = actor.get_instance_id()
	if inventories.has(id):
		return inventories[id]
	else:
		printerr(str(id) + " does not have an inventory associated with it!")
		return Inventory.new()

# Unsure if these will be used, placeholders
func _load() -> void:
	pass
func _save() -> void:
	pass
