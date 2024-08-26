extends Node2D

var _inventory: Inventory

@onready var player: Character = $Devin
@onready var inventory: Control = $UI/Inventory


# A lot of duplicated variable names here, just for the sake of wiring and debugging
func setup(driver: Driver) -> void:
	var limited_inventory := Inventory.new()
	limited_inventory.size = 2
	var inv: Inventory = driver.inventory_mgr.register("Devin", limited_inventory)
	_inventory = inv
	# Test/Debug wiring for the time being

	inventory.set_inventory(inv)
	inv.inventory_updated.connect(_inventory_updated)


func _inventory_updated(inv: Inventory) -> void:
	inventory.set_inventory(inv)
