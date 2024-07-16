class_name DebugMenu
extends Control

@onready var _button_container := %ButtonContainer

signal request_load(path: String)

func _ready() -> void:
	var scene_dict := ScratchScenes.get_scenes()
	for k in (scene_dict.keys() as Array[String]):
		var b := Button.new()
		b.text = k
		b.pressed.connect(_on_load_request.bind(scene_dict[k]))
		_button_container.add_child(b)

func _on_load_request(path: String) -> void:
	request_load.emit(path)