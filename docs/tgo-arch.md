# Building TGO

- [Building TGO](#building-tgo)
  - [Goal](#goal)
  - [Changelog](#changelog)
  - [Dataflow / Signals / Interfaces.](#dataflow--signals--interfaces)
  - [**Prospective** Scene Tree](#prospective-scene-tree)
  - [Scene Tree Details](#scene-tree-details)
    - [Driver](#driver)
    - [AudioManager](#audiomanager)
    - [OverlayManager](#overlaymanager)
      - [Curtain/HUD/Journal/Dialogue/Menus](#curtainhudjournaldialoguemenus)
    - [GameWorld](#gameworld)
      - [Clock](#clock)
      - [InventoryManager](#inventorymanager)
      - [Player](#player)
        - [Camera2D](#camera2d)
        - [\<OtherItems\>](#otheritems)
      - [LevelBase](#levelbase)
        - [Objects / Characters / Markers](#objects--characters--markers)

## Goal
In this document I want to lay out the very high level approach we will take to
tying major systems together in TGO. It is written aspirationally and without
having encountered what I'm sure to be very real challenges along the path to
implementation.

To the degree that is possible we should strive to keep it updated but make
sure to check the changelog and the farther in the past it is the more likely
it's hiding dragons.

## Changelog
- 2024-12-15: True up to recent changes; mostly minor edits.
- 2024-09-07: Minor update to match the state of the world.
- 2024-07-09: Initial draft. Wish us luck.

## Dataflow / Signals / Interfaces.

Some very general rules:

1. A parent may call into their children
2. A child should signal up to the parent and should _not_ call methods via `get_parent()`
3. A node should avoid direct access to its sibling (e.g. another child of their parent)
4. Nodes that require initialization should expose a `setup` function that takes the
   required objects and have those objects provided by the parent if it is added to
   the scene tree via code.
5. Driver should strive to be the only true singleton.

We'll expand/revise these as we research/discover best practices.

## **Prospective** Scene Tree

Let's take a quick look at how the TGO Driver will be structured and a quick
summary of the what/why for each major slice.

```
Driver
├─ AudioManager
├─ OverlayManager
│  ├─ Curtain
│  ├─ HUD
│  ├─ Journal
│  ├─ Dialogue
│  └─ Menus
├─ <X>Manager
└─ GameWorld
   ├─ DayNightOverlay
   ├─ Player
   │  ├─ Camera2D
   │  └─ <OtherItems>
   └─ LevelBase
      ├─ TileMap
      ├─ Objects
      │  ├─ Lights
      │  ├─ Switches
      │  └─ etc...
      └─ Markers
```

## Scene Tree Details

> :warning: Note that the farther down this list you go the less
> well defined the information we have is to inform the design.
> Expect things to change and, if you're the one changing them,
> please update the doc for your team.

### Driver

This handles bootstrapping the game through initial setup and getting us to a
start menu.

It will also handle distribution of global state changes via defined signals
(e.g., the game becomes paused) and provides an API to orchestrate broad multi-component
functions (e.g., initiating a save/load).

It is a singleton and provides access to attached managers. Each of the managers
should rely only on API/signals from the Driver and should take a Driver reference
to enable testing with stubs should we decide it necessary.

### AudioManager

Initially this will drive background music playback to enable easy transition
between relevant tracks as we move between modes in the game (menus,
dialogue, cutscenes, gameplay). Sound effects will live on the corresponding
objects.

Eventually this will be the central location for configuration and bootstrapping
of any middleware we use and we'll refactor any exposed API for music controls to
utilize the middleware system.

### OverlayManager

All UI that is presented not as part of the game world will end up a child here.
Basically those scenes have a different coordinate system not impacted by player/camera
movement and their z-order is detached from that of the rest of the game.

It exposes an API that lets us request specific actions (Open Journal, Start Dialogue,
etc) and exports signals indicating overlay start/stop states so that any gameplay
related interfaces can take appropriate actions.

#### Curtain/HUD/Journal/Dialogue/Menus

A non exhaustive list of things I expect will be added to a UI overlay:

- **Curtain**: can be used as a high z-order opaque screen to facilitate easy transitions
- **HUD**: displays stat bars, active items, etc. Likely contains references to the GameWorld, Player, etc.
- **Journal**: details unknown but primary information management mechanic
- **Dialogue**: interaction point for triggering conversations
- **Menus**: A catch-all for whatever menus we'll have available. May be a top-level MenuManager or we may have entries for each menu. TBD

### <X>Managers
Catch all for the various state tracing objects we'll introduce. These are
things not closely tied to the "physical" world that the player exists in and
track more abstract things QuestState or handle operations that touch multiple
systems like driving saving/loading game state.

At the time of this update we have included: InventoryManager,
SerializationManager, and QuestManager.

### GameWorld

Contains state about the interactive game environment. Anything that Devin will
interact with "physically" goes here.

#### DayNightCycle

Handles the global color overlay, configuration on what constitutes day/night
and drives the game world's time of day.

#### Player

Player representation in a scene. Handles input intended to guide player actions
(move, interact, use item, etc). Signals can be used to indicate state changes.

##### Camera2D
Our current setup has the camera as a child of the player. That will eventually
change to get more designed camera behavior but for now it works pretty well.

##### &lt;OtherItems&gt;

TBD, do we have things that get player-attached? idk.

#### LevelBase

When we load a level it gets added as a child of the GameWorld / a peer of
the player. Currently level loading and dispatch lives in Driver which provides
a reference it itself to all loaded levels. For more information on level
loading see [tgo-levels.md](./tgo-levels.md) and [tgo-level-loading.md](./tgo-level-loading.md).

##### Objects / Characters / Markers / etc

NPCs, objects, buildings. Things that Devin interacts with. Documentation for
things in this bucket will likely be broken out into their own section or
referenced indirectly in LevelBase docs.

Broadly though you can think of them "the things in the game world."