class_name Menus
extends Control

enum MenuKind { PAUSE, TITLE }

const PauseMenuScene: PackedScene = preload("res://Scenes/Menu/pause_menu.tscn")
const TitleMenuScene: PackedScene = preload("res://Scenes/Menu/title_menu.tscn")

var _menus: Array[Menu] = []

## Public


func dismiss() -> void:
	_menus.reverse()
	for menu: Menu in _menus:
		menu.queue_free()
	_menus = []
	hide()


## presents a menu and returns immediately; see `present_async` for a version
## that awaits on a menu dismissal
func present(kind: MenuKind) -> Menu:
	show()
	var menu: Menu = null
	match kind:
		MenuKind.PAUSE:
			menu = PauseMenuScene.instantiate()
		MenuKind.TITLE:
			menu = TitleMenuScene.instantiate()
	self._present(menu)
	return menu


## presents a menu and awaits for the menu to emit .dismiss
func present_async(kind: MenuKind) -> void:
	await present(kind).dismiss


## Private


func _dismiss() -> void:
	var active: Menu = _menus.pop_back()
	if active:
		active.queue_free()
		active = null

	if !_menus.is_empty():
		active = _menus.back()
		if active:
			active.visible = true


func _present(menu: Menu) -> void:
	if !_menus.is_empty():
		var active: Menu = _menus.back()
		if active:
			active.visible = false
	menu.dismiss.connect(_dismiss)
	menu.present.connect(_present)
	_menus.push_back(menu)
	self.add_child(menu)
