@tool
extends MarginContainer

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
const ADD_NEW = "Define New Region"
var _known_paths: Dictionary = {}

func setup(_plugin: TGOInspectorControlledRegionId, obj: ControlledRegion) -> void:
	_obj = obj
	_sync_dropdown_contents()
	_sync_selected()


func _sync_dropdown_contents() -> void:
	var all_paths := RegionStateManager.get_settings_paths()
	_existing_options.clear()
	_known_paths.clear()
	_existing_options.selected = -1
	for path in all_paths:
		_existing_options.add_item(path)
		_known_paths[path] = true
		if path == _obj.region_id:
			_existing_options.selected = _existing_options.item_count - 1
	_existing_options.add_item(ADD_NEW)


func _on_select(_idx: int) -> void:
	if !is_adding_new():
		_obj.region_id = selected_id()
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
	_config_section.visible = !is_adding_new()

	if !is_adding_new() && !none_selected():
		var path := _obj.region_id
		var cur_values: Dictionary = ProjectSettings.get_setting("tgo/region_states", {})[path]
		_region_passable.button_pressed = cur_values["passable"] as bool
		_region_visible.button_pressed = cur_values["visible"] as bool
		_obj.region_id = selected_id()

func _on_create_region() -> void:
	var new_id := _new_id_edit.text.strip_edges()
	var rs := RegionState.new()
	RegionStateManager.update_setting(new_id, rs)
	_obj.region_id = new_id
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