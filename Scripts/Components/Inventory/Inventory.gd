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


func insert(new_item: ItemStack) -> bool:
	var inserted := false

	for slot in _items:
		if slot.can_stack(new_item):
			slot.stack(new_item)
			inserted = true
			break

		if slot.can_partially_stack(new_item) && _can_grow():
			var remaining := slot.partially_stack(new_item)
			_items.append(remaining)
			inserted = true
			break

	if !inserted && _can_grow():
		_items.append(new_item)
		inserted = true

	if inserted:
		inventory_updated.emit(self)
		inventory_item_inserted.emit(new_item)

	return inserted


func _can_grow(delta: int = 1) -> bool:
	return size == -1 || (_items.size() + delta) <= size


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
