class_name DialogicAdapter
extends Node

class player_inventory:
	static func has(item_name: String) -> bool:
		var inv := Driver.instance().inventory_mgr.get_inventory("devin")
		return inv.has_item_by_id(item_name)