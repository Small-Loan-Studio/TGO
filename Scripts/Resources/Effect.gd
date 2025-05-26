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
# DECISION: We should switch to this; at the point I made this decision I
#           don't think I was considering the singleton nature of resources


## Called with the actor triggering this action and the LevelBase context in
## which this action is getting triggered.
##
## When triggered by a quest this will be called with the QuestID and the
## currently loaded level.
##
## TODO: Potentially we could return some enum that lets actions control execution,
## e.g., maybe an action returns HALT or CONTINUE and we can add predicate checking
## to guard trigger actions
func act(_actor_id: String, _cur_level: LevelBase) -> Variant:
	return null


## Will only be called for effects triggered by a Switch.
func terminal_callback(_arg: Variant) -> void:
	pass


## Provides a default implementation of running a chain of effects and
## collecting the effects + terminal callback contexts. Should be paired
## by calling _run_next_callbacks from the class that uses this in its
## terminal_callback implementation.
func _run_next(chain: Array[Effect], actor_id: String, cur_level: LevelBase) -> Variant:
	var chain_ctx: Array[Variant] = []
	for e in chain:
		e.parent = parent
		var ctx: Variant = e.act(actor_id, cur_level)
		if ctx != null:
			chain_ctx.append([e, ctx])

	if chain_ctx.size() == 0:
		return null

	return chain_ctx

## Provides a default implementation of running the terminal callbacks
## for a chain of effects. Intended to be used to handle the contexts
## constructed from _run_next.
func _run_next_callbacks(ctx: Variant) -> void:
	for ele_pair: Variant in ctx as Array[Variant]:
		var ele: Effect = ele_pair[0]
		var arg: Variant = ele_pair[1]
		ele.terminal_callback(arg)