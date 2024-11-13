## Base class that can be extended to make easily configurable actions
## interactable objects. See [TeleportEffect] for an example of its
## usage.
class_name Effect
extends Resource

## Stores the parent that this action is attached to. Note that this is
## the Node and not the level itself. It must be set by the logic running
## an Effect (chain?) before act is called.
var parent: Node2D
# TODO: why aren't we passing the parent into act again? Consider moving to
#       that model instead of an invisible coupling where it gets magically set
#       by the calling code.


## Called with the actor triggering this action and the LevelBase context in
## which this action is getting triggered.
##
## When triggered by a quest this will be called with the QuestID and the
## currently loaded level.
##
## TODO: Potentially we could return some enum that lets actions control execution,
## e.g., maybe an action returns HALT or CONTINUE and we can add predicate checking
## to guard trigger actions
func act(_actor_id: String, _cur_level: LevelBase) -> void:
	pass
