extends Control

var _akh: AKHelper

@onready var _event_opt: OptionButton = $VBoxContainer/HBoxContainer2/Event
@onready var _rtpc_opt: OptionButton = $VBoxContainer/HBoxContainer/RTPC
@onready var _rtpc_val: TextEdit = $VBoxContainer/HBoxContainer/Value


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Wwise.register_game_obj(self, "debug panel")
	_akh = AKHelper.new(self)
	for k: String in AK.EVENTS._dict:
		_event_opt.add_item(k)
	for k: String in AK.GAME_PARAMETERS._dict:
		_rtpc_opt.add_item(k)


func _fire_event() -> void:
	var idx: int = _event_opt.selected
	if idx == -1:
		return
	var name: String = _event_opt.get_item_text(idx)
	_akh.send_event(AK.EVENTS._dict[name])


func _send_rtpc() -> void:
	var idx: int = _rtpc_opt.selected
	if idx == -1:
		return
	var name: String = _rtpc_opt.get_item_text(idx)
	var value: float = _rtpc_val.text as float
	_akh.global_send_param(AK.GAME_PARAMETERS._dict[name], value)
