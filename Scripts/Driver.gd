class_name Driver
extends Node2D

## This will bypass the normal menu and automatically swap to the provided
## scene. It [b]must[/b] be a child of LevelBase.
@export var autoload_scene: PackedScene

## TODO: Replace this with the official location for levels in the future
const LEVEL_FILE_PATH: String = "res://ZZ_Scratch/GreyboxingTools/"
const FIRST_LEVEL_NAME: String = "BadLevelA"

var _last_loaded_level: LevelBase = null

@onready var audio_mgr: AudioManager = $AudioManager
@onready var player: Devin = %Devin
@onready var inventory_mgr: InventoryManager = $InventoryManager
@onready var _menu_mgr: MenuManager = $OverlayManager/MenuManager
@onready var _curtain := $OverlayManager/Curtain
@onready var _world := $GameWorld
@onready var _hud: HUD = $OverlayManager/HUD
@onready var _debug_ui_inventory := $OverlayManager/HUD/DebugInventoryUI
@onready var _serialization_mgr: SerializationManager = $SerializationManager


static func instance() -> Driver:
	return Engine.get_singleton("DriverInstance") as Driver


func _ready() -> void:
	_curtain.visible = true
	if !Engine.has_singleton("DriverInstance"):
		Engine.register_singleton("DriverInstance", self)
	else:
		printerr("Attempting to register a second singleton")

	audio_mgr.play(Enums.AudioTrack.SKETCH_1, .75)
	# call via deferred so we don't have await in the _ready path. I'm not
	# sure that's a bad thing to do but it felt weird so here we are.
	call_deferred("_post_ready")

	# TODO: we probably don't want to use this as a way to wire up the inventory
	# replace eventually with a more principled method that can be used for more
	# than just one-offs
	inventory_mgr.get_inventory(player.id).inventory_updated.connect(_debug_refresh_inventory_ui)
	# do an initial build from the start state
	_debug_refresh_inventory_ui(inventory_mgr.get_inventory(player.id))


func _debug_refresh_inventory_ui(inventory: Inventory) -> void:
	var items := inventory.get_items()
	_debug_ui_inventory.visible = items.size() > 0
	_debug_ui_inventory.build(items)


func _post_ready() -> void:
	if autoload_scene != null:
		var level_instance := autoload_scene.instantiate() as LevelBase
		await _curtain.fade_in(1)
		load_level(level_instance.level_name, "")
		await _curtain.fade_out(1)
	else:
		_menu_mgr.show_menu(Enums.MenuType.DEBUG)
		await _curtain.fade_out(1)


func get_hud() -> HUD:
	return _hud


## Loads a new level into the game world
func load_level(target_level_name: String, target_name: String) -> void:
	# first add the new level
	var load_level: PackedScene
	var new_level: LevelBase
	
	if _last_loaded_level != null:
		# if we had a previous level clean it up.

		_serialization_mgr._update_persistent_level(_last_loaded_level)
		_world.remove_child(_last_loaded_level)
		_last_loaded_level.save_level_state()
		_last_loaded_level.queue_free()

	# make sure the hud is shown
	get_hud().show()

	# run any setup the level needs to do to work
	print("Target Level Name: "+target_level_name)
	if _serialization_mgr.check_level_persistence(target_level_name):
		load_level= load(_serialization_mgr.get_persistent_level_dict()[target_level_name])
		print("Loading persisting level")
	else:
		load_level= load(LEVEL_FILE_PATH+target_level_name+".tscn")
		print("Loading non-persisting level")
	
	new_level = load_level.instantiate()
	_world.add_child(new_level, true)
	new_level.setup(self)

	# TODO: get the player ready and move them to the appropriate location
	# we'll probably want to parameterize this more eventually.
	player.visible = true
	player.player_controled = true
	if target_name == null || target_name == "":
		target_name = LevelBase.DEFAULT_MARKER
	var location := new_level.get_named_location(target_name)
	player.global_position = location

	# update level ref
	_last_loaded_level = new_level


## TODO: We'll need to switch away  from debug load path soon
func request_debug_load(path: String) -> void:
	var music_ready := audio_mgr.play(Enums.AudioTrack.SKETCH_2, 2)
	await _curtain.fade_in(1)
	_menu_mgr.hide_menu(Enums.MenuType.DEBUG)
	print("debug loading")
	load_level(FIRST_LEVEL_NAME, LevelBase.DEFAULT_MARKER)

	await music_ready.finished
	await _curtain.fade_out(1)


func _on_debug_pressed() -> void:
	pass
	#print(Dialogic.VAR.get_variable("HasSpoken"))
