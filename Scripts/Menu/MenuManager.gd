class_name MenuManager
extends Control

@onready var _debug_menu := $DebugMenu

func _ready() -> void:
	for c in get_children():
		c.visible = false

func _get_menu(typ: Enums.MenuType) -> Node2D:
	match typ:
		Enums.MenuType.DEBUG:
			return _debug_menu
		Enums.MenuType.NONE:
			printerr('Requesting NONE menu, this is likely a mistake')
			return null
		_:
			assert(false, "Bad menu type provided: " + str(typ))
	return null

func hide_menu(menu_type: Enums.MenuType) -> void:
	var menu := _get_menu(menu_type)
	menu.visible = false

func show_menu(menu_type: Enums.MenuType) -> void:
	var menu := _get_menu(menu_type)
	menu.visible = true