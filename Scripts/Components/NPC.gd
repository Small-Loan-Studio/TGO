class_name NPC
extends Character

## This is the dialog timeline that gets triggered when the player speaks
## with this this NPC.
@export var dlg: InteractableDialogue = null

@onready var _interactable := $Interactable


func _ready() -> void:
	if dlg != null:
		_interactable.actions.append(dlg)