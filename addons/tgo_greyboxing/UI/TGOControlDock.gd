@tool
class_name TGOControlDock
extends Control

var _plugin_ref: TGOGreyboxingToolsPlugin = null

func setup(plugin_ref: TGOGreyboxingToolsPlugin) -> void:
	_plugin_ref = plugin_ref

func _reload() -> void:
	_plugin_ref.reload()