extends Menu

const LevelMenuScene: PackedScene = preload("./level_menu.tscn")
const SettingsMenuScene: PackedScene = preload("./settings_menu.tscn")

## Private


func _on_continue_button_pressed() -> void:
	# FIXME: Level 1 should not be defined here we should probably have
	# something like `Driver.instance().continue_game()`
	Driver.instance()._serialization_mgr.load_game()
	dismiss.emit()


func _on_new_game_button_pressed() -> void:
	# FIXME: Level 1 should not be defined here we should probably have
	# something like `Driver.instance().new_game()`
	Driver.instance().load_level("BadLevelA", "")
	dismiss.emit()


func _on_load_button_pressed() -> void:
	var submenu := LevelMenuScene.instantiate()
	present.emit(submenu)


func _on_settings_button_pressed() -> void:
	var submenu := SettingsMenuScene.instantiate()
	present.emit(submenu)


func _on_exit_button_pressed() -> void:
	Driver.instance().exit_game()


## Override


func _ready() -> void:
	var driver := Driver.instance()
	if driver._serialization_mgr._check_save_exists():
		$ButtonContainer/ContinueButton.disabled = false
