class_name Driver
extends Node2D

static func instance() -> Driver:
	return Engine.get_singleton('DriverInstance')

var _last_loaded_level: LevelBase = null

@onready var audio_mgr: AudioManager = $AudioManager
@onready var player: Devin = %Devin
@onready var _menu_mgr: MenuManager = $OverlayManager/MenuManager
@onready var _curtain := $OverlayManager/Curtain
@onready var _world := $GameWorld
@onready var _hud: HUD = $OverlayManager/HUD


func _ready() -> void:
	_curtain.visible = true
	if !Engine.has_singleton('DriverInstance'):
		Engine.register_singleton('DriverInstance', self)
	else:
		printerr('Attempting to register a second singleton')

	audio_mgr.play(Enums.AudioTrack.SKETCH_1, .75)
	# call via deferred so we don't have await in the _ready path. I'm not
	# sure that's a bad thing to do but it felt weird so here we are.
	call_deferred("_post_ready")


func _post_ready() -> void:
	_menu_mgr.show_menu(Enums.MenuType.DEBUG)
	await _curtain.fade_out(1)


func get_hud() -> HUD:
	return _hud

## Loads a new level into the game world
func load_level(tgt: LevelBase, target_name: String) -> void:
	# first add the new level
	_world.add_child(tgt)
	if _last_loaded_level != null:
		# if we had a previous level clean it up.
		_world.remove_child(_last_loaded_level)
		_last_loaded_level.save_level_state()
		_last_loaded_level.queue_free()
	# run any setup the level needs to do to work
	tgt.setup(self)
	# TODO: get the player ready and move them to the appropriate location
	# we'll probably want to parameterize this more eventually.
	player.visible = true
	player.player_controled = true
	if target_name == null || target_name == "":
		target_name = LevelBase.DEFAULT_MARKER
	var location := tgt.get_named_location(target_name)
	player.global_position = location

	# update level ref
	_last_loaded_level = tgt


## TODO: We'll need to switch away  from debug load path soon
func request_debug_load(path: String) -> void:
	var music_ready := audio_mgr.play(Enums.AudioTrack.SKETCH_2, 2)
	await _curtain.fade_in(1)
	_menu_mgr.hide_menu(Enums.MenuType.DEBUG)

	var new_scene_resource := load(path) as PackedScene
	var new_scene := new_scene_resource.instantiate()
	if new_scene is LevelBase:
		load_level(new_scene as LevelBase, LevelBase.DEFAULT_MARKER)
	else:
		_world.add_child(new_scene)
		_world.remove_child(player)
		player.queue_free()
		new_scene.setup(self)

	await music_ready.finished
	await _curtain.fade_out(1)
