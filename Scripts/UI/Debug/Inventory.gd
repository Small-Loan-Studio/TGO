extends PanelContainer

@export var item_slot: PackedScene

@onready var items: GridContainer = $MarginContainer/Items


func set_inventory(inv: Inventory) -> void:
	build(inv.get_items())


func build(data: Array[ItemStack]) -> void:
	for child in items.get_children():
		child.queue_free()

	for item_stack in data:
		var slot: PanelContainer = item_slot.instantiate()
		items.add_child(slot)
		slot.set_item_slot(item_stack)
