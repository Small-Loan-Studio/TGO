class_name AudioManager
extends Node

const AUDIO_PREFS_PATH = "user://audio_prefs.dat"
const DB_MIN: float = -25
const DB_MAX: float = 8

var _akhelper: AKHelper
var _levels_local := false

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
	for bus_name in AKHelper.bus_names():
		var bus_id := AKHelper.get_bus_id(bus_name)
		var bus_param := AKHelper.bus_param(bus_id)
		var level := _normalize_bus_level(_akhelper.get_param(bus_param, false))
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
			var bus_enum := int(key) as Enums.AudioBus
			var stored_vol := data[key] as float
			set_level(bus_enum, stored_vol)
		else:
			var wwise_name := String(key)
			var level := data[key] as float
			set_level(AKHelper.bus_from_name(wwise_name), level)


func _volume_to_db(level: float) -> float:
	level = clampf(level, 0, 1)
	var x := DB_MIN + (level * (DB_MAX - DB_MIN))
	return x


func _db_to_volume(db_level: float) -> float:
	var vol := clampf(db_level, DB_MIN, DB_MAX) - DB_MIN
	return clampf(vol / (DB_MAX - DB_MIN), 0, 1)


## Sets the volume level as a value 0->1 for a specific audio bus
## handles converting into db internally
func set_level(bus: Enums.AudioBus, volume_pct: float) -> void:
	if _akhelper:
		var wwise_level := _unnormalize_bus_level(volume_pct)
		var rtpc_param := AKHelper.bus_param_from_enum(bus)
		_akhelper.send_param(rtpc_param, wwise_level, _levels_local)
	else:
		print("No _akhelper is registered, failed to set_level")


## returns the level of a requested audio bus in a 0->1 range.
func get_level(bus: Enums.AudioBus) -> float:
	if _akhelper:
		var bus_rtpc_id := AKHelper.bus_param_from_enum(bus)
		return _normalize_bus_level(_akhelper.get_param(bus_rtpc_id, _levels_local))
	print("No _akhelper is registered, failed to get_level")
	return 0


func _normalize_bus_level(wwise_level: float) -> float:
	return wwise_level / 100


func _unnormalize_bus_level(local_level: float) -> float:
	return local_level * 100
