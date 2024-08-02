class_name AudioManager
extends Node

const AUDIO_PREFS_PATH = "user://audio_prefs.dat"
const DB_MIN: float = -25
const DB_MAX: float = 8

var cur_track: Enums.AudioTrack

@onready var bgm_player: AudioStreamPlayer2D = %BGPlayer


func _ready() -> void:
	cur_track = Enums.AudioTrack.NONE
	load_levels()


## starts playing a given track with some caveats:
##  1. if the same as the current track no change is made
##  2. if a different track is playing *and* fade_in > 0 we fade out then back
##     up in fade_in/2 seconds
##  3. if no track is playing and fade_in > 0 we set volume to -80 then fade
##     to the previous volume in fade_in
##
## Returns a Tween that can be awaited indicating this is all completed
func play(tgt_track: Enums.AudioTrack, fade_in: float = 0) -> Tween:
	if tgt_track == Enums.AudioTrack.NONE:
		return stop(fade_in)

	if cur_track != tgt_track:
		print('cur_track %s != tgt_track %s' % [cur_track, tgt_track])
		if bgm_player.playing:
			return crossfade_to(tgt_track, fade_in)

		var stream: AudioStream = ResourceLoader.load(Enums.audio_track_path(tgt_track))
		bgm_player.stream = stream

	# either playing the current track on not playing
	var tween := get_tree().create_tween()

	var tgt_vol := bgm_player.volume_db

	if bgm_player.playing:
		# playing the current track
		tween.tween_property(bgm_player, "volume_db", tgt_vol, 0)
		return tween

	# default to no volume
	var start_vol := -80
	if fade_in == 0:
		start_vol = tgt_vol

	bgm_player.volume_db = start_vol
	cur_track = tgt_track
	bgm_player.play()
	tween.tween_property(bgm_player, "volume_db", tgt_vol, fade_in)
	return tween


## fades the current track out and a second track in, does not check if the
## current track is the same as the target so it's possible to fade out & in
## to the same track
##
## the fade out happens in fade_time / 2
## the fade in happens in fade_time / 2
##
## returns a Tween than can be used to await the transition's completion
func crossfade_to(tgt_track: Enums.AudioTrack, fade_time: float) -> Tween:
	var tgt_vol := bgm_player.volume_db
	var tween := get_tree().create_tween()
	var stream: AudioStream = ResourceLoader.load(Enums.audio_track_path(tgt_track))
	tween.tween_property(bgm_player, "volume_db", -80, fade_time / 2)
	tween.tween_callback(func() -> void: cur_track = tgt_track)
	tween.tween_callback(_set_stream.bind(bgm_player, stream, true))
	tween.tween_property(bgm_player, "volume_db", tgt_vol, fade_time / 2)
	return tween


## stops the current track with an optional fade out
## returns the tween responsible for handling the fade or null if no fade is requested
func stop(fade_time: float = 0) -> Tween:
	if fade_time == 0:
		bgm_player.stop()
		cur_track = Enums.AudioTrack.NONE
		return null

	var tween := get_tree().create_tween()
	tween.tween_property(bgm_player, "volume_db", 1.5 * DB_MIN, fade_time)
	tween.tween_callback(bgm_player.stop)
	tween.tween_callback(func() -> void: bgm_player.volume_db = 0)
	return tween


func _set_stream(player: AudioStreamPlayer2D, stream: AudioStream, should_play: bool) -> void:
	player.stream = stream
	if should_play:
		player.play()


## Saves the bus volume levels to disk
func save_levels() -> void:
	var data: Dictionary = {}
	for i in range(0, AudioServer.bus_count):
		var value := AudioServer.get_bus_volume_db(i)
		data[i] = value

	var json_str := JSON.stringify(data)
	var file := FileAccess.open(AUDIO_PREFS_PATH, FileAccess.WRITE)
	if file == null:
		print(FileAccess.get_open_error())
		return
	file.store_string(json_str)
	file.close()


## Loads bus volume levels from disk; if not previous values exist make no
## changes and use game defaults.
func load_levels() -> void:
	if !FileAccess.file_exists(AUDIO_PREFS_PATH):
		printerr("No data at prefs path, using defaults")
		return

	var file := FileAccess.open(AUDIO_PREFS_PATH, FileAccess.READ)
	var json_prefs_data := file.get_as_text()

	var json := JSON.new()
	var err := json.parse(json_prefs_data)
	if err != OK || typeof(json.data) != TYPE_DICTIONARY:
		printerr("Failed to read prefs data: " + str(err))
		return

	var data: Dictionary = json.data
	for k: String in data.keys():
		var vol: float = data[k]
		AudioServer.set_bus_volume_db(k.to_int(), vol)


func _volume_to_db(level: float) -> float:
	level = clampf(level, 0, 1)
	var x := DB_MIN + (level * (DB_MAX - DB_MIN))
	return x


func _db_to_volume(db_level: float) -> float:
	var vol := clampf(db_level, DB_MIN, DB_MAX) - DB_MIN
	return clampf(vol / (DB_MAX - DB_MIN), 0, 1)


# TODO: Open question if disconnecting levels and db is a good idea. Originally
# I did it because I thought it'd be easier to build options UIs around [0, 1]
# than [-80, 6] but maybe that's dumb. TBD we can roll it back if needed.
# On the other hand I find this to be a better way to make our low-end correspond
# to more useful levels than -80, -75, etc.


## Sets the volume level as a value 0->1 for a specific audio bus
## handles converting into db internally
func set_level(bus: Enums.AudioBus, volume_pct: float) -> void:
	var idx := Enums.audio_bus_index(bus)
	var new_level := clampf(_volume_to_db(volume_pct), DB_MIN, DB_MAX)
	AudioServer.set_bus_mute(idx, new_level <= DB_MIN)
	AudioServer.set_bus_volume_db(idx, new_level)


## returns the level of a requested audio bus in a 0->1 range.
func get_level(bus: Enums.AudioBus) -> float:
	return _db_to_volume(AudioServer.get_bus_volume_db(Enums.audio_bus_index(bus)))
