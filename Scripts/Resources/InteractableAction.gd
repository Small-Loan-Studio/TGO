## Base class that can be extended to make easily configurable actions
## interactable objects. See [InteractableTeleport] for an example of its
## usage.
class_name InteractableAction
extends Resource

## Stores the parent that this action is attached to. Can be used to resolve
## relative node paths and the like.
var parent: Node2D


## Called with the actor triggering this action and the LevelBase context in
## which this action is getting triggered.
##
## TODO: Potentially we could return some enum that lets actions control execution,
## e.g., maybe an action returns HALT or CONTINUE and we can add predicate checking
## to guard trigger actions
func act(_actor: Character, _cur_level: LevelBase) -> void:
	pass
