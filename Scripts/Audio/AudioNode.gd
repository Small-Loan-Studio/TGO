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


func setup(node: Node2D, id: String) -> void:
	_target = node
	id = id
	_registered = Wwise.register_game_obj(node, "C-" + id)
	if _registered:
		add_to_group(Utils.GroupNames.AudioNodes)
	else:
		printerr("Failed to register %s"  %[id])


func _process(_delta: float) -> void:
	if track_position:
		if _last_reported_pos != _target.transform:
			if debug_wise_comms:
				print("[Wwise] %s.position -> %s" % [id, _target.transform])
			Wwise.set_2d_position(_target, _target.transform, 0)


func post_event(cfg: EventConfig) -> AkEvent2D:
	if !AK.EVENTS._dict.has(name):
		printerr("[Wwise] Attempting to post unknown event %s" % [name])
		return

	var akn := AkEvent2D.new()
	akn.event = {
		"id": AK.EVENTS._dict[name],
		"name": name,
	}
	add_child(akn)
	return akn

func stop_event(akevent: AkEvent2D) -> void:
	printerr("[Wwise] Attempting to stop event")
	remove_child(akevent)
	akevent.queue_free()

class EventConfig:
	extends RefCounted

	var event_name: String
	var stop_fade_time: int
	var interp_mode: int
	var one_shot: bool = false