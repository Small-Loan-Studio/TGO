class_name Driver
extends Node2D

@onready var _menu_mgr: MenuManager = $OverlayManager/MenuManager
@onready var _curtain := $OverlayManager/Curtain
@onready var _world := $GameWorld

func _ready() -> void:
	_curtain.visible = true
	call_deferred('_post_ready')

func _post_ready() -> void:
	_menu_mgr.show_menu(Enums.MenuType.DEBUG)
	await _curtain.fade_out(1)


func request_debug_load(path:String) -> void:
	await _curtain.fade_in(1)

	var new_scene_resource := load(path) as PackedScene
	var new_scene := new_scene_resource.instantiate()
	_world.add_child(new_scene)
	_menu_mgr.hide_menu(Enums.MenuType.DEBUG)

	await _curtain.fade_out(1)
