## Base class that can be extended to make easily configurable actions
## interactable objects. See [InteractableTeleport] for an example of its
## usage.
class_name InteractableAction
extends Resource

## Stores the parent that this action is attached to. Note that this is
## the Interactable scene. It's set by the Interactable before act is
## called.
var parent: Interactable


## Called with the actor triggering this action and the LevelBase context in
## which this action is getting triggered.
##
## TODO: Potentially we could return some enum that lets actions control execution,
## e.g., maybe an action returns HALT or CONTINUE and we can add predicate checking
## to guard trigger actions
func act(_actor: Character, _cur_level: LevelBase) -> void:
	pass
