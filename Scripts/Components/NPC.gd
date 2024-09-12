@tool
class_name NPC
extends Character

## Contains NPC specification, only used during _ready call to bootstrop
## NPC data.
@export var config: NPCConfig

## This is the conversation event that will be triggered when the NPC
## is spoken with. If null at _ready no conversation will be set up.
@export var dlg: InteractableDialogue

@onready var _talk_sensor := $TalkSensor


func _ready() -> void:
	if !Engine.is_editor_hint() && dlg != null:
		_talk_sensor.actions.append(dlg)

	if config != null:
		id = config.character_id
		_sprite.sprite_frames = config.sprite_sheet
	else:
		printerr("NPC %s does not have an associated config" % [name])
