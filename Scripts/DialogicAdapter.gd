class_name DialogicAdapter
extends Node

static var player_inventory := InventoryAdapter.new(Utils.PLAYER_ID)


static func character_inventory(name: String) -> InventoryAdapter:
	return InventoryAdapter.new(name)


static func quest(quest_id: String) -> QuestAdapter:
	return QuestAdapter.new(quest_id)


class InventoryAdapter:
	
	var _id: String
	static var _item_dict: Dictionary = {}


	static func _static_init() -> void:
		var paths  := Utils.walk_directory(Item.ITEM_PATH, func(s: String) -> bool: return s.ends_with(".tres"))

		for p in paths:
			var item := ResourceLoader.load(Item.ITEM_PATH.path_join(p)) as Item
			if item != null:
				_item_dict[item.id] = item
				pass


	func _init(id: String) -> void:
		_id = id


	func has(item_name: String, count: int = -1) -> bool:
		# TODO(envy): file issue that will validate item_name as a real item id
		var inv := Driver.instance().inventory_mgr.get_inventory(_id)
		if count == -1:
			return inv.has_item_by_id(item_name)
		if inv.count_item_by_id(item_name) == count:
			return true
		return false

	func add_item(item_id: String, count: int = 1) -> bool:
		var inv := Driver.instance().inventory_mgr.get_inventory(_id)
		var item: Item

		if _item_dict.has(item_id):
			item = _item_dict[item_id]
		else:
			printerr("Invalid item id")
			return false

		if count > item.stack_size:
			printerr("Trying to add more than allowable stack size")
			return false
		if count == 0:
			printerr("Trying to add zero items to inventory")
			return false

		var item_stack := ItemStack.new()
		item_stack.item = item
		item_stack.quantity = count
		return inv.insert(item_stack)

	func remove_item(item_id: String, count: int = 1) -> bool:
		var inv := Driver.instance().inventory_mgr.get_inventory(_id)
		return inv.remove_by_id(item_id, count)

	func has_room(item_id: String, count: int) -> bool:
		var inv := Driver.instance().inventory_mgr.get_inventory(_id)
		var item: Item

		if _item_dict.has(item_id):
			item = _item_dict[item_id]
		else:
			printerr("Invalid item id")
			return false

		if count > item.stack_size:
			printerr("Trying to add more than allowable stack size")
			return false
		if count == 0:
			printerr("Trying to add zero items to inventory")
			return false

		var item_stack := ItemStack.new()
		item_stack.item = item
		item_stack.quantity = count
		return inv.has_room(item_stack)


class QuestAdapter:
	var _id: String

	func _init(id: String) -> void:
		_id = id

	func is_finished() -> bool:
		var qst := Driver.instance().quest_mgr.quest_by_id(_id)
		return qst.is_finished()

	func is_completed() -> bool:
		var qst := Driver.instance().quest_mgr.quest_by_id(_id)
		return qst.state == Enums.QuestState.COMPLETED

	func is_failed() -> bool:
		var qst := Driver.instance().quest_mgr.quest_by_id(_id)
		return qst.state == Enums.QuestState.FAILED

	func start() -> bool:
		var qst := Driver.instance().quest_mgr.quest_by_id(_id)
		return qst.mark_active()

	func complete() -> bool:
		var qst := Driver.instance().quest_mgr.quest_by_id(_id)
		return qst.mark_completed()

	func fail() -> bool:
		var qst := Driver.instance().quest_mgr.quest_by_id(_id)
		return qst.mark_failed()
