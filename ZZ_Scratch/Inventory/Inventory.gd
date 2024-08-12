class_name Inventory
extends Node

## Fired whenever an item has been inserted into the inventory
signal item_inserted(item: Item)
## Fired whenever an item has been removed from the inventory
signal item_removed(item: Item)

## The item in this inventory, you can add items here to start with to create an inventory with specific items, like say a dropbox in the world that contains specific loot
@export var items: Array[Item] = []

## The counts of each slot in our inventory, index[0] represents items[0] count
@export var counts: Array[int] = []

## The number of slots this container will have. The behavior of -1 should indicate that the inventory is unlimited and will accept every item inserted into it
@export var slots: int = -1


# INFO: We might want to come back here and design a system that isn't slot-agnostic, a first pass of the system should be fine being slot-agnostic though
func insert(item: Item) -> bool:
	# Our item is not stackable, so just push into our array
	print(item.count)
	if item.stack_size == 1:
		items.append(item)
		counts.append(1)
		emit_signal(&"item_inserted", item)
		return true
	else:
		if item in items:
			## NOTE: Come back here if we end up having performance issues with find, shouldn't be an issue unless the size of the inventory is massive
			var index: int = search(item)
			var oItem: Item = items[index]
			var count: int = counts[index]
			
			# If index is -1, we found a slot, otherwise add a new item
			if index != -1:
				if count + item.count > item.stack_size:
					var remaining: int = count + item.count - item.stack_size
					counts[index] = item.stack_size
					counts.insert(index + 1, remaining)
					items.append(item)
					emit_signal(&"item_inserted", item)
					return true
				else:
					counts[index] += item.count
					emit_signal(&"item_inserted", item)
					return true
			else:
				items.append(item)
				counts.append(item.count)
				emit_signal(&"item_inserted", item)
				return true
		else:
			items.append(item)
			counts.append(item.count)
			emit_signal(&"item_inserted", item)
			return true
	return false

func remove() -> void:
	pass
	
## Search for a slot that our item can fit in without breaking stack_size restraints
func search(item: Item) -> int:
	for i in range(items.size()):
		if items[i] == item && counts[i] != item.stack_size:
			return i
	return -1


func _process(_delta: float) -> void:
	#print(counts)
	pass
