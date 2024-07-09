# Building TGO

- [Building TGO](#building-tgo)
  - [Goal](#goal)
  - [Changelong](#changelong)
  - [TGO Structure](#tgo-structure)


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

## TGO Structure

```
Driver
├─ OverlayMgr
│ ├─ HUD
│ ├─ Journal
│ ├─ Dialogue
│ └─ Menus
├─ MusicMgr
└─ GameWorld
  └─ Level
```