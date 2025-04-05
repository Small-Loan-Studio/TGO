class_name AKHelper
extends RefCounted

var _target: Node

func _init(owner: Node) -> void:
	_target = owner

func bus_names() -> Array[String]:
	var ret: Array[String] = []
	for k: String in AK.BUSSES._dict.keys():
		ret.append(k)
	return ret

func bus_ids() -> Array[int]:
	var ret: Array[int] = []
	for k: int in AK.BUSSES._dict.values():
		ret.append(k)
	return ret

func get_bus_id(name: String) -> int:
	return AK.BUSSES._dict[name]

func bus_param(bus_id: int) -> int:
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

func name_by_id(dict: Dictionary, id: int) -> String:
	for key: String in dict:
		if dict[key] == id:
			return key
	return "--unknown--"

func get_param(param: int) -> float:
	return Wwise.get_rtpc_value_id(param, _target)

func send_param(param: int, value: float) -> void:
	print("[Wwise] %s rtpc -> %s=%s" % [
		_target.name, self.name_by_id(AK.GAME_PARAMETERS._dict, param), value])
	Wwise.set_rtpc_value_id(param, value, _target)

func send_event(event_id: int) -> void:
	print("[Wwise] %s event -> %s" % [
		_target.name, self.name_by_id(AK.EVENTS._dict, event_id)])
	Wwise.post_event_id(event_id, _target)
