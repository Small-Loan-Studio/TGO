# Levels / Placeables

- [Levels / Placeables](#levels--placeables)
  - [Changelog](#changelog)
  - [Presentation Style](#presentation-style)
    - [An argument against premature optimization](#an-argument-against-premature-optimization)
  - [Art style](#art-style)
    - [Workflow](#workflow)
    - [Our role](#our-role)
  - [Open Questions](#open-questions)


## Changelog
- 2024-07-14: Capture initial braindump from Luke's research. Still a lot of amibuity.

## Presentation Style

From talking with Mario, I think we're going to be okay having the game broken up into relatively small areas, with doorways or portals to move between them.

The camera can follow the player as they move around the space, and we should be able to load the whole space up at the same time. So we don't have to worry too much about streaming in the level (which we might if we had a large, open world).

### An argument against premature optimization

In theory we could do optimizations like loading in adjacent 'rooms' so that we are ready when the player goes through a door, but I would recommend against that kind of early optimization and say we should just try to dumbest way possible and only complicate if we find that we actually have performance issues.

I think a good reference here is probably old 2D pokemon games. Which of course still have open areas, but break things up into towns, routes, floors of buildings, caves, and other areas which are always connected by some kind of portal/door.

## Art style
And then I talked with the art folks about workflow, and tried to pin down some basic answers about art direction where it might relate to us. Results are:

1. we still don't know the exact size we are going to be working at. We do want charcters that are on the larger side when it comes to pixel art overword sprites (maybe something like 32 px tall). So that gives us some idea how big our overall canvas might be, but not enough to really make any firm decisions about it
2. Art team does want to use tilemaps, instead of working with like a single large image. This has some implications for how we want to greybox, since it's probably better if we also greybox using tilemaps (i.e. make a fake tileset with just some basic colors, tiles with colliders, that kind of thing). One thing that I'm realizing now that I should have asked about is layers. I assume we will want to have multiple layers on the tilemap (i.e. we can place a shrub tile with transparency over a grass tile or over a dirt tile) but it would probably be nice to have an idea of how many layers we actually want to have so that we can set it up

### Workflow

When it comes to workflow, it seems like the artists want to be responsible for concept art and making the tileset, but not actually placing tiles in engine (which would be the job of level designers). My understanding of the basic flow here for a region would be. 

1. designers decide generally what a place is and what it should have (i.e. "we need a house interior for x family that has a spooky dining room for this scene in the game")
2. artists would make concept art for the location, probably pretty specific concept art including things like general layout, would go back and forth with designers to finilize
3. aritsts would make/add to tilesets to support all the in game locations
4. level designers would use those tileset and the concept art layouts to impliment the actual area in engine

### Our role
I'm imagining basically that leaving us with the task of importing the tileset into the engine and making them usable (including probably setting up collision), but not actually doing layout stuff ourselves.

For more interesting interactions (say, a chest you can walk up to and interact with to get items from) I'm imagining we will treat those as separate from the tileset/map, and just make individual Scenes with sprites attached that level designers can drop into the world.

## Open Questions
1. How many and what layers does design/art expect to od
2. How do we expect lighting these levels & layers to work
