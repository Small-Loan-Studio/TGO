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


func _load(filepath: String) -> bool:
	_check_file_location(filepath)
	print("loading inventory")

	return 0


func save(filepath: String) -> void:
	_check_file_location(filepath + "inventory.json")


func _check_file_location(filepath: String) -> void:
	var error: int
	if !DirAccess.dir_exists_absolute(filepath):
		error = DirAccess.make_dir_absolute(filepath)
		if error:
			printerr("Could not create directory: ", filepath, " Error: ", error)
