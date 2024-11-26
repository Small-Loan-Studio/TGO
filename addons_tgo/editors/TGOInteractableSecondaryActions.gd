@tool
class_name TGOInteractableSecondaryActions
extends Control

var _plugin_ref: TGOInspectorInteractable
var _data: Interactable

@onready var _margin_container := $MarginContainer
@onready var _action_select: OptionButton = %ActionSelect


func _ready() -> void:
	custom_minimum_size.y = _margin_container.size.y
	_sync()


func setup(plugin: TGOInspectorInteractable, obj: Interactable) -> void:
	_plugin_ref = plugin
	_data = obj


func _sync() -> void:
	_action_select.clear()
	var secondary_keys := _data.action_map.keys()
	for a: Enums.ActionVerb in Enums.ActionVerb.values():
		if !(a == _data.default_verb || a in secondary_keys):
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
