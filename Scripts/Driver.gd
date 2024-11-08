class_name Driver
extends Node2D

## This will bypass the normal menu and automatically swap to the provided
## scene. It [b]must[/b] be a child of LevelBase.
@export var autoload_scene: PackedScene

var _last_loaded_level: LevelBase = null

@onready var audio_mgr: AudioManager = $AudioManager
@onready var player: Devin = %Devin
@onready var inventory_mgr: InventoryManager = $InventoryManager
@onready var quest_mgr: QuestManager = $QuestManager
@onready var _menu_mgr: MenuManager = $OverlayManager/MenuManager
@onready var _curtain := $OverlayManager/Curtain
@onready var _world := $GameWorld
@onready var _hud: HUD = $OverlayManager/HUD
@onready var _debug_ui_inventory := $OverlayManager/HUD/DebugInventoryUI
@onready var _debug_ui_quest: QuestTracker = $OverlayManager/HUD/DebugQuestUI


static func instance() -> Driver:
	return Engine.get_singleton("DriverInstance")


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
	_debug_ui_quest.setup(quest_mgr)

	if autoload_scene != null:
		var level_instance := autoload_scene.instantiate() as LevelBase
		await _curtain.fade_in(1)
		load_level(level_instance, "")
		await _curtain.fade_out(1)
	else:
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

	# make sure the hud is shown
	get_hud().show()

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


## Returns the currently loaded level. A bit of a hack for routing things into
## Quest effect chain.
func get_current_level() -> LevelBase:
	return _last_loaded_level


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


func _on_debug_pressed() -> void:
	quest_mgr.debug_print()
