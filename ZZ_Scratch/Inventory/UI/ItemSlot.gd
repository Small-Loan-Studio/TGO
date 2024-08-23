extends PanelContainer

@onready var icon: TextureRect = $MarginContainer/Icon
@onready var quantity: Label = $Quantity

func set_item_slot(item_stack: ItemStack) -> void:
	icon.texture = item_stack.item.icon
	quantity.text = "x" + str(item_stack.quantity)
