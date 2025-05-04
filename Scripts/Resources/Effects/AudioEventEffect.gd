@tool
class_name AudioEventEffect
extends Effect

var event_name: String
var fire_type: String = "one shot":
	set(v):
		fire_type = v
		property_list_changed.emit()
var stop_fade_time: int
var interpolation_mode: int = 4


func act(actor_id: String, cur_level: LevelBase) -> Variant:
	var actor := _find_actor(actor_id, cur_level)
	if actor == null:
		return null

	if !AK.EVENTS._dict.has(event_name):
		printerr("AudioEvent - attempting to send invalid event %s.%s" % [actor_id, event_name])
		return null

	var cfg := AudioNode.EventConfig.new()
	cfg.event_name = event_name
	cfg.one_shot = fire_type == "one shot"
	cfg.interp_mode = interpolation_mode
	cfg.stop_fade_time = stop_fade_time
	cfg.playing_id = actor.post_event(cfg)

	if !cfg.one_shot:
		return func() -> void: actor.stop_event(cfg)
	return null


func terminal_callback(ctx: Variant) -> void:
	(ctx as Callable).call()


func _find_actor(id: String, _cur_level: LevelBase) -> AudioNode:
	for node: AudioNode in _cur_level.get_tree().get_nodes_in_group(Utils.GroupNames.AudioNodes):
		if node.id == id:
			return node
	return null


func _get_property_list() -> Array[Dictionary]:
	var event_names := AK.EVENTS._dict.keys()
	event_names.sort()
	var event_names_csv := ",".join(event_names)
	var props: Array[Dictionary] = [
		{
			"name": "event_name",
			"type": TYPE_STRING,
			"hint": PROPERTY_HINT_ENUM,
			"hint_string": event_names_csv,
			"usage": PROPERTY_USAGE_DEFAULT,
		},
		{
			"name": "fire_type",
			"type": TYPE_STRING,
			"hint": PROPERTY_HINT_ENUM,
			"hint_string": "one shot,until exit",
			"usage": PROPERTY_USAGE_DEFAULT,
		},
	]
	if fire_type == "until exit":
		var modes_csv := ",".join(
			[
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
				"CONSTANT"
			]
		)
		(
			props
			. push_back(
				{
					"name": "interpolation_mode",
					"type": TYPE_INT,
					"hint": PROPERTY_HINT_ENUM,
					"hint_string": modes_csv,
					"usage": PROPERTY_USAGE_DEFAULT,
				}
			)
		)
		(
			props
			. push_back(
				{
					"name": "stop_fade_time",
					"type": TYPE_INT,
					"usage": PROPERTY_USAGE_DEFAULT,
				}
			)
		)
	return props
