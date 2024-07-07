extends PanelContainer

func _ready()->void:
	Signalbus.resolution_changed.connect(_on_resolution_changed)
	pass

func _on_close_pressed() -> void:
	self.hide()
	pass # Replace with function body.


func _on_h_slider_2_value_changed(value:float) -> void:
	Global.music_volume = value
	var audio_manager : Node2D = get_node("../../audio_manager")
	audio_manager.change_music_volume()
	pass # Replace with function body.



func _on_h_slider_value_changed(value:float)->void:
	Global.sound_volume = value
	var audio_manager : Node2D = get_node("../../audio_manager")
	audio_manager.change_sound_volume()
	pass # Replace with function body.


func _on_option_button_item_selected(index:int)->void:
	match index:
		0:
			Global.resolution = "1920x1080"
			Signalbus.resolution_changed.emit()
			print("selected 1080p")
		1:
			Global.resolution = "1280x720"
			Signalbus.resolution_changed.emit()
			print("selected 720p")
		_:
			pass
	print("item selected")
	pass # Replace with function body.
func _on_resolution_changed()->void:
	match Global.resolution:
		"1920x1080":
			get_tree().root.content_scale_size = Vector2i(1920,1080)
			DisplayServer.window_set_size(Vector2i(1920,1080))
			print(Global.resolution + "selected")
		"1280x720":
			get_tree().root.content_scale_size = Vector2i(1280,720)
			DisplayServer.window_set_size(Vector2i(1280,720))
			print(Global.resolution + "selected")
	print("signal connected")
	pass
