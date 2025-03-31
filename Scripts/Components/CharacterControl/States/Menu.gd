extends CharacterState

@export var idle_state: State

var _menu_type: Enums.MenuType
var _shown_menu: Control
var _waiting := false
var _done_waiting := false


func enter(_ctx: Variant, _change_state: Callable) -> void:
	_menu_type = _ctx["menu"]
	_waiting = false
	_done_waiting = false


func run_tick(_delta: float, change_state: Callable) -> void:
	if _waiting:
		if _done_waiting:
			change_state.call(idle_state)
		return

	_waiting = true
	_done_waiting = false
	_shown_menu = Driver.instance()._menu_mgr.show_menu(_menu_type)

	await _shown_menu.menu_closed
	_done_waiting = true


static func mk_args(which_menu: Enums.MenuType) -> Variant:
	return {"menu": which_menu}
