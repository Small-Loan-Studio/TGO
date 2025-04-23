extends Menu

@onready var _debug_container := $SectionContainer/DebugContainer


func _ready() -> void:
	var scene_dict := ScratchScenes.get_scenes()
	for k in scene_dict.keys() as Array[String]:
		var b := Button.new()
		b.text = k
		b.pressed.connect(_on_load_request.bind(scene_dict[k]))
		_debug_container.add_child(b)


func _on_load_request(path: String) -> void:
	Driver.instance().load_level(path, "")


func _on_back_button_pressed() -> void:
	dismiss.emit()
