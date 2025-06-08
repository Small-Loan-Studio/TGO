@tool

class_name TGOInspectorControlledRegionId
extends EditorInspectorPlugin


func _can_handle(obj: Object) -> bool:
	return obj is ControlledRegion || obj is ToggleDoorEffect || obj is UpdateControlledRegionEffect


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
	if obj is ControlledRegion && name == "region_id":
		add_property_editor(name, IdProperty.new(self, obj as ControlledRegion, null, null))
		return true
	if obj is ToggleDoorEffect && name == "door_id":
		add_property_editor(name, IdProperty.new(self, null, obj as ToggleDoorEffect, null))
		return true
	if obj is UpdateControlledRegionEffect && name == "region_id":
		var ure := obj as UpdateControlledRegionEffect
		add_property_editor(name, IdProperty.new(self, null, null, ure))
		return true
	return false


class IdProperty:
	extends EditorProperty

	func _init(
		plugin: TGOInspectorControlledRegionId,
		obj: ControlledRegion,
		tde: ToggleDoorEffect,
		ure: UpdateControlledRegionEffect,
	) -> void:
		var control_scene: PackedScene = load(
			"res://addons_tgo/editors/region/TGOInspectorControlledRegionId.tscn"
		)
		var control := control_scene.instantiate()
		control.setup(plugin, obj, tde, ure)
		add_child(control)
		if obj != null:
			set_bottom_editor(control)
		add_focusable(control)
