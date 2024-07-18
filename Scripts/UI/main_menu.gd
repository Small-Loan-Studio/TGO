extends Control


var audio : Node2D
func _ready() -> void:
	audio = $audio_manager
	audio.play_music("mirage")

func _on_exit_pressed() -> void:
	get_tree().quit()


func _on_newgame_pressed() -> void:
	get_tree().change_scene_to_file("res://Scratch/Movement/TestMovement.tscn")

func _on_loadgame_pressed() ->void:
	var load_window : Control= $canvas/load_window
	load_window.show()

func _on_options_pressed() -> void:
	var options_window : Control = $canvas/options_window
	options_window.show()