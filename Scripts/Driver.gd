class_name Driver
extends Node2D

signal resumed

var _last_loaded_level: LevelBase = null

@onready var audio_mgr: AudioManager = $AudioManager
@onready var player: Devin = %Devin
@onready var inventory_mgr: InventoryManager = $InventoryManager
@onready var menus: Menus = $OverlayManager/Menus
@onready var quest_mgr: QuestManager = $QuestManager
@onready var _curtain := $OverlayManager/Curtain
@onready var _presentation := $GameWorld/Presentation
@onready var _world := $GameWorld
@onready var _day_night_cycle: DayNightCycle = $GameWorld/DayNightOverlay
@onready var _hud: HUD = $OverlayManager/HUD
@onready var _serialization_mgr: SerializationManager = $SerializationManager
@onready var _debug_ui_inventory := $OverlayManager/HUD/DebugInventoryUI
@onready var _debug_ui_equipment: DebugEquipment = $OverlayManager/HUD/RightDebug/DebugEquipment
@onready var _debug_ui_quest: QuestTracker = $OverlayManager/HUD/DebugCorner/DebugQuestUI
@onready var _debug_dnc: DebugDayNight = $OverlayManager/HUD/DebugStack/DebugDayNight
@onready var _debug_inventory: DebugInventory = $OverlayManager/HUD/DebugStack/DebugInventory
@onready var _debug_quests: QuestDebugger = $OverlayManager/HUD/DebugStack/QuestDebugger
@onready var _personal_config := $PersonalDevConfig


static func instance() -> Driver:
	return Engine.get_singleton("DriverInstance") as Driver


func _ready() -> void:
	_curtain.visible = true
	if !Engine.has_singleton("DriverInstance"):
		Engine.register_singleton("DriverInstance", self)
	else:
		printerr("Attempting to register a second singleton")

	# call via deferred so we don't have await in the _ready path. I'm not
	# sure that's a bad thing to do but it felt weird so here we are.
	call_deferred("_post_ready")

	# TODO: we probably don't want to use this as a way to wire up the inventory
	# replace eventually with a more principled method that can be used for more
	# than just one-offs
	inventory_mgr.inventory_updated.connect(_debug_refresh_inventory_ui)
	# do an initial build from the start state
	_debug_refresh_inventory_ui(player.id)


func _debug_refresh_inventory_ui(inventory_id: String) -> void:
	if inventory_id.to_lower() != Utils.PLAYER_ID.to_lower():
		return
	var items := inventory_mgr.get_inventory(inventory_id).get_items()
	_debug_ui_inventory.visible = items.size() > 0
	_debug_ui_inventory.build(items)


func _post_ready() -> void:
	## wire up debug bullshit
	_debug_ui_quest.setup(quest_mgr)
	_debug_dnc.setup(_day_night_cycle)
	_debug_quests.setup(quest_mgr)
	# let's just ignore the get_node call. it's trash but beyond temporary
	_debug_inventory.setup(inventory_mgr, player.id)
	inventory_mgr.get_inventory("Devin").inventory_updated.connect(
		_debug_ui_equipment.update_available.unbind(1)
	)
	player.equipment_changed.connect(_debug_ui_equipment.update_available.unbind(1))
	_debug_ui_equipment.update_available()

	if !_personal_config.autoload_level.is_empty():
		await _curtain.fade_in(1)
		print("Loading autoload level")
		load_level(_personal_config.autoload_level, LevelBase.DEFAULT_MARKER)
		await _curtain.fade_out(1)
	else:
		menus.present(Menus.MenuKind.TITLE)
		await _curtain.fade_out(1, false)


func exit_game() -> void:
	var tree := get_tree()
	tree.root.propagate_notification(NOTIFICATION_WM_CLOSE_REQUEST)
	tree.quit()


func get_hud() -> HUD:
	return _hud


func get_world_presentation() -> Node2D:
	return _presentation


func free_previous_level() -> void:
	_world.remove_child(_last_loaded_level)
	_last_loaded_level.queue_free()


## Loads a new level into the game world. Connected to SerilizationManager.gd: load_saved_level
func load_level(target_level_name: String, target_name: String) -> void:
	assert(target_level_name != "", "Level to load must not be empty")

	menus.dismiss()

	var packed_level: PackedScene
	var new_level: LevelBase

	if _last_loaded_level != null:
		if !_serialization_mgr.is_loading_game:
			# before unloading save the state of the current level into working
			# serialization cache
			_serialization_mgr.update_level(_last_loaded_level)

		free_previous_level()

	# make sure the hud is shown
	get_hud().show()

	# Load a level, either a previously saved/persisting level otherwise a new level
	print("Target Level Name: " + target_level_name)
	if _serialization_mgr.check_level_persistence(target_level_name):
		packed_level = load(_serialization_mgr.get_persistent_level_dict()[target_level_name])
		print("Loading persisting level")
	else:
		packed_level = load(Utils.level_to_path_text(target_level_name))
		print("Loading non-persisting level")

	if packed_level:
		new_level = packed_level.instantiate()
		_world.add_child(new_level, true)

		## Run any setup the level needs to do to work
		new_level.setup(self)

		if new_level.use_fixed_ambient && new_level.use_fixed_ambient != "DISABLE":
			_day_night_cycle._modulate.visible = false
		else:
			_day_night_cycle._modulate.visible = true

		# update level ref
		_last_loaded_level = new_level

		if _serialization_mgr.is_loading_game:
			_set_player_from_save()
		else:
			_set_player(new_level, target_name)
	else:
		printerr("packed level is null")


## Setup the player in the recently loaded level
func _set_player(new_level: LevelBase, marker_name: String) -> void:
	# TODO: get the player ready and move them to the appropriate location
	# we'll probably want to parameterize this more eventually.
	player.visible = true
	if marker_name == null || marker_name == "":
		marker_name = LevelBase.DEFAULT_MARKER
	var location := new_level.get_named_location(marker_name)
	player.global_position = location


func _set_player_from_save() -> void:
	# TODO: get the player ready and move them to the appropriate location
	# we'll probably want to parameterize this more eventually.
	player.visible = true


## Returns the currently loaded level. A bit of a hack for routing things into
## Quest effect chain.
func get_current_level() -> LevelBase:
	return _last_loaded_level


func pause(should_pause: bool = true) -> void:
	get_tree().paused = should_pause


## TODO: We'll need to switch away  from debug load path soon
func request_debug_load(level_name: String) -> void:
	audio_mgr.send_event(AK.EVENTS.LEVELSTART)
	await _curtain.fade_in(1, false)
	load_level(level_name, LevelBase.DEFAULT_MARKER)
	await _curtain.fade_out(1, false)


func _on_debug_pressed() -> void:
	quest_mgr.debug_print()
