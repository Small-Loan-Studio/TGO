class_name AudioSettings
extends Menu

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

@onready var _levels_container := $VBoxContainer


func _ready() -> void:
	_active_bus = 0
	var max_width := 0
	for c in _levels_container.get_children():
		if c is AudioSlider:
			_sliders.append(c)
			if max_width < c.label_width():
				max_width = c.label_width()

	for c in _sliders:
		c.set_label_width(max_width)
		c.init(Driver.instance().audio_mgr)
		c.process_mode = Node.PROCESS_MODE_INHERIT
		c.is_active = false

	_active_bus = 0


func _exit_tree() -> void:
	Driver.instance().audio_mgr.save_levels()
	visible = false
	for c in _sliders:
		c.process_mode = Node.PROCESS_MODE_DISABLED


func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed(Enums.input_action_name(Enums.InputAction.UP)):
		_active_bus -= 1
	if Input.is_action_just_pressed(Enums.input_action_name(Enums.InputAction.DOWN)):
		_active_bus += 1


func _sync_sliders_state() -> void:
	for i in range(len(_sliders)):
		_sliders[i].is_active = i == _active_bus


func _main_drag_start() -> void:
	_active_bus = 0


func _bgm_drag_start() -> void:
	_active_bus = 1


func _sfx_drag_start() -> void:
	_active_bus = 2
