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


func remove_by_id(item_id: String, count: int = 1) -> bool:
	if not has_item_by_id(item_id):
		printerr("Item does not exist in inventory")
		return false
	if count_item_by_id(item_id) < count:
		printerr("Attempting to remove more items than present in inventory")
		return false
	while count > 0:  # While there are still items to remove
		var size: int = _items.size() - 1
		for index in range(size, -1, -1):
			if _items[index].item.id == item_id:
				if _items[index].quantity > count:
					## Bigger stack than needed, decrement quantity
					_items[index].quantity = _items[index].quantity - count
					print(str(count) + " " + item_id + " removed from inventory ")
					count = 0
					break

				elif _items[index].quantity <= count:
					## exact amount to remove, delete whole stack
					count = count - _items[index].quantity
					print(str(_items[index].quantity) + " " + item_id + " removed from inventory ")
					_items.remove_at(index)
					break
	inventory_updated.emit(self)
	return true


func remove(item: Item, count: int = 1) -> bool:
	return remove_by_id(item.id, count)


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
