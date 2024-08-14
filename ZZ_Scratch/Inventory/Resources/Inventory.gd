class_name Inventory
extends Resource

signal inventory_updated(inventory: Inventory)

@export var items: Array[ItemStack]

# The biggest size this inventory can be
@export var size: int = -1

func insert(item: ItemStack) -> bool:
	
	## Iterate over our inventory and stack items if available
	for index in items.size():
		if items[index].can_stack(item):
			items[index].stack(item)
			inventory_updated.emit(self)
			return true
			
	## We cannot stack, so let's insert the new ItemStack
	items.append(item)
	inventory_updated.emit(self)
	return true
	
func remove(item: ItemStack) -> void:
	pass

func _to_string() -> String:
	var stringRep: Array[String] = []
	for item in items:
		stringRep.append(str(item))
	return "[" + ",".join(stringRep) + "]"
