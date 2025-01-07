@tool
class_name TGOGreyboxingToolsPlugin
extends EditorPlugin

const PLUGIN_NAME = "tgo_greyboxing"

var _control_scene: TGOControlDock = null
var _quest_editor_scene: QuestMainPanel = null
var _editor: EditorInterface = null

var _interactable_plugin: EditorInspectorPlugin

func _enter_tree() -> void:
	if !Engine.is_editor_hint():
		return
	_editor = get_editor_interface()

	_load_scene()


func _has_main_screen() -> bool:
	return true

func _make_visible(visible: bool) -> void:
	_quest_editor_scene.visible = visible


func _get_plugin_name() -> String:
	return "Quest Manager"


func _get_plugin_icon():
	return EditorInterface.get_editor_theme().get_icon("Node", "EditorIcons")


func _load_scene() -> void:
	if !Engine.is_editor_hint():
		return
	var control_scene_res := load("res://addons_tgo/greyboxing/UI/TGOControlDock.tscn")
	_control_scene = control_scene_res.instantiate() as TGOControlDock
	add_control_to_dock(DOCK_SLOT_LEFT_BR, _control_scene)
	_control_scene.setup(self)

	_quest_editor_scene = load("res://addons_tgo/quest/quest_main_panel.tscn").instantiate()
	_editor.get_editor_main_screen().add_child(_quest_editor_scene)
	_make_visible(false)
	_quest_editor_scene.setup(_editor)

	_interactable_plugin = TGOInspectorInteractable.new()
	add_inspector_plugin(_interactable_plugin)


func _unload_scene() -> void:
	remove_control_from_docks(_control_scene)
	_control_scene.hide()
	_control_scene.queue_free()
	_quest_editor_scene.queue_free()
	_quest_editor_scene = null

	# this reports nonexisting inspector plugin...?
	# remove_inspector_plugin(_interactable_plugin)


func reload() -> void:
	print('TGOGreyboxingToolsPlugin.reload')
	# https://www.reddit.com/r/godot/comments/hvqxco/comment/l3oj782/
	# https://gist.github.com/stravant/7aec484bb5e34e3a6196faaa13159ac3
	_editor.call_deferred("set_plugin_enabled", PLUGIN_NAME, false)
	_editor.call_deferred("set_plugin_enabled", PLUGIN_NAME, true)


func _exit_tree() -> void:
	_unload_scene()
	remove_inspector_plugin(_interactable_plugin)
