@tool
class_name NPC
extends Character

const SCENE_RES = preload("res://Scenes/Components/NPC.tscn")

## This is the dialog timeline that gets triggered when the player speaks
## with this this NPC.
# @export var dlg: InteractableDialogue = null

@onready var _talk_sensor := $TalkSensor

@export var config: NPCConfig
@export var dlg: InteractableDialogue


func _ready() -> void:
	if !Engine.is_editor_hint() && dlg != null:
		_talk_sensor.actions.append(dlg)

	if config != null:
		id = config.character_id
		_sprite.sprite_frames = config.sprite_sheet
	else:
		printerr("NPC %s does not have an associated config" % [name])