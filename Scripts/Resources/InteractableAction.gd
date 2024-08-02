## Base class that can be extended to make easily configurable actions
## interactable objects. See [InteractableTeleport] for an example of its
## usage.
class_name InteractableAction
extends Resource

## Stores the parent that this action is attached to. Can be used to resolve
## relative node paths and the like.
var parent: Node2D


func act(_actor: Character) -> void:
	pass
