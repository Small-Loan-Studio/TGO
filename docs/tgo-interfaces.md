# TGO User Interfaces

## Preface

In Godot circles you'll see a lot of talk about "Signal Up / Call Down" as a
best practice. That is basically shorthand that covers the following three
bits of design advice:

Signal Up:

1. Prefer low coupling &mdash; Avoid having your components need to know too
   deeply about things that don't concern them and instead...
2. Use the observer pattern &mdash; This lets you interact with the outside
   world without having to understand or know about it.

Call down:

3. Well defined interfaces &mdash; make sure that your components have clear
   interfaces on how users should interact with them.

Taken together these practices help to ensure that the components you build
are usable in as many circumstances as possible. When building a new scene it's
safe to assume these principles apply and while diversions from this standard
can be made we should do so with intention understanding the justification and
the trade offs. That said because many things we build are not needed to be
super generic there is often a significant amount of leeway.

Interface components often end up on the other extreme though -- you'll be
building a single component that will be reused in many places and often in
ways you don't initially expect. For that reason when doing UI work lead hard
on these guidelines and push back when you see yourself or others deviating.
It's okay to do so but have a conversation about why and if other options are
viable.


## A Quick Explainer

Wait, what does this even mean in practice? I'm glad you asked, here is a
[three minute video](https://www.youtube.com/watch?v=c1qxvwGxC64) that does
a reasonable job distilling it.

## In TGO

Now that we know what our design guidelines are how do we apply that within
TGO? Let's take a look at some examples from the debugging QuestTracker
interface.

### Prefer low coupling
The QuestTracker scene only understands how to display quests. It is fully
disconnected from the management of quest state.

### Well defined interfaces

When QuestTracker needs to know information about a quest it uses a reference
it has to the the QuestManager to get access to a Quest and used the code
internal to those classes to gather the data necessary. If there was no function
that yielding the data needed a new one was added.

This mean that that as the internal data structures needed to track Quest
state evolved we are able to make changes knowing that we're not breaking
outside interested parties. In the worst case we might have to change our
API and when that happens we can very easily confirm whether or not API users
have moved over to the new setup.

### Use the observer pattern
The UI needs to understand when it should refresh the UI. It makes that decision
based on when the state of the displayed quests changes.

There are two ways to go about that

1. QuestManager could call an update function in the UI, or
2. QuestManager could emit a signal and whoever cares can do whatever they
   want with it.

The first is quick and easy but also breaks our low coupling goal and ties
the functionality of the data (QuestManager) to the representation
(QuestTracker). That's ass because it means any time we change the structure
or details of the UI we have to care about whether it will break the data
model.

Using a signal though means that QuestManager can just keep emiting a notice
that things have changed and the UI will roll right along handling those
signals as they see fit. In this particular case we use it to trigger a call
to `_sync` which results in a re-build of the interface to be an accurate
representation of quest state.

## Implementation

Okay but even though we know how these goals map into our design there are
still _many_ different ways we could accomplish this. If you look at the
early debug UIs for Inventory you'll see a very similar pattern that is
handled differently.

Going forward I suggest the following patterns...

### Pure data models

When the primary goal is to represent the state of some data model within the
game:

1. Data is fully separated/managed in a structure that
	- exposes signals the interface can use to track state changes
	- has an API that allows inquiry and modification of the data.
2. The interface API has a `setup` function that can be used when it's
   added to a scene to inject necessary references and trigger interface.
	 We use this instead of `_ready` to avoid initializitaion sequence issues
	 and it may be invoked via deferred call from the parent.
3. Any cleanup can be done in `_exit_tree`. If necessary we can adopt a
   `teardown` paradigm before removing the interface but I can't imagine
	 when that'd be needed.

### Menus

This is still in flux as we haven't started prototying menus
aggressively yet so caveat emptor.

At the base we use the all the same principles as above. The major difference
is that a menu is more than just a display

TBD: many interfaces will be more than display; maybe drop this segmentation
and rework into a new section "getting actions out" or some shit