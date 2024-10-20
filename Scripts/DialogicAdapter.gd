class_name DialogicAdapter
extends Node

class player_inventory:
	static func has(item_name: String) -> bool:
		# TODO(envy): file issue that will validate item_name as a real item id
		var inv := Driver.instance().inventory_mgr.get_inventory(Utils.PLAYER_ID)
		return inv.has_item_by_id(item_name)