class_name DialogicAdapter
extends Node


static func selected_id_valid() -> bool:
	return player_inventory.valid_id(SelectItemEffect.get_selected_id())


static var player_inventory := InventoryAdapter.new(Utils.PLAYER_ID)

static var time_of_day := TimeOfDayAdapter.new()


static func audio(actor_id: String) -> AudioActorAdapter:
	return AudioActorAdapter.new(actor_id)


static func character_inventory(inv_name: String) -> InventoryAdapter:
	return use_inventory(inv_name)


static func use_inventory(inv_name: String) -> InventoryAdapter:
	return InventoryAdapter.new(inv_name)


static func quest(quest_id: String) -> QuestAdapter:
	return QuestAdapter.new(quest_id)


class InventoryAdapter:
	static var _item_dict: Dictionary = {}
	var _id: String

	func _init(id: String) -> void:
		_id = id

	static func _static_init() -> void:
		var paths := Utils.walk_directory(
			Item.ITEM_PATH, func(s: String) -> bool: return s.ends_with(".tres")
		)

		for p in paths:
			var item := ResourceLoader.load(Item.ITEM_PATH.path_join(p)) as Item
			if item != null:
				_item_dict[item.id] = item

	func valid_id(item_id: String) -> bool:
		print("checking validity of: %s - %s" % [item_id, _item_dict.has(item_id)])
		return _item_dict.has(item_id)

	func has(item_name: String, count: int = -1) -> bool:
		# TODO(envy): file issue that will validate item_name as a real item id
		var inv := Driver.instance().inventory_mgr.get_inventory(_id)
		if count == -1:
			return inv.has_item_by_id(item_name)
		if inv.count_item_by_id(item_name) == count:
			return true
		return false

	func at_least(item_name: String, count: int) -> bool:
		var inv := Driver.instance().inventory_mgr.get_inventory(_id)
		if count < 1:
			printerr("Checking if inventory has a 0 or negative value doesn't make sense")
			return true
		if inv.count_item_by_id(item_name) >= count:
			return true
		return false

	func add(item_id: String, count: int = 1) -> bool:
		return add_item(item_id, count)

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

	func remove(item_id: String, count: int = 1) -> bool:
		return remove_item(item_id, count)

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


class TimeOfDayAdapter:
	var _dnc_cache: DayNightCycle
	var _dnc: DayNightCycle:
		get:
			if _dnc_cache == null:
				_dnc_cache = Driver.instance()._day_night_cycle
			return _dnc_cache

	func is_time_of_day(segment_name: String) -> bool:
		var tod := Enums.time_of_day_from_str(segment_name)
		return tod == _dnc.day_segment()

	func _time_str_to_sec(ts: String) -> int:
		var parts := ts.split(":")
		var hr := parts[0].to_int()
		var min := parts[1].to_int()
		if hr < 0 || hr > 23 || min < 0 || min > 59:
			printerr("Bad time check: %s" % [ts])
			return 0
		return DayNightCycle.DNClock.hms_to_sec(hr, min, 0)

	func is_before(time_str: String) -> bool:
		var sec_check := _time_str_to_sec(time_str)
		var sec_cur := _dnc.get_time_sec()

		return sec_cur < sec_check

	func is_after(time_str: String) -> bool:
		var sec_check := _time_str_to_sec(time_str)
		var sec_cur := _dnc.get_time_sec()

		return sec_cur > sec_check

	func is_between(start: String, end: String) -> bool:
		var sec_start := _time_str_to_sec(start)
		var sec_stop := _time_str_to_sec(end)
		var sec_cur := _dnc.get_time_sec()

		return sec_cur < sec_stop && sec_cur > sec_start

	func set_time(time_str: String) -> void:
		var want_sec := _time_str_to_sec(time_str)
		_dnc.set_time_sec(want_sec)


class AudioActorAdapter:
	var _actor_id: String

	func _init(actor: String) -> void:
		_actor_id = actor

	func rtpc(name: String, value: float) -> bool:
		var audio_node := Driver.instance().get_current_level().get_audio_node(_actor_id)
		if audio_node == null:
			printerr("No audio node with id %s" % [_actor_id])
			return false
		audio_node.send_param(name, value)
		return true

	func get_rtpc(name: String) -> float:
		var audio_node := Driver.instance().get_current_level().get_audio_node(_actor_id)
		if audio_node == null:
			printerr("No audio node with id %s" % [_actor_id])
			return 0.0
		return audio_node.get_param(name)

	func fire(event_name: String) -> int:
		var audio_node := Driver.instance().get_current_level().get_audio_node(_actor_id)
		if audio_node == null:
			printerr("No audio node with id %s" % [_actor_id])
			return -1
		var cfg := AudioNode.EventConfig.new()
		cfg.event_name = event_name
		cfg.one_shot = true  # default to one shot for now
		cfg.event_name = event_name
		return audio_node.post_event(cfg)

	func stop(event_id: int, fade_out: int) -> bool:
		var audio_node := Driver.instance().get_current_level().get_audio_node(_actor_id)
		if audio_node == null:
			printerr("No audio node with id %s" % [_actor_id])
			return false
		audio_node.stop_event_by_id(event_id, fade_out)
		return true
