@tool
class_name TGOInspectorInteractable
extends EditorInspectorPlugin


func _can_handle(obj: Object) -> bool:
	return obj is Interactable || obj is InteractMenuSignals


func _parse_begin(_obj: Object) -> void:
	pass


func _parse_end(_obj: Object) -> void:
	pass


func _parse_category(_obj: Object, _category: String) -> void:
	pass


func _parse_group(_obj: Object, _group: String) -> void:
	pass


func _parse_property(
	obj: Object,
	_type: Variant.Type,
	name: String,
	_hint_type: PropertyHint,
	_hint_str: String,
	_usage_flags: int,
	_wide: bool
) -> bool:
	if name == "action_map":
		var adapter: TGOInteractableSecondaryActions.Adapter
		if obj is Interactable:
			adapter = TGOInteractableSecondaryActions.InteractableAdapter.new(obj)
		if obj is InteractMenuSignals:
			adapter = TGOInteractableSecondaryActions.MenuSignalsAdapter.new(obj)
		add_property_editor(name, Property.new(self, adapter))
		return true
	return false


class Property:
	extends EditorProperty

	func _init(plugin: TGOInspectorInteractable, obj: TGOInteractableSecondaryActions.Adapter) -> void:
		var control_scene: PackedScene = load(
			"res://addons_tgo/editors/TGOInteractableSecondaryActions.tscn"
		)
		var control := control_scene.instantiate() as TGOInteractableSecondaryActions
		control.setup(plugin, obj)
		add_child(control)
		set_bottom_editor(control)
		add_focusable(control)
