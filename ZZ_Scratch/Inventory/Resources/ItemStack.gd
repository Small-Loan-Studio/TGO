class_name ItemStack
extends Resource

@export var item: Item
@export var quantity: int

func can_stack(oItemStack: ItemStack) -> bool:
	return item.stackable \
			and item == oItemStack.item \
			and quantity + oItemStack.quantity <= item.stack_size

func can_partially_stack(oItemStack: ItemStack) -> bool:
	return item.stackable \
			and item == oItemStack.item \
			and quantity < item.stack_size

func stack(oItemStack: ItemStack) -> void:
	quantity += oItemStack.quantity

func partially_stack(oItemStack: ItemStack) -> ItemStack:
	var stack := ItemStack.new()
	stack.item = item
	stack.quantity = (quantity + oItemStack.quantity) % item.stack_size
	quantity = item.stack_size
	return stack
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
