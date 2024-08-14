extends PanelContainer

@onready var icon: TextureRect = $MarginContainer/Icon
@onready var quantity: Label = $Quantity

func set_item_slot(itemStack: ItemStack) -> void:
	icon.texture = itemStack.item.icon
	quantity.text = "x" + str(itemStack.quantity)
