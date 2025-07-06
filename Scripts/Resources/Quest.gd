## A quest is a collection of data describing something we want the user to do
## captured in the title & description. It is then paired with conditional checks
## that we use to programmatically determine when it is finished -- these are
## optional as a quest can be managed directly if they are omitted. After those
## conditions are met some results can be triggred to impact the world and
## our management system can use the phase/next attributes to determine what
## new quests become available.
##
## A quest with phases is basically a structural quest that acts as a parent
## for a series of sub-quests. It may not finish unless all phases are also
## finished.
##
## A quest that has a next quest is sequential in nature and the next quest
## will trigger once the current quest is completed.
##
## TODO: In a rational environment this is a prototype and we can reframe the
## phase/next breakdown as all next linkages and either let a Quest specify a
## custom progression strategy or something. Walking the tree was non-trivial
## but has been shown to be workable for now so not going to touch it.
@tool
class_name Quest
extends Resource

signal state_change(id: String, old_state: Enums.QuestState, new_state: Enums.QuestState)

## How the quest is tracked in our internal systems. Should be unique among all quests
@export var id: String

## A short version of this quest for the user's HUD or similar
@export var title: String

## A longer description of what the goals of this quest are.
@export var description: String

## If set when this quest is part of a next array it will not automatically
## transition to active when its parent is marked Completed
@export var manual_start: bool = false

## What state is the quest in -- Dormant is untracked, Active is currently in
## progress, and Completed|Failed respresent a finish state
@export var state: Enums.QuestState

## The set of conditions that will be checked to see if the quest is completed
@export var conditions: Array[QuestCondition]

## If set this quest requires being externally set to completed. This is primarily
## going to be used when a Quost has no conditions or it's hard to model success
## state as a condition and we just want to manage it through some other means.
@export var manual_completion: bool = false

@export_category("Quest line structure")
## A quest with phases acts as a kind of "parent" of its phase quests. When
## this quest is marked active the first phase is automatically set to active
## and each time a phase is completed the next one will be marked active. A
## quest may not be finished unless all phases are completed or until one has
## failed.
@export var phases: Array[QuestPhase]

## When this quest is Completed all the next quests will be marked as active
## (unless manual_start is set)
@export var next: Array[Quest]

## When a quest is marked completed these results will be acted upon. The Effect
## will receive the id of the quest acting and the current level.
@export var results: Array[Effect]

# Set during Quest linking if this quest is directly part of a phased parent
var _phase_parent: Quest

# Set during Quest linking if this quest is a child of some other Quest
var _parent: Array[Quest]


## If this quest is part of a phased quest either directly or indirectly via
## parent/next relationship return the containing quest.
##
## Example:
## Given the following quest structure...
## - PhaseParent
##    - Phase1
##    - Phase2
##       - Phase2.1
##       - Phase2.2
##       - Phase2.3a -> Phase2.3b -> Phase2.3c -> Phase2.3d
##                       - Phase2.3b.i
##                       - Phase2.3b.ii
##                       - Phase2.3b.iii
##       - Phase2.4
##    - Phase3
##    - Phase4
##
## object       | result
## -------------|-------
## PhaseParent  | null
## Phase1       | PhaseParent
## Phase2       | PhaseParent
## Phase2.1     | Phase2
## Phase2.3a    | Phase2
## Phase2.3c    | Phase2
## Phase2.3b.ii | Phase2.3b
##
## ⚠️: A quest may have multiple parents, in that context we arbitrarily pick
## the first parent to be the path to follow. Probably we want to lint this
## into a warning when setting up quest structure.
##
## TODO: lmao this def needs tests
func get_phase_parent() -> Quest:
	var cur := self
	while true:
		if cur._phase_parent != null:
			return cur._phase_parent
		if len(cur._parent) == 0:
			return null
		cur = cur._parent[0]

	return null


# yes, this has a lot of returns but I believe it is actually easier to read
# than a more clever version that reduces the number or breaks the evaluation
# into multiple functions
#gdlint: disable=max-returns


## Triggers an evaluation as to whether a quest should be moved from active to
## a finished state.
##
## If a quest is not active no work is done, an error is printed, and false is
## returned.
##
## If a quest has been marked as requiring manual completion no work is done, an
## error is printed, and false is returned.
##
## For an active quest this walks the conditions and checks if they are all met.
## When phases are present it will check the completion state of all phases and
## mark the current quest as COMPLETED or FAILED as appropriate.
func evaluate() -> bool:
	if state != Enums.QuestState.ACTIVE:
		printerr(
			"Not evaluating quest %s because state is %s" % [id, Enums.quest_state_name(state)]
		)
		return false

	if manual_completion:
		printerr("Not evaluating quest %s because it's set to manual_completion" % [id])
		return false

	if !conditions_met():
		return false

	if !phases_completed(true):
		return false

	return await self.mark_completed()


#gdlint: enable=max-returns


func conditions_met() -> bool:
	for c: QuestCondition in conditions:
		if c != null && !c.eval():
			return false
	return true


