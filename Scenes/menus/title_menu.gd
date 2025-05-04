extends Menu

const LevelMenuScene: PackedScene = preload("./level_menu.tscn")
const SettingsMenuScene: PackedScene = preload("./settings_menu.tscn")

@export var start_level: String

## Private


func _on_continue_button_pressed() -> void:
	# FIXME: Level 1 should not be defined here we should probably have
	# something like `Driver.instance().continue_game()` as we should not be
	# hitting private variables.
	Driver.instance()._serialization_mgr.load_game()
	dismiss.emit()


func _on_new_game_button_pressed() -> void:
	Driver.instance().new_game()
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
