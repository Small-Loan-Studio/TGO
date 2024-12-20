class_name InventoryManager
extends Node

signal inventory_updated(id: String)

# Dictionary[String, Inventory]
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


func load(data: Dictionary) -> void:
	# TODO - how to disconnect Callable?
	# TODO - maybe just reuse existing inventory objs and clear them individually
	_inventories.clear()
	for inv_id: String in data:
		var inv := get_inventory(inv_id)
		inv.load(data[inv_id] as Dictionary)
		inventory_updated.emit(inv_id)


func save() -> Dictionary:
	var mgr_state := {}

	for inv_id: String in _inventories:
		var inv: Inventory = _inventories[inv_id]
		mgr_state[inv_id] = inv.save()

	return mgr_state


func _check_file_location(filepath: String) -> void:
	var error: int
	if !DirAccess.dir_exists_absolute(filepath):
		error = DirAccess.make_dir_absolute(filepath)
		if error:
			printerr("Could not create directory: ", filepath, " Error: ", error)
