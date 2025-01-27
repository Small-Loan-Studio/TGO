class_name Menu
extends Control

## How should we reference this menu
@export var menu_type: Enums.MenuType

## should this menu pause the game while open
@export var should_pause := true

## fired when the menu wants to close itself, includes a bool to indicate if
## there is some result that can be retrieved. May be triggered by internal
## menu state or the eventual result of a close_menu call.
signal menu_closed(has_result: bool)

func open_menu() -> void:
    visible = true

## Called when an external actor wants to close the menu; should result in
## emitting menu_closed when any necessary shutdown is completed
func close_menu() -> void:
    pass

