extends Node2D

var next : int = 0
var audioStreamPlayers : Array = []

@export var count : int = 1
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if get_child_count() == 0:
		print("No AudioStreamPlayer Found")
		return
	var child : AudioStreamPlayer2D= get_child(0)
	if child is AudioStreamPlayer2D:
		audioStreamPlayers.append(child)
		for i in range(count):
			var dup : AudioStreamPlayer2D = child.duplicate()
			add_child(dup)
			audioStreamPlayers.append(dup)
		pass
	change_music_volume()
	pass # Replace with function body.
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta :float) -> void :
	if Global.volume_changed :
		Global.volume_changed = false
		change_music_volume()
	pass
#func _get_configuration_warnings() -> PackedStringArray:
	#var child : AudioStreamPlayer2D= get_child(0)
	#if get_child_count() == 0:
		#var string : String = "No children found. Expected one AudioStreamPlayer child."
		#return string
	#if child is AudioStreamPlayer2D:
		#pass
	#else:
		#var string : String= "Expected first child to be an AudioStreamPlayer."
		#return string
	#return self._get_configuration_warnings()
func play_sound() -> void:
	if !audioStreamPlayers[next].playing:
		next = next +1 
		audioStreamPlayers[next].play()
		
		next %= audioStreamPlayers.size()
func play_music(musicname : String,mode : String = "")-> String:
	if musicname == null or musicname == "":
		return "No music selected"
	else:
		var player : AudioStreamPlayer2D = get_child(0)
		if player is AudioStreamPlayer2D:
			#var getmusic = ResourceLoader.load("res://Music/"+musicname+".mp3")
			var getmusic : AudioStream = ResourceLoader.load("res://assets/temp/"+musicname+".mp3")
			Global.active_music = musicname
			player.stream = getmusic
			if player.playing == true:
				player.stop()
				transition_music(player,mode)
			else:
				transition_music(player,mode)
	return ""
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
			tween.tween_property(player_node,"volume_db",Global.music_volume,2)
			await get_tree().create_timer(2).timeout
			tween.kill()
		_:
			player_node.play()
			pass
	pass
func change_music_volume() -> void:
	var player :AudioStreamPlayer2D = get_child(0)
	if player is AudioStreamPlayer2D:
		player.volume_db = Global.music_volume
	pass
func change_sound_volume() -> void:
	var player :AudioStreamPlayer2D = get_child(1)
	if player is AudioStreamPlayer2D:
		player.volume_db = Global.sound_volume
	pass
func stop_music(fade : int = 0) -> void:
	var player :AudioStreamPlayer2D = get_child(0)
	if player is AudioStreamPlayer2D:
		if player.playing == true:
			Global.active_music = ""
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
	pass