## checks to see if the phases (if any) of this quest are completed; arg
## controls whether or not this will mark the current quest as failed if
## a phase that may not  fail has failed. This will default to false but
## for simplicity / to reduce code duplication you can pass that from an
## evaluation context when you want to have side effects.
func phases_completed(fail_on_phase: bool = false) -> bool:
	# if there are phases check to see if everything has completed such that we
	# should close out this quest
	for qp: QuestPhase in phases:
		if qp.quest != null:
			var q := qp.quest
			match q.state:
				Enums.QuestState.DORMANT:
					return false
				Enums.QuestState.ACTIVE:
					return false
				Enums.QuestState.FAILED:
					if fail_on_phase:
						if !qp.may_fail:
							return self.mark_failed()
					return false
				Enums.QuestState.COMPLETED:
					if !chain_completed(q):
						return false
				_:
					printerr("Unknown quest state for '%s': %s" % [id, q.state])
	return true


## returns whether or not a quest and all children have been marked as completed
func chain_completed(q: Quest) -> bool:
	var quest_list: Array[Quest] = [q]

	while len(quest_list) > 0:
		var cur := quest_list[0]
		if !cur.is_finished():
			return false
		quest_list.remove_at(0)
		for n: Quest in cur.next:
			quest_list.append(n)

	return true


## returns whether the quest state is in a "finished" state (completed or
## failed)
func is_finished() -> bool:
	return state == Enums.QuestState.COMPLETED || state == Enums.QuestState.FAILED


## Move a quest into an active state. May only be entered from a dormant
## and will emit a state change signal. Returns true if state was
## successfully updated.
##
## TODO: what should we do if this is part of a chain or phased quest and the
## parent or phase_parent isn't active?
func mark_active() -> bool:
	if state != Enums.QuestState.DORMANT:
		printerr(
			"Attempting to set quest to active from invalid state: ",
			Enums.quest_state_name(state),
		)
		return false

	state = Enums.QuestState.ACTIVE
	state_change.emit(id, Enums.QuestState.DORMANT, Enums.QuestState.ACTIVE)
	return true


## Move a quest into a failed state. May only be entered from dormant|active
## and emits a state change signal. Returns true if the state was succesfully
## updated
func mark_failed() -> bool:
	if state == Enums.QuestState.COMPLETED || state == Enums.QuestState.FAILED:
		printerr(
			"Attempting to set quest to failed from invalid state: ",
			Enums.quest_state_name(state),
		)
		return false

	var old_state := state
	state = Enums.QuestState.FAILED
	state_change.emit(id, old_state, state)
	return true


## Move a quest into a completed state. May only be entered from dormant|active
## and emits a state change signal. Returns true if the state was succesfully
## updated
func mark_completed() -> bool:
	if state == Enums.QuestState.COMPLETED || state == Enums.QuestState.FAILED:
		printerr(
			"Attempting to set quest to completed from invalid state: ",
			Enums.quest_state_name(state),
		)
		return false

	var old_state := state
	state = Enums.QuestState.COMPLETED

	for e: Effect in results:
		await e.act(id, Driver.instance().get_current_level())

	state_change.emit(id, old_state, state)
	return true


## Forces the quest into the desired; will use the normal mark_<state> path
## but will also explicitly set the state and emit the state change signal
## itself if normal guard rails prevented the change.
##
## Generally this shouldn't be called in the normal flow of gameplay and
## should be used in utility code or similar.
func set_state(new_state: Enums.QuestState) -> void:
	var success := false
	match new_state:
		Enums.QuestState.DORMANT:
			# there is no mark_dormant
			pass
		Enums.QuestState.ACTIVE:
			success = mark_active()
		Enums.QuestState.FAILED:
			success = mark_failed()
		Enums.QuestState.COMPLETED:
			success = await mark_completed()
		_:
			assert(false, "Unexpected quest state: " + Enums.quest_state_name(new_state))
	if !success:
		var old_state := state
		state = new_state
		state_change.emit(id, old_state, new_state)


func _to_string() -> String:
	var next_ids: Array = next.map(func(e: Quest) -> String: return e.id)
	var parent_ids: Array = _parent.map(func(e: Quest) -> String: return e.id)
	return (
		"%s / %s / %s\nnext: %s\nparents: %s"
		% [
			id,
			title,
			Enums.quest_state_name(state),
			next_ids,
			parent_ids,
		]
	)


## checks this quest for configuration issues, returns Array[String] of errors
func lint() -> Array[String]:
	var errs: Array[String] = []
	if id.strip_edges() == "":
		errs.append("E: Core: id is not set")
	if title.strip_edges() == "":
		errs.append("W: Core: title is empty")
	if description.strip_edges() == "":
		errs.append("W: Core: description is empty")
	if len(conditions) == 0 && len(phases) == 0 && !manual_completion:
		errs.append(
			(
				"E: No conditions or phases and Manual Completion not set. "
				+ "Quest will automatically complete when started."
			)
		)

	for i in range(phases.size()):
		var qp := phases[i]
		if qp == null:
			errs.append("W: Phase.%d: null phase" % [i])
			continue
		if qp.quest == null:
			errs.append("W: Phase.%d: phase quest is not set" % [i])
			continue

	for i in range(conditions.size()):
		var c: QuestCondition = conditions[i]
		if c == null:
			errs.append("W: Condition.%d: null condition" % [i])
			continue
		var c_lint: Array[String] = c.lint()
		for c_i in range(c_lint.size()):
			var lint_msg := c_lint[c_i]
			var parts := lint_msg.split(":", true, 1)
			errs.append("%s: Condition.%d:%s" % [parts[0], i, parts[1]])

	for i in range(results.size()):
		if results[i] == null:
			errs.append("W: Result.%d: null effect" % [i])

	return errs
