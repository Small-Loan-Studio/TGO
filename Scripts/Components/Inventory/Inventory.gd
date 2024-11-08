class_name Inventory
extends Resource

signal inventory_updated(inventory: Inventory)
signal inventory_item_inserted(item: ItemStack)

@export var _items: Array[ItemStack]

## The biggest size this inventory can be
@export var size: int = -1


func has_item_by_id(item_id: String) -> bool:
	for stack in _items:
		if stack.item.id == item_id:
			return true
	return false


func has_item(item: Item) -> bool:
	return has_item_by_id(item.id)


func count_item_by_id(item_id: String) -> int:
	var count := 0
	for stack in _items:
		if stack.item.id == item_id:
			count += stack.quantity
	return count


func count_item(item: Item) -> int:
	return count_item_by_id(item.id)


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
	if size == -1 || (_items.size() < size):
		_items.append(item)
		inventory_item_inserted.emit(item)
		inventory_updated.emit(self)
		return true
	return false


func remove(_item: ItemStack) -> void:
	pass


func set_size(new_size: int) -> void:
	if _items.size() > new_size:
		printerr(
			"The size of this inventory cannot be lower than the amount of items in the inventory"
		)
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
