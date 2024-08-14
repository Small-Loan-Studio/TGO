class_name ItemStack
extends Resource

@export var item: Item
@export var quantity: int

func can_stack(oItemStack: ItemStack) -> bool:
	return item.stackable \
			and item == oItemStack.item \
			and quantity + oItemStack.quantity <= item.stack_size

func stack(oItemStack: ItemStack) -> void:
	quantity += oItemStack.quantity

func _to_string() -> String:
	return "ItemStack<" + str(item) + "," + str(quantity) + ">"
