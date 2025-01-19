extends CharacterState

@export var idle_state: State

var _menu_type: Enums.MenuType

func enter(_ctx: Variant) -> void:
  _menu_type = _ctx["menu"]
  Driver.instance()._menu_mgr.show_menu(_menu_type)


func run_input(_event: InputEvent) -> void:
  if _event is InputEventJoypadButton:
    print("Menu.run_input(%s)" % [_event])

  var just_pressed := _ctx.controller.get_just_pressed()
  print("    ", just_pressed)

  if _ctx.controller.just_pressed(Enums.InputAction.MENU):
    _state_machine.queue_state_change(idle_state)


func exit() -> void:
  Driver.instance()._menu_mgr.hide_menu(_menu_type)


static func mk_args(which_menu: Enums.MenuType) -> Variant:
  return { "menu": which_menu }