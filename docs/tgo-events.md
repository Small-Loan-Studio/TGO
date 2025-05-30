# TGO Events System

- [TGO Events System](#tgo-events-system)
  - [Introduction](#introduction)
  - [Core Concepts](#core-concepts)
    - [Effects](#effects)
    - [Trigger Conditions](#trigger-conditions)
    - [Branching Effects](#branching-effects)
  - [Available Effects](#available-effects)
    - [Inventory Effects](#inventory-effects)
      - [Add Item Effect (`InventoryAddItemEffect`)](#add-item-effect-inventoryadditemeffect)
      - [Remove Item Effect (`InventoryRemoveItemEffect`)](#remove-item-effect-inventoryremoveitemeffect)
      - [Update Character's gear (`UpdateEquipmentEffect`)](#update-characters-gear-updateequipmenteffect)
    - [Quest Effects](#quest-effects)
      - [Start Quest Effect (`SetQuestStateEffect`)](#start-quest-effect-setqueststateeffect)
    - [Time Effects](#time-effects)
  - [Logical Operations](#logical-operations)
    - [Conditonally perform some effect (`ConditionalEffect`)](#conditonally-perform-some-effect-conditionaleffect)
    - [](#)
  - [Available Conditions](#available-conditions)
    - [Inventory Conditions](#inventory-conditions)
      - [Has Item Condition (`InventoryHasItemCondition`)](#has-item-condition-inventoryhasitemcondition)
      - [Has Room Condition (`InventoryHasRoomCondition`)](#has-room-condition-inventoryhasroomcondition)
    - [Quest Conditions](#quest-conditions)
      - [Quest State Condition (`QuestStateCondition`)](#quest-state-condition-queststatecondition)
    - [Time Conditions](#time-conditions)
      - [Time of Day Condition (`TimeOfDayCondition`)](#time-of-day-condition-timeofdaycondition)
      - [Time Range Condition (`TimeRangeCondition`)](#time-range-condition-timerangecondition)

## Introduction

The TGO Events System provides a way for designers to create complex interactive behaviors without writing code. It uses a combination of Effects (actions that can be taken) and Trigger Conditions (checks that determine if an effect should run) to create a (somewhat) reactive world.

## Core Concepts

### Effects

Effects are the building blocks of interactive behaviors in TGO. Each effect represents a single action that can be taken, such as:
- Adding or removing items from inventories
- Starting, completing, or failing quests
- Moving the player
- etc

In most cases effects can be chained together to create complex sequences of actions. Some effects expose branching paths for success and failure cases and there are generic Effects allowing you to create branching behaviors if necessary.

### Trigger Conditions

Trigger Conditions are checks that determine whether an effect should run. They can check things like:
- Whether an inventory has specific items
- The state of quests
- The current time of day
- And more!

Multiple conditions can be combined - all conditions must be true for the effect to trigger.

### Branching Effects

When an effect is something that can fail--e.g. adding or removing inventory items--there are hooks for
effects to hang off each outcome:

1. **Success Chain**: Effects that run if the previous effect was successful
2. **Failure Chain**: Effects that run if the previous effect failed

This allows for creating branching behaviors based on the outcome of each effect.

For Effects that should branch based on world state _before_ acting you can construct simple tests using the logical effect set.

## Available Effects

### Inventory Effects

#### Add Item Effect (`InventoryAddItemEffect`)
Adds items to a specific inventory.

**Properties:**
- `inventory_id`: The ID of the inventory to add to
- `item_id`: The ID of the item to add
- `count`: (Optional) Number of items to add (default: 1)

**Success Chain:** Effects to run if the item was successfully added
**Failure Chain:** Effects to run if the item could not be added (e.g., inventory full)

#### Remove Item Effect (`InventoryRemoveItemEffect`)
Removes items from a specific inventory.

**Properties:**
- `inventory_id`: The ID of the inventory to remove from
- `item_id`: The ID of the item to remove
- `count`: (Optional) Number of items to remove (default: 1)

**Success Chain:** Effects to run if the item was successfully removed
**Failure Chain:** Effects to run if the item could not be removed (e.g., not enough items)

#### Update Character's gear (`UpdateEquipmentEffect`)
// TODO

### Quest Effects

#### Start Quest Effect (`SetQuestStateEffect`)

Updates the state of a specified quest.

**Properties:**
- `quest_id`: The ID of the quest to start
- `target_state`: The new state a quest should take.

**Does not branch**

The quest will be set to any `target_state` _except_ `DORMANT`.

### Time Effects

None yet

## Logical Operations
### Conditonally perform some effect (`ConditionalEffect`)
### 

## Available Conditions

### Inventory Conditions

#### Has Item Condition (`InventoryHasItemCondition`)
Checks if an inventory has a specific item.

**Properties:**
- `inventory_id`: The ID of the inventory to check
- `item_id`: The ID of the item to look for
- `count`: (Optional) Number of items required (default: 1)
- `exact`: (Optional) If true, requires exactly the count (default: false)

#### Has Room Condition (`InventoryHasRoomCondition`)
Checks if an inventory has room for an item.

**Properties:**
- `inventory_id`: The ID of the inventory to check
- `item_id`: The ID of the item to check space for
- `count`: (Optional) Number of items to check space for (default: 1)

### Quest Conditions

#### Quest State Condition (`QuestStateCondition`)
Checks the state of a quest.

**Properties:**
- `quest_id`: The ID of the quest to check
- `state`: The state to check for (one of: "not_started", "in_progress", "completed", "failed")

### Time Conditions

#### Time of Day Condition (`TimeOfDayCondition`)
Checks if it's a specific time of day.

**Properties:**
- `time_of_day`: The time of day to check for (one of: "dawn", "day", "dusk", "night")

#### Time Range Condition (`TimeRangeCondition`)
Checks if the current time is within a specific range.

**Properties:**
- `start_time`: Start time in 24-hour format (HH:MM)
- `end_time`: End time in 24-hour format (HH:MM) 