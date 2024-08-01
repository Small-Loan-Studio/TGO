extends Node2D

var _audio_mgr: AudioManager = null

@onready var master_val: Label = $CanvasLayer/Master/Value
@onready var master_val_db: Label = $CanvasLayer/Master/ValueDB
@onready var bgm_val: Label = $CanvasLayer/Background/Value
@onready var bgm_val_db: Label = $CanvasLayer/Background/ValueDB


func setup(driver: Driver) -> void:
	_audio_mgr = driver.audio_mgr


func _process(_delta: float) -> void:
	if _audio_mgr != null:
		var n: int = (_audio_mgr.get_level(Enums.AudioBus.MASTER) * 100) as int
		master_val.text = str(n) + "%"
		master_val_db.text = "%.2f db" % [
			AudioServer.get_bus_volume_db(Enums.audio_bus_index(Enums.AudioBus.MASTER)),
		]

		var bg_n: int = (_audio_mgr.get_level(Enums.AudioBus.BACKGROUND_MUSIC) * 100) as int
		bgm_val.text = str(bg_n) + "%"
		bgm_val_db.text = "%.2f db" % [
			AudioServer.get_bus_volume_db(Enums.audio_bus_index(Enums.AudioBus.BACKGROUND_MUSIC)),
		]
	else:
		master_val.text = "!"
		master_val_db.text = "!"
		bgm_val.text = "!"
		bgm_val_db.text = "!"


func _up(bus: Enums.AudioBus) -> void:
	var cur := _audio_mgr.get_level(bus)
	_audio_mgr.set_level(bus, cur + .05)


func _down(bus: Enums.AudioBus) -> void:
	var cur := _audio_mgr.get_level(bus)
	_audio_mgr.set_level(bus, cur - .05)


func _master_up() -> void:
	_up(Enums.AudioBus.MASTER)


func _master_down() -> void:
	_down(Enums.AudioBus.MASTER)


func _bgm_up() -> void:
	_up(Enums.AudioBus.BACKGROUND_MUSIC)


func _bgm_down() -> void:
	_down(Enums.AudioBus.BACKGROUND_MUSIC)


func _level_save() -> void:
	_audio_mgr.save_levels()


func _levels_load() -> void:
	_audio_mgr.load_levels()


func _play_pressed() -> void:
	_audio_mgr.play(Enums.AudioTrack.SKETCH_1)


func _stop_pressed() -> void:
	_audio_mgr.stop(2)