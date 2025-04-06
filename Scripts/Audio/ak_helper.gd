class_name AKHelper
extends RefCounted

const _OLD_NEW_MAPPING := {
		Enums.AudioBus.MASTER: "Main",
		Enums.AudioBus.BACKGROUND_MUSIC: "Background Music",
		Enums.AudioBus.SOUND_EFFECTS: "Sound Effects",
		Enums.AudioBus.MENU_EFFECTS: "Menu",
		Enums.AudioBus.AMBIENT: "Ambient Sounds",
	}

var _target: Node

func _init(owner: Node) -> void:
	_target = owner


static func bus_names() -> Array[String]:
	var ret: Array[String] = []
	for k: String in AK.BUSSES._dict.keys():
		ret.append(k)
	return ret


static func bus_ids() -> Array[int]:
	var ret: Array[int] = []
	for k: int in AK.BUSSES._dict.values():
		ret.append(k)
	return ret


static func get_bus_id(name: String) -> int:
	return AK.BUSSES._dict[name]


static func bus_param(bus_id: int) -> int:
	match bus_id:
		AK.BUSSES.MENU:
			return AK.GAME_PARAMETERS.LEVELS_MENU
		AK.BUSSES.AMBIENT_SOUNDS:
			return AK.GAME_PARAMETERS.LEVELS_AMBIENT
		AK.BUSSES.BACKGROUND_MUSIC:
			return AK.GAME_PARAMETERS.LEVELS_BACKGROUND
		AK.BUSSES.MAIN:
			return AK.GAME_PARAMETERS.LEVELS_MAIN
		AK.BUSSES.SOUND_EFFECTS:
			return AK.GAME_PARAMETERS.LEVELS_EFFECTS
		_:
			assert('unknown bus id %d' % [bus_id])
			return -9999


static func name_by_id(dict: Dictionary, id: int) -> String:
	for key: String in dict:
		if dict[key] == id:
			return key
	return "--unknown--"


func get_param(param: int, local: bool = true) -> float:
	var locality_str := ""
	if !local:
		locality_str = "(global) "
	print("[Wwise] %s%s <- rtpc %s" % [
		locality_str, _target.name, self.name_by_id(AK.GAME_PARAMETERS._dict, param)])

	# we have to branch like this because a null variable seems to marshal
	# differently when getting pushed into the plugin/GDExtension. Causes a
	# segfault if we don't use a bare null. :shrug:
	if local:
		return Wwise.get_rtpc_value_id(param, self._target)
	return Wwise.get_rtpc_value_id(param, null)


func send_param(param: int, value: float, local: bool = true) -> void:
	var locality_str := ""
	if !local:
		locality_str = "(global) "
	print("[Wwise] %s%s rtpc -> %s=%s" % [
		locality_str,_target.name, self.name_by_id(AK.GAME_PARAMETERS._dict, param), value])

	# we have to branch like this because a null variable seems to marshal
	# differently when getting pushed into the plugin/GDExtension. Causes a
	# segfault if we don't use a bare null. :shrug:
	if local:
		Wwise.set_rtpc_value_id(param, value, self._target)
	else:
		Wwise.set_rtpc_value_id(param, value, null)



func send_event(event_id: int, local: bool = true) -> void:
	var tgt := _target
	var locality_str := ""
	if !local:
		tgt = null
		locality_str = "(global) "

	print("[Wwise] %s%s event -> %s" % [
		locality_str,_target.name, self.name_by_id(AK.EVENTS._dict, event_id)])
	Wwise.post_event_id(event_id, tgt)


static func bus_id_from_enum(bus: Enums.AudioBus) -> int:
	var name: String = _OLD_NEW_MAPPING[bus]
	return get_bus_id(name)

static func bus_param_from_enum(bus: Enums.AudioBus) -> int:
	var id := bus_id_from_enum(bus)
	return bus_param(id)

static func bus_from_id(wwise_id: int) -> Enums.AudioBus:
	var bus_name: String = name_by_id(AK.BUSSES._dict, wwise_id)
	return bus_from_name(bus_name)

static func bus_from_name(wwise_name: String) -> Enums.AudioBus:
	var wwise_id: int = AK.BUSSES._dict[wwise_name]
	for key: Enums.AudioBus in _OLD_NEW_MAPPING.keys():
		var bus_id := get_bus_id(_OLD_NEW_MAPPING[key] as String)
		if wwise_id == bus_id:
			return key

	assert("Failed to find audio bus by name " + wwise_name)
	return Enums.AudioBus.MASTER