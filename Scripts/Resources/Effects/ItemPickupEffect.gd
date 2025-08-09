## Adds an item from the world into the actor's inventory. The world item
## will be destroyed.
class_name ItemPickupEffect
extends Effect

## The destination path to the node that represents an item
@export var dest_path: NodePath

## The item that will be added if picked up
@export var item: ItemStack


func act(actor_id: String, level: LevelBase) -> Variant:
	var inv_manager: InventoryManager = Driver.instance().inventory_mgr
	var item_node := parent.get_node(dest_path) as Node2D

	var inventory: Inventory = inv_manager.get_inventory(actor_id)
	if inventory.insert(item):
		item_node.picked_up.emit()
		item_node.queue_free()

	var actor_obj := level.get_by_id(actor_id)
	if actor_obj is Character:
		var actor_char := actor_obj as Character
		var audio_node := actor_char.audio_node()
		if audio_node != null:
			var event_name := "play_IN_%s_pickup" % [item.item.id.to_lower()]
			if AK.EVENTS._dict.has(event_name):
				var cfg := AudioNode.EventConfig.new()
				cfg.event_name = event_name
				audio_node.post_event(cfg)

	return null
