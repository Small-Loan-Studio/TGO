extends PanelContainer

var itemSlot: PackedScene = preload("res://ZZ_Scratch/Inventory/UI/ItemSlot.tscn")

@onready var items: GridContainer = $MarginContainer/Items

func set_inventory(inv: Inventory) -> void:
	build(inv.items)

func build(data: Array[ItemStack]) -> void:
	for child in items.get_children():
		child.queue_free()
	
	for itemStack in data:
		var slot: PanelContainer = itemSlot.instantiate()
		items.add_child(slot)
		slot.set_item_slot(itemStack)
