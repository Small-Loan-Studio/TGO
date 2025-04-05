class_name AudioManager
extends Node

const AUDIO_PREFS_PATH = "user://audio_prefs.dat"
const DB_MIN: float = -25
const DB_MAX: float = 8
const _old_new_mapping := {
		Enums.AudioBus.MASTER: "Main",
		Enums.AudioBus.BACKGROUND_MUSIC: "Background Music",
		Enums.AudioBus.SOUND_EFFECTS: "Sound Effects",
		Enums.AudioBus.MENU_EFFECTS: "Menu",
		Enums.AudioBus.AMBIENT: "Ambient Sounds",
	}

var _akhelper: AKHelper

@onready var bgm_player: AudioStreamPlayer2D = %BGPlayer


func _ready() -> void:
	var success: bool = Wwise.register_game_obj(self, "Audio Manager")
	if !success:
		print("Failed to register AudioManager with Wwise")
	_akhelper = AKHelper.new(self)
	load_levels_wwise()


# sends a global event to wwise, See AK.EVENTS.XYZ for options
func send_event(event: int) -> void:
	_akhelper.send_event(event)


## Saves the bus volume levels to disk
func save_levels() -> void:
	var data: Dictionary = {}
	data["wwise"] = true
	for bus_name in _akhelper.bus_names():
		var bus_id := _akhelper.get_bus_id(bus_name)
		var bus_param := _akhelper.bus_param(bus_id)
		var level := _normalize_bus_level(_akhelper.get_param(bus_param))
		data[bus_name] = level

	var json_str := JSON.stringify(data)
	var file := FileAccess.open(AUDIO_PREFS_PATH, FileAccess.WRITE)
	if file == null:
		print(FileAccess.get_open_error())
		return
	file.store_string(json_str)
	file.close()


func load_levels_wwise() -> void:
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
	var wwise_levels := data.has("wwise") && (data["wwise"] as bool)

	for key: String in data.keys():
		if key == "wwise":
			continue

		if !wwise_levels:
			var bus_id := int(key)
			bus_id = _akhelper.get_bus_id(_old_new_mapping[bus_id])
			var stored_vol := data[key] as float
			var mapped_vol := _db_to_volume(stored_vol)
			var scaled_vol := _unnormalize_bus_level(mapped_vol)
			_akhelper.send_param(_akhelper.bus_param(bus_id), scaled_vol)
		else:
			var bus_name := String(key)
			var bus_id := _akhelper.get_bus_id(bus_name)
			var bus_param := _akhelper.bus_param(bus_id)
			_akhelper.send_param(bus_param, _unnormalize_bus_level(data[key]))


func _volume_to_db(level: float) -> float:
	level = clampf(level, 0, 1)
	var x := DB_MIN + (level * (DB_MAX - DB_MIN))
	return x


func _db_to_volume(db_level: float) -> float:
	var vol := clampf(db_level, DB_MIN, DB_MAX) - DB_MIN
	return clampf(vol / (DB_MAX - DB_MIN), 0, 1)


## Sets the volume level as a value 0->100 for a specific audio bus
## handles converting into db internally
func set_level(bus: Enums.AudioBus, volume_pct: float) -> void:
	if _akhelper:
		var ak_bus_id := _akhelper.get_bus_id(_old_new_mapping[bus])
		var rtpc_param := _akhelper.bus_param(ak_bus_id)
		_akhelper.send_param(rtpc_param, 100.0 * volume_pct)


## returns the level of a requested audio bus in a 0->1 range.
func get_level(bus: Enums.AudioBus) -> float:
	var bus_id: Variant = _akhelper.get_bus_id(_old_new_mapping[bus])
	var bus_rtpc_id := _akhelper.bus_param(bus_id)
	return _normalize_bus_level(_akhelper.get_param(bus_rtpc_id))

func _normalize_bus_level(wwise_level: float) -> float:
	return wwise_level / 100

func _unnormalize_bus_level(local_level: float) -> float:
	return local_level * 100