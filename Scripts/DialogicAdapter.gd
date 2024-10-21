class_name DialogicAdapter
extends Node

static var player_inventory := InventoryAdapter.new(Utils.PLAYER_ID)


static func character_inventory(name: String) -> InventoryAdapter:
	return InventoryAdapter.new(name)


class InventoryAdapter:
	var _id: String

	func _init(id: String) -> void:
		_id = id

	func has(item_name: String) -> bool:
		# TODO(envy): file issue that will validate item_name as a real item id
		var inv := Driver.instance().inventory_mgr.get_inventory(_id)
		return inv.has_item_by_id(item_name)
