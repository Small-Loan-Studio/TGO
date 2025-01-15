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


func has_room(item: ItemStack) -> bool:
	var new_stacks: int = 1
	for slot in _items:
		if slot.can_stack(item):
			new_stacks = 0
			break

		if slot.can_partially_stack(item):
			new_stacks = 1
			break
	return _can_grow(new_stacks)


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


func save() -> Dictionary:
	var inv := {}
	var slots: Array[String] = []
	for slot in _items:
		slots.append("%d:%s" % [slot.quantity, slot.item.resource_path])

	inv["size"] = size
	inv["contains"] = slots

	return inv


func load(data: Dictionary) -> void:
	_items.clear()

	size = data["size"]

	for ele: String in data["contains"]:
		var parts := ele.split(":", true, 1)
		var qty := int(parts[0])
		var item_path := parts[1]

		var item := ResourceLoader.load(item_path) as Item
		if item == null:
			print("Failed to load item ", item_path)
			continue
		var stack := ItemStack.new()
		stack.item = item
		stack.quantity = qty
		_items.append(stack)
