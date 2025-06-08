@tool

class_name TGOInspectorControlledRegionId
extends EditorInspectorPlugin


func _can_handle(obj: Object) -> bool:
	return obj is ControlledRegion


func _parse_begin(_obj: Object) -> void:
	pass


func _parse_end(_obj: Object) -> void:
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
	if name == "region_id":
		add_property_editor(name, IdProperty.new(self, obj as ControlledRegion))
		return true
	return false


class IdProperty:
	extends EditorProperty

	func _init(plugin: TGOInspectorControlledRegionId, obj: ControlledRegion) -> void:
		var control_scene: PackedScene = load("res://addons_tgo/editors/region/TGOInspectorControlledRegionId.tscn")
		var control := control_scene.instantiate()
		control.setup(plugin, obj)
		add_child(control)
		set_bottom_editor(control)
		add_focusable(control)
