class_name NPC
extends Character

@onready var _interactable := $Interactable


## This is the dialog timeline that gets triggered when the player speaks
## with this this NPC.
@export var dlg: InteractableDialogue = null


func _ready() -> void:
	if dlg != null:
		_interactable.actions.append(dlg)