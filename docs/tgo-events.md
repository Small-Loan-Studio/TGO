# TGO Events System

- [TGO Events System](#tgo-events-system)
  - [Introduction](#introduction)
  - [Core Concepts](#core-concepts)
    - [Effects](#effects)
      - [Actor ID](#actor-id)
      - [Branching Effects](#branching-effects)
      - [Special Case: SignalToEffect](#special-case-signaltoeffect)
      - [Special Case: completion callbacks](#special-case-completion-callbacks)
    - [Trigger Conditions](#trigger-conditions)
      - [Evaluation ID](#evaluation-id)
  - [Available Effects](#available-effects)
    - [Inventory Effects](#inventory-effects)
      - [Add Item to an Inventory](#add-item-to-an-inventory)
      - [Remove Item from an Inventory](#remove-item-from-an-inventory)
      - [Update Character's gear](#update-characters-gear)
      - [Picking an item up](#picking-an-item-up)
      - [Select an item](#select-an-item)
    - [Set Quest State](#set-quest-state)
    - [Time Effects](#time-effects)
    - [Conditonally perform some effect](#conditonally-perform-some-effect)
    - [Audio](#audio)
      - [Triggering an event](#triggering-an-event)
    - [Starting a Dialogue](#starting-a-dialogue)
    - [Setting a variable](#setting-a-variable)
    - [Player Movement](#player-movement)
      - [Moving around a level](#moving-around-a-level)
      - [Loading a new level](#loading-a-new-level)
    - [Misc / Utility](#misc--utility)
      - [Adding a debug printout](#adding-a-debug-printout)
      - [Overriding the actor id](#overriding-the-actor-id)
    - [Controlling regions](#controlling-regions)
      - [Changing door state](#changing-door-state)
      - [Generic region changes](#generic-region-changes)
  - [Available Conditions](#available-conditions)
    - [Logical Conditions](#logical-conditions)
      - [Logical AND](#logical-and)
      - [Logical OR](#logical-or)
      - [LogicalNOT](#logicalnot)
      - [True](#true)
      - [False](#false)
    - [Check an Inventory state](#check-an-inventory-state)
      - [Check equipped items](#check-equipped-items)
    - [Check the state of a quest](#check-the-state-of-a-quest)
    - [World state check](#world-state-check)
    - [Time Conditions](#time-conditions)

## Introduction

The TGO Events System provides a way for designers to create complex
interactive behaviors without writing code. It uses a combination of Effects
(actions that can be taken) and Trigger Conditions (checks that determine if
an effect should run) to create a (somewhat) reactive world.

## Core Concepts

### Effects

Effects are the building blocks of interactive behaviors in TGO. Each effect
represents a single action that can be taken, such as:
- Adding or removing items from inventories
- Starting, completing, or failing quests
- Moving the player
- etc

In most cases effects can be chained together to create complex sequences of
actions. Some effects expose branching paths for success and failure cases
and there are generic Effects allowing you to create branching behaviors if
necessary.

#### Actor ID

The `actor_id` represents the entity that triggered the effect. When an effect is executed, this ID identifies which character, quest, or game object initiated the action.

**Key Usage Patterns:**
- Effects use this ID to find the triggering entity in the game world
- Many effects default to modifying the actor's inventory unless overridden
- Movement effects like `TeleportEffect` move the triggering actor
- Equipment effects modify the triggering actor's gear

**Examples:**
- When a player interacts with a switch, the player's ID becomes the `actor_id`
- When a quest triggers an effect, the quest ID becomes the `actor_id`
- Effects like `InventoryAddItemEffect` add items to the actor's inventory by default

#### Branching Effects

When an effect is something that can fail--e.g. adding or removing inventory 
tems--there are hooks for effects to hang off each outcome:

1. **Success Chain**: Effects that run if the previous effect was successful
2. **Failure Chain**: Effects that run if the previous effect failed

This allows for creating branching behaviors based on the outcome of each effect.

For Effects that should branch based on world state _before_ acting you can
construct simple tests using the logical effect set.

#### Special Case: SignalToEffect
If a node has a signal that you would like to chain effects to you can attach a
`SignalToEffect` node to make that conversion. It has a single zero-parameter
function called `trigger` that will run the effects with a configured ID. The
"parent" for the effect will be the parent node of `SignalToEffect` and then
current level will be the currently loaded level.

#### Special Case: completion callbacks
> Only interesting as Effect authors. If you are only _using_ effects this
> doesn't impact you at all.

As a special Effects that are invoked by switch **activation** can return
a non-null context to receive a callback when the switch is **deactivated**.
This is currently only utilized by `AudioEventEffect` where we occasionally
need to maintain a reference to the event that was created to issue a stop
event.

### Trigger Conditions

Trigger Conditions are checks that determine whether an effect should run. They
can check things like:

- Whether an inventory has specific items
- The state of quests
- Equipped items
- etc

Multiple conditions can be combined - all conditions must be true for the effect
to trigger. In this way an `Array[TriggerCondition]` is implicitly a logical
AND operation.

Typically triggers reside not on the effect itself but on the node that
exposes an effect chain, e.g., a switch has an activation trigger and, when
activated, has a series of effects that will run.

An exception to this is the `ConditionalEffect` which we will discuss later.

#### Evaluation ID

The `actor_id` (referred to as "evaluation ID" in this context) represents
the entity for which the condition is being evaluated. This determines which
entity's state should be checked when the condition runs.

**Key Usage Patterns:**
- Conditions use this ID to check the specific entity's state
- Many conditions have override fields but default to using the `actor_id`
- Inventory and equipment conditions check the actor's possessions
- Quest conditions typically don't use this ID since quests are global

**Examples:**
- `InventoryCheckCondition` checks if the actor has certain items (unless `inventory_id` is overridden)
- `EquipmentCondition` verifies what the actor character has equipped
- When a player triggers an interaction, conditions evaluate against the player's state

## Available Effects

### Inventory Effects

#### Add Item to an Inventory
> `InventoryAddItemEffect`
Adds items to a specific inventory.

**Properties:**
- `item`: What item to add
- `add_quantity`: How many to add (default: 1)
- `inventory_override`: Override which inventory to add to; if not set uses the
  id of the triggering actor

**Success Chain:** Effects to run if the item was successfully added
**Failure Chain:** Effects to run if the item could not be added (e.g., inventory full)

#### Remove Item from an Inventory
> `InventoryRemoveItemEffect`

Removes items from a specific inventory.

**Properties:**
- `item`: What item to remove
- `remove_quantity`: How many to remove (default: 1)
- `inventory_override`: Override which inventory to add to; if not set uses the
  id of the triggering actor

**Success Chain:** Effects to run if the item was successfully removed
**Failure Chain:** Effects to run if the item could not be removed (e.g., not enough items)

#### Update Character's gear
> `UpdateEquipmentEffect`

Equips or unequips items for characters.

**Properties:**
- `slot`: Equipment slot - "left", "right", or "any" (default: "any")
- `unequip_previous`: Whether to unequip existing items (default: true)
- `item`: Item to equip/unequip
- `action`: Action to take - "equip" or "unequip" (default: "equip")

**Success Chain:** Effects to run if the equipment change was successful
**Failure Chain:** Effects to run if the equipment change failed

When equipping an item using `slot` "any" means it will be placed into
the first viable slot discovered.

When _un_equipping from "any" if an item is set it will unequip that item
if it's equipped at all. If _no_ item is set it will unequip all items.

#### Picking an item up
> `ItemPickupEffect`

Picks up items from the world and adds them to inventory.

**NOTE**: This is really only intended to be used by the Item scene.

**Properties:**
- `dest_path`: NodePath to the item node in the world
- `item`: The ItemStack that will be added to inventory

**Does not branch**

#### Select an item
> `SelectItemEffect`
>
> :warning: Experimental

Selects an item for some additional effect chain. Right now this is an text
entry box where you must enter the item id. This ID is validated against the
list if known items but not against what's in your inventory. Eventually
we'll swap out the mechanism of selection but the behavior (`util.selected_item_id`)
should remain the same. That means Effect chains you build using this _probably_
will just continue to work. :sweat_smile:.

**Properties:**
- `with_item`: This is an effect chain that will run after an item is selected
  and placed into the Dialogic variable `Util.selected_item_id`

**Does not branch**

### Set Quest State
> `SetQuestStateEffect`

Updates the state of a specified quest.

**Properties:**
- `quest_id`: The ID of the quest to change
- `target_state`: The new state a quest should take.

**Does not branch**

The quest will be set to any `target_state` _except_ `DORMANT`.

### Time Effects

None yet

### Conditonally perform some effect
> `ConditionalEffect`

Execute an efect chain based on the result of a condition.

**Properties:**
- `condition`: Array of TriggerConditions to evaluate

**Success Chain:** Effects to run if all conditions are true
**Failure Chain:** Effects to run if any condition is false

### Audio
#### Triggering an event
> `AudioEventEffect`

Sends an Audio Event to Wwise.

**Properties:**
- `actor_id_override`: Override the effect actor ID
- `event_name`: Name of the audio event to play
- `fire_type`: "one shot" or "until exit" -- until_exit only works when used
  as part of a Switch's effect chain
- `stop_fade_time`: Fade time when stopping (for "until exit" type, only valid when run from a Switch effect chain)
- `interpolation_mode`: Interpolation mode for fade

**Does not branch**

**Object determination:** If `actor_id_override` is set, it will be used as the
actor ID. If both the effect actor ID and the override ID are empty, the system
examines the parent node and looks for an attached AudioNode. For effects run
from an Interactable context, it checks the Interactable's parent; in all other
cases it checks only the parent. If all this fails, the effect falls back to
using the AudioManager's ID.

When we fallback to AudioManager that will be fired as a one-shot event without
the interpolation mode.

### Starting a Dialogue
> `DialogueEffect`

Starts a Dialogic timeline.

**Properties:**
- `timeline`: The DialogicTimeline to start

**Does not branch**

### Setting a variable
> `SetVAREffect`

Modifies Dialogic variables.

**Properties:**
- `variable_name`: Name of the variable to modify
- `set_type`: "overwrite" or "update" the current value (default: "overwrite")
- `new_value`: Value to set (or add to the existing value)

**Does not branch**

Only variables that are ints or floats can be updated.

### Player Movement
#### Moving around a level
> `TeleportEffect`

Teleports an actor to a destination within the current level.

**Properties:**
- `dest_path`: path to the destination within the `Markers` sceen tree section.

**Does not branch**

#### Loading a new level
> `LevelLoadEffect`

Loads a new level/scene.

**Properties:**
- `load_level_name`: Path to the scene to load
- `marker_name`: Marker to use for player placement (default: empty which resolves to the "PlayerStart" location)

**Does not branch**

### Misc / Utility
#### Adding a debug printout
> `DebugEffect`

Prints debug messages to the console.

**Properties:**
- `message`: Debug message to print (default: "debug message")

**Does not branch**

#### Overriding the actor id
> `ForceEffectId`

Wraps other effects and overrides their actor ID.

**Properties:**
- `override_id`: ID to use instead of the original actor ID
- `wrapped_effects`: Array of Effects to run with the overridden ID

**Does not branch**

### Controlling regions
#### Changing door state
> `ToggleDoorEffect`

Controls door states.

**Properties:**
- `door_id`: ID of the door to control
- `door_action`: Action to take - "open", "close", or "toggle" (default: "toggle")

**Does not branch**

#### Generic region changes
> `UpdateControlledRegionEffect`

Updates controlled region visibility and passability.

**Properties:**
- `region_id`: ID of the region to update
- `passable_state`: "passable", "visible", "toggle", or "unchanged" (default: "unchanged")
- `visible_state`: "passable", "visible", "toggle", or "unchanged" (default: "unchanged")

**Does not branch**

## Available Conditions

### Logical Conditions
#### Logical AND
> `AndCondition`

Returns true only if all contained conditions are true.

**Properties:**
- `clauses`: Array of TriggerConditions that must all be true

**Note:** Returns true for empty arrays

#### Logical OR
> `OrCondition`

Returns true if any contained condition is true.

**Properties:**
- `clauses`: Array of TriggerConditions where at least one must be true

**Note:** Returns true for empty arrays

#### LogicalNOT
> `InvertCondition`

Returns the opposite of the wrapped condition's result.

**Properties:**
- `condition`: The TriggerCondition to invert

#### True
> `TrueCondition`

Always returns true. Useful for testing or as a placeholder condition.

**Properties:** None

#### False
> `FalseCondition`

Always returns false. Useful for testing or as a placeholder condition.

**Properties:** None

### Check an Inventory state
> `InventoryCheckCondition`

Checks inventory for item existence or specific quantities.

**Properties:**
- `inventory_id`: Which inventory to check (defaults to actor's inventory if empty)
- `target_item`: Item to check for
- `check_type`: Type of check operation (default: EXISTS)
- `check_value`: Quantity value for non-EXISTS checks

**Note**: To check if an inventory _does not_ contain an item you would use `check_type:LT` and `check_value:1`.

#### Check equipped items
> `EquipmentCondition`

Checks if a specific item is equipped or unequipped in specified slots.

**Properties:**
- `check_item`: The item to check for
- `check_type`: "equipped" or "unequipped" (default: "equipped")
- `slot_requirement`: "left", "right", or "any" (default: "any")

### Check the state of a quest
> `QuestStateCondition`
Checks the state of a quest.

**Properties:**
- `quest_id`: The ID of the quest to check
- `state`: The state to check for (one of: "not_started", "in_progress", "completed", "failed")

### World state check
> `DialogicVARCondition`

Checks Dialogic variables with support for different data types.

**Properties:**
- `variable_name`: Name of the Dialogic variable to check
- `check_type`: Type of comparison operation (default: EQ)
- `check_value`: Value to compare against

**Supports:** INT, FLOAT, BOOL, and STRING types. Special handling for EXISTS check which returns true if the variable is defined at all regardless of value.

### Time Conditions
None implemented yet