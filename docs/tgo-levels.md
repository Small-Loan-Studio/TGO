# Levels / Placeables

- [Levels / Placeables](#levels--placeables)
  - [Changelog](#changelog)
  - [Structure: Levels within the Game](#structure-levels-within-the-game)
  - [Structure: Level-Internal](#structure-level-internal)
    - [TileMap Layers](#tilemap-layers)
  - [Style](#style)
  - [Design / Implementation Details](#design--implementation-details)
    - [New levels](#new-levels)
    - [Objects](#objects)
    - [Markers](#markers)
    - [An argument against premature optimization](#an-argument-against-premature-optimization)
    - [Tilemap Collision Changes](#tilemap-collision-changes)
  - [TODO: These things need more thinking / writing](#todo-these-things-need-more-thinking--writing)
    - [Interactable nodes](#interactable-nodes)
    - [Lighting](#lighting)
    - [Hooks to various other systems (journal, quests, dialogue)](#hooks-to-various-other-systems-journal-quests-dialogue)


## Changelog
- 2024-08-08: Update for greybox-in-progress
- 2024-07-14: Capture initial braindump from Luke's research. Still a lot of amibuity.

## Structure: Levels within the Game

- Levels exist in the scene tree as a peer to the player
- The camera tracks the player
- The Driver manages ensuring that the correct level is loaded and works with
  the levels themselves to orchestrate any state saving that needs to be done

```
Driver
└── GameWorld
    ├── Level
    └── Devin
        └── Camera
```

## Structure: Level-Internal

Each level has three major components: the base tilemap, non-tile objects, and
location markers. The tilemap itself also has different layers with varying
z-indexes to control draw order. The tilemap, all layers, and the Objects
group are all y-sorted.

Markers are broadly intended to be non-visible game play objects used to
specify points of interest for other bits of code, e.g., teleport
destinations.

```
Level
├── TileMap
│   ├── L0: Base Layer     (z: -10)
│   ├── L1: Ground         (z:  -5)
│   ├── L2: Ground Details (z:  -2)
│   ├── L3: Placeables     (z:   0)
│   └── L4: Canopy         (z:  10)
├── Objects
└── Marker
```

### TileMap Layers
Not every map will need every layer and some maps may need more. This is
intended to be a "good start" that we can deviate from as necessary.

* **Base Layer**&mdash;This is displayed under everything else, likely it will be
water, an empty void, or plausibly unused;
* **Ground**&mdash;Drawn above the base layer and is an area that the player is
expected to traverse. This could still include non-passable areas, e.g. a
lake, but broadly it encompasses the space a player will be. Always drawn behind the player;
* **Ground Details**&mdash;Embellishments in the world. Things like plants,
fountains, bridges, and the like. Always drawn behind the player;
* **Placeables**&mdash;More embellishment but drawn in front of the details layer.
This in the first layer that the player will be able to be behind so things like
fence railings, pillars, and the like go here;
* **Canopy**&mdash;Think "tops of trees" or "roofs." This layer is always drawn
over the player and may or may not be impacted by a light source the player is
holding (TBD).

## Style

Current threads with design has the game broken up into relatively small areas
with doorways or portals to move between them.

The camera can follow the player as they move around the space, and we should
be able to load the whole space up at the same time. So we don't have to worry
too much about streaming in the level (which we might if we had a large, open
world).

## Design / Implementation Details

`LevelBase` is the parent scene for all levels. At present it contains a few
functions and references that make dealing with building level features out
and I expect that set to grow over time. Let's take a brief tour through it
with a focus on level lifecycle:

1. `setup`&mdash;Called after the level is added to the GameWorld by the
   `Driver` and accepts the `Driver` as an argument. This allows the level
   to do any setup it needs for itself before being played.
2. `level_setup`&mdash;called from `level_setup` this is not used by `LevelBase`
   directly but is intended to be an overridden method by specific levels if
   they have any configuration to do.
3. `swap_to_level`&mdash;this is called (typically be the level itself) to
   kick off a level change. Currently plumbing that I'm not sure we'll keep
   around.
4. `save_level_state`&mdash;when `Driver` starts to unload a level that is
   being left behind this will get called so that any state that needs to
   be saved or any cleanup can be done prior to unload.

### New levels
New levels should be created as a `New Inherited Scene` and select `LevelBase`
as the node to inherit from.

You can add custom code by changing the script attached to the scene's root
to a new script that extends `LevelBase`, e.g.:

```
class_name CustomLevel
extends LevelBase


func level_setup() -> void:
	print("CustomLevel.level_setup")
```

### Objects
The `Objects` sub-tree within the LevelBase is intended to house things that
either doesn't fit well within the tile-based grid or that the player may be
interacting with.

I expect our most common usage will be:

* a `Sprite2D` / `AnimatedSprite2D` with an `Interactable` child for NPCs,
  items, etc;
* a `Node2D` with no rendered display wwith an `Interactable` child for an
  area that the player can trigger upon entry
* a `Sprite2D` / `AnimatedSprite2D` with no child for just a "thing" that
  exists in the world but didn't make sense to try to represent as tiles

### Markers

tl;dr: `Node2D` that captures positions in the world for reference as
player entry, teleport locations, whatever.

### An argument against premature optimization

In theory we could do optimizations like loading in adjacent 'rooms' so that we
are ready when the player goes through a door, but I would recommend against
that kind of early optimization and say we should just try to dumbest way
possible and only complicate if we find that we actually have performance issues.

I think a good reference here is probably old 2D pokemon games. Which of course
still have open areas, but break things up into towns, routes, floors of buildings,
caves, and other areas which are always connected by some kind of portal/door.

### Tilemap Collision Changes

Due to a current bug with pushing and pulling moveable blocks, the player character gets stuck if they drag a block so that the character is stuck between the block and the wall. Once they do this, the block is not grabbable so that the player can get unstuck. By changing Collision Animatable to "On" we can avoid this bug.

![image](https://github.com/user-attachments/assets/fc2f9c2c-6c20-412b-8f29-5927b368c58d)


## TODO: These things need more thinking / writing
### Interactable nodes
### Lighting
### Hooks to various other systems (journal, quests, dialogue)
