class_name MenuManager
extends Control

@onready var _debug_menu: Control = $DebugMenu
@onready var _gameplay: Control = $InGameOverlay


func _ready() -> void:
	# TODO:....
	#   - get all children
	#   - validate menu API on each control
	#   - build enum->control map
	#   - alert on errors
	for c in get_children():
		c.visible = false


func _get_menu(typ: Enums.MenuType) -> Menu:
	match typ:
		Enums.MenuType.DEBUG:
			return _debug_menu
		Enums.MenuType.NONE:
			printerr("Requesting NONE menu, this is likely a mistake")
			return null
		Enums.MenuType.GAMEPLAY:
			return _gameplay
		_:
			assert(false, "Bad menu type provided: " + str(typ))
	return null


func hide_menu(menu_type: Enums.MenuType) -> void:
	var menu := _get_menu(menu_type)
	menu.visible = false
	if menu.should_pause:
		Driver.instance().pause(false)


func show_menu(menu_type: Enums.MenuType) -> Menu:
	var menu := _get_menu(menu_type)
	menu.open_menu()
	if menu.should_pause:
		Driver.instance().pause()
	return menu
