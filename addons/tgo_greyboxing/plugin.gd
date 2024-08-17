@tool
class_name TGOGreyboxingToolsPlugin
extends EditorPlugin

const PLUGIN_NAME = "tgo_greyboxing"

var _control_scene: TGOControlDock = null
var _editor: EditorInterface = null

func _enter_tree() -> void:
	_editor = get_editor_interface()
	_load_scene()


func _load_scene() -> void:
	var control_scene_res := preload("res://Scripts/Addons/tgo_greyboxing/UI/TGOControlDock.tscn")
	_control_scene = control_scene_res.instantiate() as TGOControlDock
	add_control_to_dock(DOCK_SLOT_RIGHT_BL, _control_scene)
	_control_scene.setup(self)


func _unload_scene() -> void:
	remove_control_from_docks(_control_scene)
	_control_scene.hide()
	_control_scene.queue_free()


func reload() -> void:
	print('TGOGreyboxingToolsPlugin.reload')
	# https://www.reddit.com/r/godot/comments/hvqxco/comment/l3oj782/
	# https://gist.github.com/stravant/7aec484bb5e34e3a6196faaa13159ac3
	_editor.call_deferred("set_plugin_enabled", PLUGIN_NAME, false)
	_editor.call_deferred("set_plugin_enabled", PLUGIN_NAME, true)


func _exit_tree() -> void:
	_unload_scene()