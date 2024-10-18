[SLIDE: TGO titlecard]

Welcome to the much anticipated and hopefully not-underwhelming video tutorials
for the TGO level design toolkit. What we talk through and what you'll be using
is a first cut at the tools available so over time we should see both the ergonomics
and power of these improve. While you're using them:
1. if you run into bugs or rough edges, or
2. you think of use cases which are not well supported and you'd like additional
   tooling work done there
then please reach out to the dev team to let us know.

[SLIDE: Series agenda]

With that out of the way let's talk about TGO level design tooling! I'll be breaking
this up into several topic-focused videos. For this first release we'll be covering:

How TGO (the game) fits together and the hub we've built to interact with levels as a
designer.

[SLIDE: Advance]
Subsequent videos will go through the mechanics of using Godot or our tooling to
accomplish specific tasks:
[SLIDE: Advance]
1. How to create a new level, select a tileset, and add maps with collision;
2. How to create large non-tile based objects or interactable objects in your level
3. How to define and place new items;
4. NPCS definition, configuration, and placement;
5. How to add new conversations in Dialogic, what a Dialogic variable is, and how to use them;
6. and finally an introduction to simple switch use ... followed by some starting pointers for more complex usage.

With that out of the way: onward!

[SLIDE: TGO Structure]

As an artist, level, or gameplay designer your goal is to realize the creative
vision of TGO. For the engineering team our goal is to build the tooling that
will let you do that. Unfortunately the process of translating your grand
schemes into the cold reality of code that has been written may not
be the most intuitive process at all times and so understanding how things work
will hopefully help you reason about how to solve narrative, puzzle, or other design
problems.

[SLIDE: TGO Major Components]

As a game TGO is a platform sitting atop three core pillars. We'll first name
and then explain them...

1. Gameplay mechanics
2. Foundational systems
3. And world state management

Gameplay mechanics are fully in the realm of engineering and covers the things
that the player can do: run, push boxes, pick up items, talk to NPCs etc. As a designer
you can think of these as the verbs or actions that Devin can take as part
of the story you're telling.

Foundational systems are the ways in which the Devin's world manifests for the
player driving him. They're things like Inventory, Quests, Dialogue, Controller
input handling, and the Journal. These are not directly actions that Devin takes
but a way to mediate between the player intent and Devin. As a designer you'll use
these to communicate with the player: Devin has picked an item up, learned
something new from the world or an NPC resulting on a Quest or Journal update,
and the like. You don't need to worry about how these work internally but there
will be mechanisms that allow you to interrogate and change their state.

...Which leads directly into world state management. If the world was a static thing
there would be no story because nothing could happen. State management is broadly
a set of tools that allow you to change what is going on in the world. It could be
as simple as adding a Journal entry about a new NPC Devin has met, more complicated
like "these three switches have been pressed so the secret door is unlocked," or
a higher level "this quest has started its second phase so change these NPC dialogue
trees." The specific mechanisms you'll use to effect and react to world state will
vary and we'll talk about them in the upcoming videos.

So.

The primary challenge designing for TGO is likely going to boil down to answering
the question of how to decompose the story into a series of state changes using
the tools at your disposal... which honestly sounds a lot more complex in theory
than it actually is so don't worry! By the time we're done with this intro material
you'll have everything you need to reason through most situations and the eng team
is always here to answer questions or provide new features as needed.

[SLIDE: The Control Dock]

Before we get into the details let's take a moment to look at the tool you'll be
using for much of the TGO-specific features we've built. For that let's jump into
Godot itself.

[GODOT: Editor, pristine condition]

This is the godot editor having just opened the project. In the bottom left
sidebar slot notice a tab called "Control Dock" that's where all the stuff
we're building for you will go.

[GODOT: Open Control Dock]
Go ahead and open that up -- notice that right now there isn't anything present.
That's because you're not editing a level scene so let's do that.

I'll just press Control-P to get access to the quick-finder dialogue and open up
scene I've got prepared for this video.

[GODOT: Open a TutorialDemoLevel.tscn]

Checking in on the control dock and there still isn't anything available. That's
because we haven't selected a section of the level we want to edit. This is indicated
by the `Editing: Unknown` heading.

so let's take a look at the options...

[GODOT: Select TileMap & Markers]

If we select TileMap or Markers we notice that the Control Dock picks up on our selection
but still doesn't have any content. That's just because we don't have any custom editors
built for those items yet.

[GODOT: Select Objects and some of the children]

Now instead let's head back to the scene tree and select the objects section, or any of
the children within. That's a different story and now you'll have access to several
pre-built components that we can add as a way to start laying pieces down that a
player-as-Devin can interact with to drive the story forward.

[SLIDE: Wrapping up]
Cheers! That's it for the structure & tooling intro. Up next we'll get into how to
create a new level and then following that we'll dig into each of the components
you see in the Control Dock.