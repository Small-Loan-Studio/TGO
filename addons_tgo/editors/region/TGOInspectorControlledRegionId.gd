@tool
extends MarginContainer

const ADD_NEW = "Define New Region"

var _create_button: Button:
	get:
		return $Vbox/IdVbox/Hbox/Create

var _new_id_edit: LineEdit:
	get:
		return $Vbox/IdVbox/Hbox/NewId

var _existing_options: OptionButton:
	get:
		return $Vbox/IdVbox/Existing

var _new_id_hbox: HBoxContainer:
	get:
		return $Vbox/IdVbox/Hbox

var _config_section: Control:
	get:
		return $Vbox/Config

var _region_passable: CheckBox:
	get:
		return $Vbox/Config/Passable

var _region_visible: CheckBox:
	get:
		return $Vbox/Config/Visible

var _obj: ControlledRegion
var _tde: ToggleDoorEffect
var _ure: UpdateControlledRegionEffect
var _known_paths: Dictionary = {}


func setup(
	_plugin: TGOInspectorControlledRegionId,
	obj: ControlledRegion,
	tde: ToggleDoorEffect,
	ure: UpdateControlledRegionEffect,
) -> void:
	_obj = obj
	_tde = tde
	_ure = ure
	if _in_resource():
		add_theme_constant_override("margin_left", 0)
	_sync_dropdown_contents()
	_sync_selected()


func _get_region_id() -> String:
	if _obj != null:
		return _obj.region_id
	if _tde != null:
		return _tde.door_id
	if _ure != null:
		return _ure.region_id
	return ""


func _update_region_id(new_id: String) -> void:
	if _obj != null:
		_obj.region_id = new_id
	elif _tde != null:
		_tde.door_id = new_id
	elif _ure != null:
		_ure.region_id = new_id
	else:
		printerr("No object to update region ID for.")


func _in_resource() -> bool:
	return _obj == null


func _sync_dropdown_contents() -> void:
	var all_paths := RegionStateManager.get_settings_paths()
	_existing_options.clear()
	_known_paths.clear()

	var id_idx := -1
	for path in all_paths:
		_existing_options.add_item(path)
		_known_paths[path] = true
		if path == _get_region_id():
			id_idx = (_existing_options.item_count - 1)
	if !_in_resource():
		_existing_options.add_item(ADD_NEW)

	_existing_options.selected = id_idx


func _on_select(_idx: int) -> void:
	if !is_adding_new():
		_update_region_id(selected_id())
	_sync_selected()


func selected_id() -> String:
	if _existing_options.selected == -1:
		return ""
	return _existing_options.get_item_text(_existing_options.selected)


func is_adding_new() -> bool:
	return selected_id() == ADD_NEW


func none_selected() -> bool:
	return _existing_options.selected == -1


func _sync_selected() -> void:
	_new_id_hbox.visible = is_adding_new()
	_config_section.visible = !_in_resource() && !is_adding_new() && !none_selected()

	if _config_section.visible:
		var path := _get_region_id()
		var cur_values: Dictionary = ProjectSettings.get_setting("tgo/region_states", {})[path]
		_region_passable.button_pressed = cur_values["passable"] as bool
		_region_visible.button_pressed = cur_values["visible"] as bool


func _on_create_region() -> void:
	var new_id := _new_id_edit.text.strip_edges()
	var rs := RegionState.new()
	RegionStateManager.update_setting(new_id, rs)
	_update_region_id(new_id)
	call_deferred("_sync_dropdown_contents")
	call_deferred("_sync_selected")


func _on_new_region_id_changed(new_id: String) -> void:
	_create_button.disabled = true
	if new_id.is_empty():
		return
	if _known_paths.has(new_id):
		printerr("Region ID already exists: " + new_id)
		return
	_create_button.disabled = false


func _update_existing() -> void:
	var path := selected_id()
	var cur: Dictionary = ProjectSettings.get_setting("tgo/region_states", {})[path]
	var rs: RegionState = RegionState.from_dict(cur)
	rs.visible = _region_visible.button_pressed
	rs.passable = _region_passable.button_pressed
	RegionStateManager.update_setting(path, rs)
