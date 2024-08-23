class_name Inventory
extends Resource

signal inventory_updated(inventory: Inventory)
signal inventory_item_inserted(item: ItemStack)

@export var items: Array[ItemStack]

# The biggest size this inventory can be
@export var size: int = -1

func insert(item: ItemStack) -> bool:
	## Iterate over our inventory and stack items if available
	for index in items.size():
		if items[index].can_stack(item):
			items[index].stack(item)
			inventory_updated.emit(self)
			inventory_item_inserted.emit(item)
			return true
		if items[index].can_partially_stack(item) && items.size() + 1 <= size:
			var stack := items[index].partially_stack(item)
			items.append(stack)
			inventory_item_inserted.emit(item)
			inventory_updated.emit(self)
			return true

	## We cannot stack, so let's insert the new ItemStack if there is an available slot
	if items.size() < size:
		items.append(item)
		inventory_item_inserted.emit(item)
		inventory_updated.emit(self)
		return true
	return false

func remove(item: ItemStack) -> void:
	pass

func _to_string() -> String:
	var stringRep: Array[String] = []
	for item in items:
		stringRep.append(str(item))
	return "[" + ",".join(stringRep) + "]"
