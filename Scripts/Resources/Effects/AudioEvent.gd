class_name AudioEvent
extends Effect

@export var event_name: String
@export_enum("single fire", "until exit") var fire_type: String
@export var stop_fade_time: int
@export_enum(
	"LOG3",
	"SINE",
	"LOG1",
	"INVSCURVE",
	"LINEAR",
	"SCURVE",
	"EXP1",
	"SINERECIP",
	"EXP3",
	"LASTFADECURVE",
	"CONSTANT") var interpolation_mode: int


func act(actor_id: String, cur_level: LevelBase) -> Variant:
	var actor := _find_actor(actor_id, cur_level)
	if actor == null:
		return null

	if !AK.EVENTS._dict.has(event_name):
		printerr("AudioEvent - attempting to send invalid event %s.%s" % [actor_id, event_name])
		return null

	var cfg := AudioNode.EventConfig.new()
	cfg.event_name = event_name
	cfg.one_shot = fire_type == "single_fire"
	cfg.interp_mode = interpolation_mode
	cfg.stop_fade_time = stop_fade_time
	var event_node := actor.post_event(cfg)

	if !cfg.one_shot:
		return func() -> void:
			actor.stop_event(event_node)
	return null


func _find_actor(id: String, _cur_level: LevelBase) -> AudioNode:
	for node: AudioNode in _cur_level.get_tree().get_nodes_in_group(Utils.GroupNames.AudioNodes):
		if node.id == id:
			return node
	return null

func _get_property_list() -> Array[Dictionary]:
	return [{
		"name": "event_name",
		"type": ,
		
	}]