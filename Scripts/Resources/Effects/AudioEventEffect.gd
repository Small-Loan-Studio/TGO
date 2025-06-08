@tool
class_name AudioEventEffect
extends Effect

## If set this will override the effect actor ID. If both the effect actor_id
## and the override ID are empty it examines parent and looks to see if it's
## attached to something that has an AudioNode. What it checks is a bit
## tricky... for an effect being run from an Interactable context it checks
## the Interactable's parent; in all other cases it checks only the parent.
## for the effect will check the use the AudioManager's ID. If all this fails
## the effect falls back to the AudioManager's ID.
@export var actor_id_override: String = ""

var event_name: String
var fire_type: String = "one shot":
	set(v):
		fire_type = v
		property_list_changed.emit()
var stop_fade_time: int
var interpolation_mode: int = 4


func act(actor_id: String, cur_level: LevelBase) -> Variant:
	if !AK.EVENTS._dict.has(event_name):
		printerr("AudioEvent - attempting to send invalid event %s.%s" % [actor_id, event_name])
		return null

	var use_id := actor_id
	if actor_id_override != "":
		use_id = actor_id_override
	if use_id == "":
		var check_node: Node = parent
		if check_node is Interactable:
			check_node = check_node.get_parent()
		for child in check_node.get_children():
			if child is AudioNode:
				use_id = child.id

	if use_id == "":
		# handle fallback to AudioManager case
		var am := Driver.instance().audio_mgr
		var event_id: int = AK.EVENTS._dict[event_name]
		am.send_event(event_id)
		return null

	var actor := _find_actor(use_id, cur_level)
	if actor == null:
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


func _find_actor(id: String, cur_level: LevelBase) -> AudioNode:
	if id == Utils.WwiseIds.AudioManager:
		return Driver.instance().get_audio_manager()
	return cur_level.get_audio_node(id)


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
