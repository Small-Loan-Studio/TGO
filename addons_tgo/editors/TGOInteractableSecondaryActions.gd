@tool
class_name TGOInteractableSecondaryActions
extends Control

signal add_action(v: Enums.ActionVerb)

@onready var _margin_container := $MarginContainer
@onready var _action_select: OptionButton = %ActionSelect
@onready var _add_entry_btn := %AddEntry

var _plugin_ref: TGO_InspectorInteractable
var _data: Interactable


func _ready() -> void:
	custom_minimum_size.y = _margin_container.size.y
	_sync()


func setup(plugin: TGO_InspectorInteractable, obj: Interactable) -> void:
	_plugin_ref = plugin
	_data = obj


func _sync() -> void:
	_action_select.clear()
	var secondary_keys := _data.secondary_actions.keys()
	for a: Enums.ActionVerb in Enums.ActionVerb.values():
		if !(a == _data.action_verb || a in secondary_keys):
			_action_select.add_item(Enums.action_verb_name(a))


func _on_add_entry_pressed() -> void:
	var idx := _action_select.get_selected_id()
	var text := _action_select.get_item_text(idx)
	var verb := Enums.action_verb_from_str(text)

	_data.secondary_actions[verb] = null
	# refresh the list of things that we can add
	_sync()

	add_action.emit(verb)
	_data.property_list_changed.emit()


func _on_debug_pressed() -> void:
	var arr: Array[Dictionary] = _data.get_property_list()
	var j := JSON.new()
	print(j.stringify(arr, "  ", true, false))
