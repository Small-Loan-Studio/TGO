# TGO Events System

- [TGO Events System](#tgo-events-system)
  - [Introduction](#introduction)
  - [Core Concepts](#core-concepts)
    - [Effects](#effects)
      - [Special Case: completion callbacks](#special-case-completion-callbacks)
    - [Trigger Conditions](#trigger-conditions)
    - [Branching Effects](#branching-effects)
  - [Available Effects](#available-effects)
    - [Inventory Effects](#inventory-effects)
      - [Add Item to an Inventory](#add-item-to-an-inventory)
      - [Remove Item from an Inventory](#remove-item-from-an-inventory)
      - [Update Character's gear](#update-characters-gear)
    - [Set Quest State](#set-quest-state)
    - [Time Effects](#time-effects)
  - [Logical Operations](#logical-operations)
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
    - [Picking an item up](#picking-an-item-up)
  - [Controlling regions](#controlling-regions)
    - [Changing door state](#changing-door-state)
    - [Generic region changes](#generic-region-changes)
  - [Available Conditions](#available-conditions)
    - [Logical Conditions](#logical-conditions)
      - [Logical AND](#logical-and)
      - [Logical OR](#logical-or)
      - [True](#true)
      - [False](#false)
      - [Not](#not)
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

### Branching Effects

When an effect is something that can fail--e.g. adding or removing inventory 
tems--there are hooks for effects to hang off each outcome:

1. **Success Chain**: Effects that run if the previous effect was successful
2. **Failure Chain**: Effects that run if the previous effect failed

This allows for creating branching behaviors based on the outcome of each effect.

For Effects that should branch based on world state _before_ acting you can
construct simple tests using the logical effect set.

## Available Effects

### Inventory Effects

#### Add Item to an Inventory
> `InventoryAddItemEffect`
Adds items to a specific inventory.

**Properties:**
- `inventory_id`: The ID of the inventory to add to
- `item_id`: The ID of the item to add
- `count`: (Optional) Number of items to add (default: 1)

**Success Chain:** Effects to run if the item was successfully added
**Failure Chain:** Effects to run if the item could not be added (e.g., inventory full)

#### Remove Item from an Inventory
> `InventoryRemoveItemEffect`

Removes items from a specific inventory.

**Properties:**
- `inventory_id`: The ID of the inventory to remove from
- `item_id`: The ID of the item to remove
- `count`: (Optional) Number of items to remove (default: 1)

**Success Chain:** Effects to run if the item was successfully removed
**Failure Chain:** Effects to run if the item could not be removed (e.g., not enough items)

#### Update Character's gear
> `UpdateEquipmentEffect`
// TODO

### Set Quest State
> `SetQuestStateEffect`

Updates the state of a specified quest.

**Properties:**
- `quest_id`: The ID of the quest to start
- `target_state`: The new state a quest should take.

**Does not branch**

The quest will be set to any `target_state` _except_ `DORMANT`.

### Time Effects

None yet

## Logical Operations
### Conditonally perform some effect
> `ConditionalEffect`
// TODO

## Audio
### Triggering an event
> `AudioEventEffect`
// TODO

## Starting a Dialogue
> `DialogueEffect`
// TODO

## Setting a variable
> `SetVAREffect`
// TODO

## Player Movement
### Moving around a level
> `TeleportEffect`
// TODO

### Loading a new level
> `LevelLoadEffect`
// TODO

## Misc / Utility
### Adding a debug printout
> `DebugEffect`
// TODO

### Overriding the actor id
> `ForceEffectId`
// TODO

### Picking an item up
> `ItemPickupEffect`
// TODO

## Controlling regions
### Changing door state
> `ToggleDoorEffect`
// TODO

### Generic region changes
> `UpdateControlledRegionEffect`
// TODO

## Available Conditions

### Logical Conditions
#### Logical AND
> `AndCondition`
> 
// TODO

#### Logical OR
> `OrCondition`
> 
// TODO

#### True
> `TrueCondition`

// TODO

#### False
> `FalseCondition`

// TODO

#### Not
> `InvertCondition`
// TODO

### Check an Inventory state
> `InventoryCheckCondition`
// TODO

#### Check equipped items
> `EquipmentCondition`
// TODO

### Check the state of a quest
> `QuestStateCondition`
Checks the state of a quest.

**Properties:**
- `quest_id`: The ID of the quest to check
- `state`: The state to check for (one of: "not_started", "in_progress", "completed", "failed")

## World state check
> `DialogicVARCondition`
// TODO

## Time Conditions
None implemented yet