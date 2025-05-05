extends CharacterState

@export var idle_state: State

var _menu_type: Menus.MenuKind
var _waiting := false
var _done_waiting := false


func enter(ctx: Variant, _change_state: Callable) -> void:
	_menu_type = ctx["menu"]
	_waiting = false
	_done_waiting = false


func run_tick(_delta: float, change_state: Callable) -> void:
	if _waiting:
		if _done_waiting:
			change_state.call(idle_state)
		return

	_waiting = true
	_done_waiting = false
	await Driver.instance().menus.present(Menus.MenuKind.PAUSE)
	_done_waiting = true


static func mk_args(which_menu: Menus.MenuKind) -> Variant:
	return {"menu": which_menu}
