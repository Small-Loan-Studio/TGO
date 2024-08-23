class_name ItemStack
extends Resource

@export var item: Item
@export var quantity: int


func can_stack(other: ItemStack) -> bool:
	return item.stackable and item == other.item and quantity + other.quantity <= item.stack_size


func can_partially_stack(other: ItemStack) -> bool:
	return item.stackable and item == other.item and quantity < item.stack_size


func stack(other: ItemStack) -> void:
	quantity += other.quantity


func partially_stack(other: ItemStack) -> ItemStack:
	var stack := ItemStack.new()
	stack.item = item
	stack.quantity = (quantity + other.quantity) % item.stack_size
	quantity = item.stack_size
	return stack

	## NOTE: Revisit this if we deem necessary. This code was used for
	## determining how many stacks we needed to create if the ItemStack was more than stack_size
	## In situations where that is a multiple ((1 + i) * stack_size), we need to
	## create i stacks and insert them sequentially into the inventory

	#var stack_count := (quantity + oItemStack.quantity) / item.stack_size - 1
	#if stack_count < 2:
	#var stack := ItemStack.new()
	#stack.item = item
	#stack.quantity = (quantity + oItemStack.quantity) % item.stack_size
	#quantity = item.stack_size
	#return [stack]
	#else:
	#var stacks: Array[ItemStack] = []
	#for i in range(stack_count):
	#var stack := ItemStack.new()
	#stack.item = item
	#if (quantity + oItemStack.quantity) % item.stack_size == 0:
	#stack.quantity = item.stack_size
	#else:
	#stack.quantity = (quantity + oItemStack.quantity) % item.stack_size
	#stacks.append(stack)
	#return stacks


func _to_string() -> String:
	return "ItemStack<" + str(item) + "," + str(quantity) + ">"
