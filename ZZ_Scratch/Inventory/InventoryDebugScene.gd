extends Node2D

@onready var player: Character = $Devin
@onready var inventory: Control = $UI/Inventory
var _inventory: Inventory


# A lot of duplicated variable names here, just for the sake of wiring and debugging
func setup(driver: Driver) -> void:
	var inv: Inventory = driver._inventory_mgr.register(player)
	_inventory = inv
	# Test/Debug wiring for the time being
	inventory.set_inventory(inv)
	inv.inventory_updated.connect(_inventory_updated)



func _inventory_updated(inv: Inventory) -> void:
	inventory.set_inventory(inv)
	

	
