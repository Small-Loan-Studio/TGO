class_name Quest
extends Resource

signal state_change(id: String, old_state: Enums.QuestState, new_state: Enums.QuestState)

@export var id: String
@export var title: String
@export var description: String

@export var manual_start: bool = false
@export var state: Enums.QuestState
@export var conditions: Array[QuestCondition]

@export_category("Quest line structure")
@export var phases: Array[QuestPhase]
@export var next: Array[Quest]
@export var results: Array[Effect]

var _mgr: QuestManager

# Set during Quest linking if this quest is directly part of a phased parent
var _phase_parent: Quest

# Set during Quest linking if this quest is a child of some other Quest
var _parent: Array[Quest]


## If this quest is part of a phased quest either directly or indirectly via
## parent/child relationship return the containing quest.
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
## the first parent to be the path to follow. Plausible we want to lint this
## into a warning when setting up quest structure.
##
## TODO: lmao. tests
func get_phase_parent() -> Quest:
	if _phase_parent != null:
		return _phase_parent

	if len(_parent) == 0:
		return null

	var cur := _parent[0]
	while true:
		if cur._phase_parent != null:
			return cur._phase_parent
		if len(cur._parent) == 0:
			return null
		cur = cur._parent[0]

	return null


func abs_title() -> String:
	var full_title := title
	var cur := get_phase_parent()
	while cur != null:
		full_title = "%s/%s" % [cur.title, full_title]
		cur = cur.get_phase_parent()
	return full_title


# yes, this has a lot of returns but I believe it is actually easier to read
# than a more clever version that reduces the number or breaks the evaluation
# into multiple functions
#gdlint: disable=max-returns


## Triggers an evaluation as to whether a quest should be moved from active to
## a finished state. If a quest is not active no work is done, an error is printed,
## and false is returned.
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

	for c: QuestCondition in conditions:
		if !c.eval():
			return false

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
					if !q.may_fail:
						return self.mark_failed()
				Enums.QuestState.COMPLETED:
					if !_chain_completed(q):
						return false
				_:
					printerr("Unknown quest state for '%s': %s" % [id, q.state])

	return self.mark_completed()


#gdlint: enable=max-returns


## returns whether or not a quest and all children have been marked as completed
func _chain_completed(q: Quest) -> bool:
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
		e.act(id, Driver.instance().get_current_level())

	state_change.emit(id, old_state, state)
	return true


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
