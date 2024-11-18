@tool
class_name TGO_InspectorInteractable
extends EditorInspectorPlugin


func _can_handle(obj: Object) -> bool:
	return obj is Interactable


func _parse_begin(_obj: Object) -> void:
	# print("_parse_begin: ", obj)
	pass


func _parse_end(_obj: Object) -> void:
	# print("_parse_end: ", obj)
	pass


func _parse_category(_obj: Object, _category: String) -> void:
	# print("_parse_category(%s): " % [category], obj)
	pass


func _parse_group(_obj: Object, _group: String) -> void:
	# print("_parse_group(%s): " % [group], obj)
	pass


func _parse_property(
	obj: Object,
	type: Variant.Type,
	name: String,
	hint_type: PropertyHint,
	hint_str: String,
	usage_flags: int,
	wide: bool
) -> bool:
	if name == "action_map":
		# print("_parse_property(%s, %s, %s, 0b%s, %s)" % [type, name, hint_str, String.num_int64(usage_flags, 2), wide])
		add_property_editor(name, Property.new(self, obj as Interactable))
		return true
	return false


class Property:
	extends EditorProperty

	func _init(plugin: TGO_InspectorInteractable, obj: Interactable) -> void:
		var control_scene: PackedScene = load(
			"res://addons_tgo/editors/TGOInteractableSecondaryActions.tscn"
		)
		var control := control_scene.instantiate() as TGOInteractableSecondaryActions
		control.setup(plugin, obj)
		add_child(control)
		set_bottom_editor(control)
		add_focusable(control)
