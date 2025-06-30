@tool
class_name NPC
extends Character

## Contains NPC specification, only used during _ready call to bootstrop
## NPC data.
@export var config: NPCConfig

## This is the conversation event that will be triggered when the NPC
## is spoken with. If null at _ready no conversation will be set up.
@export var dlg: DialogueEffect

@onready var _talk_sensor: Interactable = $TalkSensor


func _ready() -> void:
	super._ready()

	if Engine.is_editor_hint():
		return

	if dlg != null:
		_talk_sensor.action_map[Enums.ActionVerb.TALK] = [dlg]

	if _has_effect(config.examine_effects):
		_talk_sensor.action_map[Enums.ActionVerb.EXAMINE] = config.examine_effects
	elif config.examine_text != "":
		_talk_sensor.action_map[Enums.ActionVerb.EXAMINE] = [
			ExamineEffect.mk_effect(config.examine_text)
		]

	if _has_effect(config.give_item_effects):
		_talk_sensor.action_map[Enums.ActionVerb.GIVE_ITEM] = [
			SelectItemEffect.mk_effect(config.give_item_effects)]

	if _has_effect(config.show_item_effects):
		_talk_sensor.action_map[Enums.ActionVerb.SHOW_ITEM] = [
			SelectItemEffect.mk_effect(config.show_item_effects)]

	_talk_sensor.default_verb = Enums.ActionVerb.TALK

	_talk_sensor.secondary_action_order = [
		Enums.ActionVerb.TALK,
		Enums.ActionVerb.EXAMINE,
		Enums.ActionVerb.SHOW_ITEM,
		Enums.ActionVerb.GIVE_ITEM,
	]

	if config != null:
		id = config.character_id
		_sprite.sprite_frames = config.sprite_sheet
	else:
		printerr("NPC %s does not have an associated config" % [name])


func _has_effect(arr: Array[Effect]) -> bool:
	return arr != null && arr.size() > 0
