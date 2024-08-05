extends Node2D

@export var count : int = 1

var next : int = 0
var audio_stream_players : Array = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	play_music("mirage")
	change_music_volume()


func play_music(musicname : String,mode : String = "")-> void:
	if musicname == null or musicname == "":
		print("No music selected")
		return

	var player : AudioStreamPlayer2D = get_child(0)
	if player is AudioStreamPlayer2D:

		var getmusic : AudioStream = ResourceLoader.load("res://Audio/BGM/temp/"+musicname+".mp3")
		player.stream = getmusic
		if player.playing == true:
			player.stop()
			transition_music(player,mode)
		else:
			transition_music(player,mode)

func transition_music(player_node : AudioStreamPlayer2D,mode :String) -> void:
	match mode:
		"fade_out":
			var tween :Tween = get_tree().create_tween()
			tween.tween_property(player_node,"volume_db",-70,2)
			await get_tree().create_timer(2).timeout
			tween.kill()
			player_node.stop()
		"fade_in":
			var tween : Tween= get_tree().create_tween()
			player_node.play()
			player_node.volume_db = -70
			await get_tree().create_timer(2).timeout
			tween.kill()
		_:
			player_node.play()

func change_music_volume() -> void:
	var player :AudioStreamPlayer2D = get_child(0)

func change_sound_volume() -> void:
	var player :AudioStreamPlayer2D = get_child(1)
func stop_music(fade : int = 0) -> void:
	var player :AudioStreamPlayer2D = get_child(0)
	if player is AudioStreamPlayer2D:
		if player.playing == true:
			if fade == 0 :
				player.stop()
			else:
				var tween : Tween = get_tree().create_tween()
				tween.tween_property(player,"volume_db",-70,fade)
				await get_tree().create_timer(fade).timeout
				tween.kill()
				player.stop()
		else:
			pass

func play_soundeffect(soundname : String) -> void:
	var player : AudioStreamPlayer2D = get_child(1)
	if player is AudioStreamPlayer2D:
		var getsound : AudioStream = ResourceLoader.load("res://Sound/"+soundname+".mp3")
		player.stream = getsound
		if player.playing == true:
			player.stop()
			player.play()
		else:
			player.play()
