class_name MenuManager
extends Control

## Holds a reference to the currently active menu
var active_menu: Menu

## stores a map from menu type to the Menu object
var _menu_map: Dictionary = {}


func _ready() -> void:
	for c in get_children():
		c.visible = false
		if c is Menu:
			var mt: Enums.MenuType = c.menu_type
			if mt in _menu_map:
				printerr(
					(
						"Duplicate menu entry for %d. "
						+ "Previously: %s. "
						+ (
							"Found: %s. Ignoring new entry"
							% [
								mt,
								_menu_map[mt].name,
								c.name,
							]
						)
					)
				)
				continue
			print("Adding Menu: Type(%d): %s" % [mt, c.name])
			_menu_map[c.menu_type] = c
			c._menu_mgr = self


func get_menu(typ: Enums.MenuType) -> Menu:
	if typ == Enums.MenuType.NONE:
		printerr('You probably didn\'t want to get the "NONE" menu')
		return null

	if !typ in _menu_map:
		assert(false, "Bad menu type provided: " + str(typ))
	return _menu_map[typ]


func hide_menu(menu_type: Enums.MenuType) -> void:
	var menu := get_menu(menu_type)
	if menu != active_menu:
		return
	menu.close_menu()


func show_menu(menu_type: Enums.MenuType) -> Menu:
	var menu := get_menu(menu_type)
	if menu.should_pause:
		Driver.instance().pause()
	menu.open_menu()
	active_menu = menu
	return menu


func post_menu_closed(which_menu: Menu) -> void:
	active_menu = null
	if which_menu.should_pause:
		Driver.instance().pause(false)
