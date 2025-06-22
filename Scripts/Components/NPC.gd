@tool
class_name NPC
extends Character

## Contains NPC specification, only used during _ready call to bootstrop
## NPC data.
@export var config: NPCConfig

## This is the conversation event that will be triggered when the NPC
## is spoken with. If null at _ready no conversation will be set up.
@export var dlg: DialogueEffect

@onready var _talk_sensor := $TalkSensor


func _ready() -> void:
	super._ready()

	if Engine.is_editor_hint():
		return

	if dlg != null:
		_talk_sensor.action_map[Enums.ActionVerb.TALK] = [dlg]

	if config.examine_text != "":
		var examine_dlg := DialogueEffect.new()
		examine_dlg.timeline = DialogicResourceUtil.get_timeline_resource("res://Dialogue/Other/examine.dtl")

		var set_var := SetVarEffect.new()
		set_var.variable_name = "Util.examine_text"
		set_var.new_value = config.examine_text
		_talk_sensor.action_map[Enums.ActionVerb.EXAMINE] = [
			set_var,
			examine_dlg,
		]

	if config != null:
		id = config.character_id
		_sprite.sprite_frames = config.sprite_sheet
	else:
		printerr("NPC %s does not have an associated config" % [name])
