class_name Inventory
extends Resource

signal inventory_updated(inventory: Inventory)
signal inventory_item_inserted(item: ItemStack)

@export var _items: Array[ItemStack]

## The biggest size this inventory can be
@export var size: int = -1


func insert(item: ItemStack) -> bool:
	## Iterate over our inventory and stack items if available
	for index in _items.size():
		if _items[index].can_stack(item):
			_items[index].stack(item)
			inventory_updated.emit(self)
			inventory_item_inserted.emit(item)
			return true
		if _items[index].can_partially_stack(item) && _items.size() + 1 <= size:
			var stack := _items[index].partially_stack(item)
			_items.append(stack)
			inventory_item_inserted.emit(item)
			inventory_updated.emit(self)
			return true

	## We cannot stack, so let's insert the new ItemStack if there is an available slot
	if _items.size() < size:
		_items.append(item)
		inventory_item_inserted.emit(item)
		inventory_updated.emit(self)
		return true
	return false


func remove(_item: ItemStack) -> void:
	pass
	

func set_size(new_size: int) -> void:
	if _items.size() > new_size:
		printerr("Setting the size of this inventory lower than the amount of items in the inventory is probably not intended")
		size = _items.size()
		return
	size = new_size


func get_items() -> Array[ItemStack]:
	return _items.duplicate(true)


func _to_string() -> String:
	var string_rep: Array[String] = []
	for item in _items:
		string_rep.append(str(item))
	return "[" + ",".join(string_rep) + "]"
