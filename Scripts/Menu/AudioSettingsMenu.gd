class_name AudioSettings
extends Menu

@onready var _levels_container := $VBoxContainer

var _sliders: Array[AudioSlider] = []
var _active_bus := 0:
	set(v):
		if !is_node_ready():
			return
		_active_bus = v
		if _active_bus >= len(_sliders):
			_active_bus = 0
		if _active_bus < 0:
			_active_bus = len(_sliders) - 1
		_sync_sliders_state()


func open_menu() -> void:
	for c in _sliders:
		c.init(Driver.instance().audio_mgr)
	super.open_menu()


func _ready() -> void:
	var max_width := 0
	for c in _levels_container.get_children():
		if c is AudioSlider:
			_sliders.append(c)
			if max_width < c.label_width():
				max_width = c.label_width()

	for c in _sliders:
		c.set_label_width(max_width)
		c.is_active = false
	_sliders[0].is_active = true

	_active_bus = 0


## Called when an external actor wants to close the menu; should result in
## emitting menu_closed when any necessary shutdown is completed
func close_menu() -> void:
	Driver.instance()._menu_mgr.hide_menu(menu_type)
	Driver.instance().audio_mgr.save_levels()
	menu_closed.emit(false)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if !visible:
		return

	if (
		Input
		. is_action_just_pressed(
			Enums.input_action_name(Enums.InputAction.MENU),
		)
	):
		close_menu()
		return

	if Input.is_action_just_pressed(Enums.input_action_name(Enums.InputAction.UP)):
		_active_bus -= 1
	if Input.is_action_just_pressed(Enums.input_action_name(Enums.InputAction.DOWN)):
		_active_bus += 1


func _sync_sliders_state() -> void:
	for i in range(len(_sliders)):
		_sliders[i].is_active = i == _active_bus
