class_name Menu
extends Control

## fired when the menu wants to close itself, includes a bool to indicate if
## there is some result that can be retrieved. May be triggered by internal
## menu state or the eventual result of a close_menu call.
signal menu_closed(has_result: bool)

## How should we reference this menu
@export var menu_type: Enums.MenuType

## should this menu pause the game while open
@export var should_pause := true

var _menu_mgr: MenuManager


func open_menu() -> void:
	_open_menu()


func close_menu() -> void:
	_close_menu()
	_menu_mgr.post_menu_closed(self)


func _process(_delta: float) -> void:
	if !_menu_mgr.active_menu == self:
		return
	_menu_process()


## Called when the menu is visible. First call will not occur until after
## _open_menu is complete. Last call happens before _close_menu is called.
func _menu_process() -> void:
	pass


## Called when something requests this menu get opened; at the end the
## menu should be visible and usable
func _open_menu() -> void:
	visible = true


## Called when an external actor wants to close the menu; should result in
## emitting menu_closed when any necessary shutdown is completed and leave
## the menu not visible
func _close_menu() -> void:
	visible = false
	menu_closed.emit(false)
