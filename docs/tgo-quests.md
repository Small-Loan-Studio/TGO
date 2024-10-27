# Quest Systems

## Structure

### General
- QuestManager hangs off Driver, e.g. InventoryMgr peer
- Quests are identified by ID and are nodes on a quest graph
  - A quest may have one or more parent
  - A quest may have one or more children
	- A quest may have a series of steps necessary to complete it; each of those
		steps are themselves a quest (wrapped in a QuestPhase to capture data)
- emits signals for state_change(quest_id, change_type)
- has a quest_by_id to get access to specific quest data
- Generally speaking the quest infrastructure should automatically watch state
	changes and be able to evaluate quest success state progressing from active
	to completed if the appropriate conditions are met.  
	At this point we do not have an auto monitoring  goal to progress to a failed
	state and that must be driven externally. An exception is made that a phased
	quest can mark itself as failed if one of the phases fails without being marked
	as may_fail

### Quest

A Quest is a node on a quest graph. It knows how to evaluate itself (via
conditions) and can be in one of a few states {dormant, active, completed,
failed}.

A quest should not* be set to active unless all its parents are completed.
When a quest is marked completed all next Quests will automatically be set as
active _unless_ the next quest has manual_start attribute set

> \* I'll probably let this work but print an error or something, TBD

Quests that have multiple phases will:
	- by default, only set the first non-completed as active
	- may not be marked as completed unless all phases are completed|failed
		- quests that are not required to pass can set 

- id
- title
- description
- state
- phases: QuestPhase[]
- manual_start: bool // this may become an arbitrary kv metadata field
- conditions: QuestCondition[]
- results: Effect[]
- next: Quest[]
- parent: Quest[]

#### QuestPhase
A phase of a quest -- allows the the containing quest to indicate if it can
be completed in the event that this quest fails. Wraps the containing quest.

- may_fail
- Quest

#### QuestCondition
A condition that must be met for a quest to succeed. A quest with no conditions
may only be marked as completed manually.

- condition_type
  - DialogicVar
  - InventoryState
- condition type specific config

Initially we'll probably manually define quest conditions instead of trying to
support all possible TriggerConditions for simplicity

#### Quests and effects
When triggering an effect the id passed will be the id of the quest itself.
If you want to trigger action for a specific character you should pin the ID
via "PinnedIdEffect" (which hasn't been written yet).