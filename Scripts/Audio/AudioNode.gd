class_name AudioNode
extends Node2D

@export var track_position: bool
@export var debug_wise_comms: bool

var id: String

var _registered: bool
var _target: Node2D
var _last_reported_pos: Transform2D


func _exit_tree() -> void:
	if _registered:
		if Wwise.unregister_game_obj(_target):
			printerr("Failed to unregister %s" % [id])
		remove_from_group(Utils.GroupNames.AudioNodes)


func setup(node: Node2D, incoming_id: String) -> void:
	_target = node
	id = incoming_id
	_registered = Wwise.register_game_obj(node, id)
	if _registered:
		add_to_group(Utils.GroupNames.AudioNodes, true)
	else:
		printerr("Failed to register %s" % [id])


func _process(_delta: float) -> void:
	if track_position:
		if _last_reported_pos != _target.transform:
			# if debug_wise_comms:
			# 	print("[Wwise] %s.position -> %s" % [id, _target.transform])
			Wwise.set_2d_position(_target, _target.transform, 0)


func post_event(cfg: EventConfig) -> int:
	if !AK.EVENTS._dict.has(cfg.event_name):
		printerr(
			(
				"[Wwise] Attempting to post unknown event %s: %s"
				% [cfg.event_name, JSON.stringify(cfg)]
			)
		)
		return -1

	var fire_type := "one shot"
	if !cfg.one_shot:
		fire_type = "until exit"
	print("[Wwise] -> %s.post_event %s (%s)" % [_target.name, cfg.event_name, fire_type])
	return Wwise.post_event(cfg.event_name, _target)


func stop_event(cfg: EventConfig) -> void:  #akevent: AkEvent2D) -> void:
	print("[Wwise] %s.stop_event %s" % [_target.name, cfg.event_name])
	Wwise.stop_event(cfg.playing_id, cfg.stop_fade_time, cfg.interp_mode)


class EventConfig:
	extends RefCounted

	var event_name: String
	var stop_fade_time: int
	var interp_mode: int
	var one_shot: bool = true
	var playing_id: int = -1
