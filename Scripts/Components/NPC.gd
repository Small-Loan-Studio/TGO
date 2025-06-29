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

	if config.examine_effects != null && config.examine_effects.size() > 0:
		_talk_sensor.action_map[Enums.ActionVerb.EXAMINE] = config.examine_effects
	elif config.examine_text != "":
		_talk_sensor.action_map[Enums.ActionVerb.EXAMINE] = [
			ExamineEffect.mk_effect(config.examine_text)]
	
	_talk_sensor.action_map[Enums.ActionVerb.GIVE_ITEM] = [
		DebugEffect.mk_effect("give_item"),
		SelectItemEffect.mk_effect([
			DialogueEffect.mk_effect(preload("res://Dialogue/Other/test_give.dtl") as DialogicTimeline)]),
	]
	_talk_sensor.action_map[Enums.ActionVerb.SHOW_ITEM] = [
		DebugEffect.mk_effect("show_item"),
		SelectItemEffect.mk_effect([
			DialogueEffect.mk_effect(preload("res://Dialogue/Other/test_show.dtl") as DialogicTimeline)]),
	]

	_talk_sensor.default_verb = Enums.ActionVerb.TALK

	if config != null:
		id = config.character_id
		_sprite.sprite_frames = config.sprite_sheet
	else:
		printerr("NPC %s does not have an associated config" % [name])