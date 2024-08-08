class_name Driver
extends Node2D

@onready var audio_mgr: AudioManager = $AudioManager
@onready var _menu_mgr: MenuManager = $OverlayManager/MenuManager
@onready var _curtain := $OverlayManager/Curtain
@onready var _world := $GameWorld
@onready var _devin: Devin = %Devin

var _last_loaded_level: LevelBase = null


func _ready() -> void:
	_curtain.visible = true
	audio_mgr.play(Enums.AudioTrack.SKETCH_1, .75)
	# call via deferred so we don't have await in the _ready path. I'm not
	# sure that's a bad thing to do but it felt weird so here we are.
	call_deferred("_post_ready")


func _post_ready() -> void:
	_menu_mgr.show_menu(Enums.MenuType.DEBUG)
	await _curtain.fade_out(1)


func load_level(tgt: LevelBase, target_name: String) -> void:
	_world.add_child(tgt)
	if _last_loaded_level != null:
		_world.remove_child(_last_loaded_level)
		_last_loaded_level.save_level_state()
		_last_loaded_level.queue_free()
	tgt.setup(self)
	_devin.visible = true
	_devin.player_controled = true
	if target_name == null || target_name == "":
		target_name = LevelBase.DEFAULT_MARKER
	var location := tgt.get_named_location(target_name)
	_devin.global_position = location

	_last_loaded_level = tgt


func request_debug_load(path: String) -> void:
	var music_ready := audio_mgr.play(Enums.AudioTrack.SKETCH_2, 2)
	await _curtain.fade_in(1)
	_menu_mgr.hide_menu(Enums.MenuType.DEBUG)

	print("Loading path: %s" % [path])
	var new_scene_resource := load(path) as PackedScene
	var new_scene := new_scene_resource.instantiate()
	print(new_scene)
	if new_scene is LevelBase:
		load_level(new_scene as LevelBase, LevelBase.DEFAULT_MARKER)
	else:
		_world.add_child(new_scene)
		new_scene.setup(self)

	await music_ready.finished
	await _curtain.fade_out(1)
