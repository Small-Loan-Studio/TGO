@tool
class_name TGOInteractableSecondaryActions
extends Control

var _plugin_ref: TGOInspectorInteractable
var _data: Adapter

@onready var _margin_container := $MarginContainer
@onready var _action_select: OptionButton = %ActionSelect


func _ready() -> void:
	custom_minimum_size.y = _margin_container.size.y
	_sync()


func setup(plugin: TGOInspectorInteractable, obj: Variant) -> void:
	_plugin_ref = plugin
	_data = obj


func _sync() -> void:
	_action_select.clear()
	if _data == null:
		return
	# var secondary_keys := _data.action_map.keys()
	var secondary_keys: Array[Enums.ActionVerb] = _data.get_keys()
	var default_verb := _data.default_verb()

	# if !_data.action_map.has(_data.default_verb):
	if ! default_verb in secondary_keys:
		_action_select.add_item(Enums.action_verb_name(default_verb))
	for a: Enums.ActionVerb in Enums.ActionVerb.values():
		if !(a == default_verb || a in secondary_keys):
			_action_select.add_item(Enums.action_verb_name(a))


func _on_add_entry_pressed() -> void:
	var idx := _action_select.get_selected_id()
	var text := _action_select.get_item_text(idx)
	var verb := Enums.action_verb_from_str(text)

	# start with a length-1 entry because we default to removing the key in the
	# case where the secondary action list is empty
	_data.action_map[verb] = [null]

	# refresh the list of things that we can add
	_sync()

	# inform the UI it should refresh the inspector view
	_data.property_list_changed.emit()


class Adapter:
	extends RefCounted


	func get_keys() -> Array[Enums.ActionVerb]:
		return []


	func default_verb() -> Enums.ActionVerb:
		return Enums.ActionVerb.DEFAULT


class InteractableAdapter:
	extends Adapter

	var _obj: Interactable

	func _init(obj: Interactable) -> void:
		_obj = obj


	func get_keys() -> Array[Enums.ActionVerb]:
		var arr: Array[Enums.ActionVerb] = []
		arr.assign(_obj.action_map.keys())
		return arr


	func default_verb() -> Enums.ActionVerb:
		return _obj.default_verb

class MenuSignalsAdapter:
	extends Adapter

	var _obj: InteractMenuSignals

	func _init(obj: InteractMenuSignals) -> void:
		_obj = obj