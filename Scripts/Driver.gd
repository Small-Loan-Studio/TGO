class_name Driver
extends Node2D

@onready var audio_mgr: AudioManager = $AudioManager

@onready var _menu_mgr: MenuManager = $OverlayManager/MenuManager
@onready var _curtain := $OverlayManager/Curtain
@onready var _world := $GameWorld
@onready var _devin: Devin = %Devin


func _ready() -> void:
	_curtain.visible = true
	audio_mgr.play(Enums.AudioTrack.SKETCH_1, .75)
	# call via deferred so we don't have await in the _ready path. I'm not
	# sure that's a bad thing to do but it felt weird so here we are.
	call_deferred("_post_ready")


func _post_ready() -> void:
	_menu_mgr.show_menu(Enums.MenuType.DEBUG)
	await _curtain.fade_out(1)


func load_level(tgt: PackedScene) -> void:
	print("Driver.load_level")

func request_debug_load(path: String) -> void:
	var music_ready := audio_mgr.play(Enums.AudioTrack.SKETCH_2, 2)
	await _curtain.fade_in(1)

	var new_scene_resource := load(path) as PackedScene
	var new_scene := new_scene_resource.instantiate()
	_world.add_child(new_scene)
	new_scene.setup(self)
	_menu_mgr.hide_menu(Enums.MenuType.DEBUG)

	await music_ready.finished
	await _curtain.fade_out(1)
