class_name InputController
extends ControllerBase


const NOT_MOD = 0
const MOD_ALT = 1
const MOD_SHIFT = 2
const MOD_CTRL = 3


var _button_state: Dictionary = {}
var _mods_state: Dictionary = {}


func _ready() -> void:
	_mods_state[MOD_ALT] = KeyState.new("alt")
	_mods_state[MOD_SHIFT] = KeyState.new("shift")
	_mods_state[MOD_CTRL] = KeyState.new("ctrl")

	var evts := {}
	for action in InputMap.get_actions():
		evts[action] = InputMap.action_get_events(action)
	print(JSON.stringify(evts, "  "))


func _unhandled_input(event: InputEvent) -> void:
	process_input(event)


func process_input(event: InputEvent) -> void:
	var mod_key := _event_is_mod(event)
	print(event)
	# print("%s -> %d" % [event.as_text(), mod_key])
	if NOT_MOD != mod_key:
		var key_state := _mods_state[mod_key] as KeyState
		if event.is_pressed():
			key_state.press()
		else:
			key_state.release()


func _event_is_mod(event: InputEvent) -> int:
	if !event is InputEventKey:
		return NOT_MOD
	
	var ievent := event as InputEventKey
	match ievent.keycode:
		KEY_SHIFT:
			return MOD_SHIFT
		KEY_CTRL:
			return MOD_CTRL
		KEY_META:
			return MOD_CTRL
		KEY_ALT:
			return MOD_ALT
	return NOT_MOD



class KeyState:
	extends RefCounted

	var key_name: String
	var down: int = -1
	var up: int = 0

	func _init(name: String) -> void:
		key_name = name

	func pressed() -> bool:
		return down > up
	
	func press() -> void:
		down = Time.get_ticks_msec()
	
	func release() -> void:
		up = Time.get_ticks_msec()
	
	func _to_string() -> String:
		var state := "pressed"
		if !pressed():
			state = "not " + state
		return "%s: %s" % [key_name, state]