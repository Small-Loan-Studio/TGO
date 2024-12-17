class_name ItemStack
extends Resource

@export var item: Item
@export var quantity: int


## returns whother or not some other item stack can be fully added to this
## stack
func can_stack(other: ItemStack) -> bool:
	return item.stackable and item == other.item and quantity + other.quantity <= item.stack_size


## returns whether some of another item stack can be added to this stack
func can_partially_stack(other: ItemStack) -> bool:
	return item.stackable and item == other.item and quantity < item.stack_size


## Adds some other item stack to this one
func stack(other: ItemStack) -> void:
	quantity += other.quantity
	quantity = clampi(quantity, 1, item.stack_size)


## Takes as many as this stack can handle from some other stack and returns
## a new stack containing whatever was unable to be held
func partially_stack(other: ItemStack) -> ItemStack:
	var rem_stack := ItemStack.new()
	rem_stack.item = item
	if other.quantity > item.stack_size:
		printerr("Found a stack size in the world that was more than the allowed max_stack size")

	var transfer := item.stack_size - quantity

	quantity = item.stack_size
	rem_stack.quantity = other.quantity - transfer
	return rem_stack


func _to_string() -> String:
	return "ItemStack<" + str(item) + "," + str(quantity) + ">"
