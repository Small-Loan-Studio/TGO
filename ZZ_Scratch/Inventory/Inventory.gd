class_name Inventory
extends Node

## Fired whenever an item has been inserted into the inventory
signal item_inserted(item: Item)
## Fired whenever an item has been removed from the inventory
signal item_removed(item: Item)

## The item in this inventory, you can add items here to start with to create an inventory with specific items, like say a dropbox in the world that contains specific loot
@export var items: Array[Item] = []

## The number of slots this container will have. The behavior of -1 should indicate that the inventory is unlimited and will accept every item inserted into it
@export var slots: int = -1


# INFO: We might want to come back here and design a system that isn't slot-agnostic, a first pass of the system should be fine being slot-agnostic though
func insert(item: Item) -> bool:
	print("INSERTING ITEM")
	
	# Our item is not stackable, so just push into our array
	if item.stack_size == 1:
		items.append(item)
		emit_signal(&"item_inserted", item)
		return true
	else:
		if item in items:
			## NOTE: Come back here if we end up having performance issues with find, shouldn't be an issue unless the size of the inventory is massive
			var oItem: Item = items[items.find(item)]
			if oItem.count + item.count >= item.stack_size:
				var remaining: int = oItem.count + item.count - item.stack_size
				oItem.count = item.stack_size
				item.count = remaining
				items.append(item)
				emit_signal(&"item_inserted", item)
				return true
			else:
				oItem.count += item.count
				emit_signal(&"item_inserted", item)
				return true
	return false

func remove() -> void:
	pass
