@tool

class_name ObjectsHelper
extends Control


var _sections: Dictionary = {}
var _focused_section: String = ""

func _enter_tree() -> void:
	_sections = {
		"generic": [$Container/AddItems/Generic, $Container/AddItems/GenericDetails],
		"pushable": [$Container/AddItems/Pushable, $Container/AddItems/PushableDetails],
		"npc": [$Container/AddItems/NPC, $Container/AddItems/NPCDetails],
	}
	_reset()

func _reset() -> void:
	_focused_section = ""
	for k: String in _sections.keys():
		var main: Control = _sections[k][0]
		var detail: Control = _sections[k][1]
		main.show()
		detail.hide()

func _select_section(name: String) -> void:
	_reset()
	_focused_section = name
	var detail: Control = _sections[name][1]
	detail.show()
	for k in _sections.keys():
		if k != name:
			_sections[k][0].hide()
			_sections[k][1].hide()

func _apply() -> void:
	print("Apply changes from %s" % [_focused_section])
	_reset()