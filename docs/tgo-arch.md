# Building TGO

- [Building TGO](#building-tgo)
  - [Goal](#goal)
  - [Changelong](#changelong)
  - [**Prospective** Scene Tree](#prospective-scene-tree)
  - [Scene Tree Details](#scene-tree-details)
    - [Driver](#driver)
    - [AudioManager](#audiomanager)
    - [OverlayManager](#overlaymanager)
      - [Curtain/HUD/Journal/Dialogue/Menus](#curtainhudjournaldialoguemenus)
    - [GameWorld](#gameworld)
      - [Clock](#clock)
      - [Inventory](#inventory)
      - [LevelManager](#levelmanager)
      - [Player](#player)
        - [Lamp](#lamp)
        - [\<OtherItems\>](#otheritems)
      - [LevelSegment](#levelsegment)
        - [Placeables](#placeables)

## Goal
In this document I want to lay out the very high level approach we will take to
tying major systems together in TGO. It is written aspirationally and without
having encountered what I'm sure to be very real challenges along the path to
implementation.

To the degree that is possible we should strive to keep it updated but make
sure to check the changelog and the farther in the past it is the more likely
it's hiding dragons.

## Changelong
- 2024-07-09: Initial draft. Wish us luck.

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
└─ GameWorld
   ├─ Clock
   ├─ Inventory
   └─ LevelManager
      ├─ Player
      │  ├─ Lamp
      │  └─ <OtherItems>
      └─ LevelSegment
         └─ Placeables
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

### GameWorld

Stores all durable state about the game world. Anything that needs to persist
between specific levels/maps being loaded should have representation here.

Likely contains majority of game save/load logic.

#### Clock

In the event we run a day/night cycle this will handle the world clock's tick
rate and contain signals indicating important times (day, dusk, night) as well
as any global color grading/overlays associated with time of day.

#### Inventory

Data model for what the Player has available to them. De-coupled from the UI
representation but can fire signals as state changes.

Plausibly covers gear / equipment state.

#### LevelManager

Details currently unknown but this is a stand-in for something orchestrating
a visual representation of the world that Devin is currently exploring. It's
likely a loader for relevant maps, handles dispatch of events relevant to other
systems, understands any necessary work to convey Devin's state between level
scenes, etc.

Likely a manager in its own right and an abstraction of a lot of logic.

In a fixed-camera setup we may define boundaries here; in an openworld scenario we
probably have signal handlers to load/unload scenes here.

#### Player

Player representation in a scene. Handles input intended to guide player actions
(move, interact, use item, etc). Signals can be used to indicate state changes.

Plausibly this exists as a peer node to specific map segments under a LevelManager
to avoid needing to juggle the node as we move between map segments.

##### Lamp

Currently the only known player-attached item. Currently has visual representation
but may not always.

##### &lt;OtherItems&gt;

TBD, do we have things that get player-attached? idk.

#### LevelSegment

An explorable segment of the world. Extremely ambigious on details, TBD.

##### Placeables

NPCs, objects, buildings. Things that Devin interacts with. We probably
won't have a Node of type Placeable or even one that inherits from
Placeable. Instead this is representative of a class of Nodes that will
likely exist.

Probably.

