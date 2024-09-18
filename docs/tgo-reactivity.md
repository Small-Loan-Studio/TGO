# Building Interactive Systems

> Goal: How to enable level designers to build a world that reacts to itself and
> to player action.

## Reactive Systems
> "When we reach state X do thing Y."

- Use Dialogic's `VAR.set_variable` / `subsystem_variable.gd` to store game state
- Track changes via `VAR.variable_changed`
  - `VAR.variable_set_state` doesn't quite work because that only gets emitted
    via an `_execute` of a `set` expression from a timeline
  - `VAR.reset` by default doesn't trigger variable_changed but it's a pretty
    minor diff to get that in place if necessary (for specific variable resets;
    a full reset is harder).

### A New LevelBase Section:
In order to organize the level we'll introduce a new top-level item:

```
Level
├── TileMap
├── Objects
│   └── Characters
├── Markers
└── Triggers
```

**I'm not clear yet if Triggers is stand-alone or if each Trigger is a Node
attached as a child.**

If a stand-alone entry `TriggerSystem.gd` could have `Array[Trigger]` with each
`Trigger` being a resource that knows which variables it needs to watch. It
could then register as a listener to `VAR.variable_changed` and whenever a
relevant change happens evaluate whatever predicates are configured.

The Node-attached-as-a-child solution is similar except each `Trigger` would
be broken out like so:

```
Level
├── TileMap
├── Objects
│   └── Characters
├── Markers
└── Triggers
    ├── Trigger1
    ├── Trigger2
    ├── Trigger3
    └── Trigger4
```

Fundamentally it would still follow the same registration/evaluation cycle
as in option one. The primary benefit here is that it may be easier to
visualize what is active in the level.

### Trigger Structure:

This could be as simple or as complicated as we want. From the simple:

```
class_name Trigger extends Resource
var var_name: String
var test: String # should be <=, <, =, >, >=
var want_value: Variant
```

to the more complicated:

```
class_name Trigger extends Resource
var expr: PredicateTerm

class_name NotTerm extends Resource
var expr: PredicateTerm

class_name OrTerm extends Resource
var expr_a: PredicateTerm
var expr_b: PredicateTerm

class_name AndTerm extends Resource
var expr_a: PredicateTerm
var expr_b: PredicateTerm

class_name VarTerm extends Resource
var var_name: String
var comparison: TestOperation
var desired_val: Variant

enum TestOperation { LTE, LT, EQ, GT, GTE }
```

and any point in between.

I believe the most likely starting point would be a simple version that has
a clear plan on how to evolve into the complicated one.

## Position-dependent behaviors

> "When a specific object is in a specific place make some change."

Introduce one new component and collision layer:
- Collision Layer: 3 &mdash; `Trigger Actor` for things that can set off a
  switch
- Component: `Switch`, an `Area2D` child that is configured to detect when a
  `Trigger Actor` area enters into its space

I'd like to be able to reuse all the `InteractableAction` to reduce code
duplication. In order to do that we'll need to make a few changes:

1. `InteractableAction`'s parent needs to be changed to something more
   generic. This should be simple at this point:
   - `InteractableTarget` uses `parent.get_node`
   - `InteractablePickup` uses `parent.get_node`
   - `InteractableLevelLoad` doesn't utilize `parent`
   - `InteractableDialogue` uses `parent.get-parent().name` in an error message
2. `act` currently takes a `Character` and `LevelBase` as parameters; the
   `LevelBase` can remain as it's a fundamental assumption that all actions
   should be taking place within the context of a level. `Character` will need
   to change.
   - for `actor` I'm currently thinking about switching to a model similar to
     `CharacterTarget` but I'm not certain yet.


### Switch
Begins life as `Area2D` with `Trigger Actor` mask set.

**Configurable Properties:**  
- `single_fire: bool`&mdash;means that the switch can only be hit once and
  doesn't automatically unset itself when the triggering item exits; may be
  reset
- `id_mask: Array[String]`&mdash; array of ids in the event that only some
  things should be able to activate the switch, e.g., a specific block / set
  of blocks.
- `triggered(bool)`&mdash;signal that is fired when the switch state changes
- `switch_on: Array[InteractableAction]`&mdash;actions that get executed in
  order when the switch is activated
- `switch_off: Array[InteractableAction]`&mdash;actions that get executed in
  order when the switch is deactivated

**Methods:**  
- `_on_pressed`&mdash;bound to `area_entered`, handles checking the id of the
  entering object (if `id_mask` is set) and kicking off `switch_on` actions
  emitting events. Adds the entering object to an "activation stack" so that
  we can handle cases where multiple activating objects are in the area at once
  so that we don't inadvertently disable the switch when one of them leaves.
- `_on_released`&mdash;bound to `area_exited`; evicts the exiting object from
  the activation stack. If there is nothing left in the activation stack
  trigger the `switch_off` events and emitting the triggered signal.


## Notes:
- Utilization of IDs above suggests we should have a universal assumption that
  almost everything dynamic will have an ID at a fixed location (`.tgo_id`,
  `.id`, `get_meta("id")`, etcetcetc)).
- Should probably rename `InteractableAction` since it's becoming more broad.