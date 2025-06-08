@tool
class_name TGORegionEditor
extends EditorPlugin

const PLUGIN_NAME = "tgo_regions"

var _control_scene: Variant = null

func _enter_tree() -> void:
	if !Engine.is_editor_hint():
		return
	_load_scene()


func _exit_tree() -> void:
	_unload_scene()


func _has_main_screen() -> bool:
	return true


func _get_plugin_name() -> String:
	return "TGO:Regions"


func _get_plugin_icon():
	return EditorInterface.get_editor_theme().get_icon("Node", "EditorIcons")


func _load_scene() -> void:
	if !Engine.is_editor_hint():
		return
	return


func _unload_scene() -> void:
	if _control_scene != null:
		remove_control_from_docs(_control_scene)