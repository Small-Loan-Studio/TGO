class_name InventoryManager
extends Node

signal inventory_updated(id: String)

var _inventories: Dictionary


func get_inventory(id: String) -> Inventory:
	id = id.to_lower()
	if _inventories.has(id):
		return _inventories[id]
	print(id + " does not have an inventory associated with it! Creating a new one")

	# create new inventory
	var new_inv := Inventory.new()
	new_inv.inventory_updated.connect(Callable(_emit_update_signal).bind(id))
	_inventories[id] = new_inv

	return _inventories[id]


func _emit_update_signal(_inv: Inventory, inv_id: String) -> void:
	inventory_updated.emit(inv_id)


# Unsure if these will be used, placeholders
func _load() -> void:
	pass


func _save() -> void:
	pass
