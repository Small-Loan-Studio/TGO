[SLIDE: TGO titlecard]

Okay then. The much anticipanted and hopefully not-underwhelming video tutorials
for the TGO level design toolkit. What we talk through and what you'll be using
is a first cut at the tools available so over time we should see both the ergonomics
and power of these improve. While you're using them:
1. if you run into bugs or rough edges, or
2. you think of use cases which are not well supported and you'd like additional
   tooling work done there
then please reach out to the dev team to let us know.

With that out of the way let's talk about TGO level design tooling! I'll be breaking
this up into several topic-focused videos. For this first release we'll be covering:
[SLIDE: Now: How TGO works]
How TGO (the game) fits together and the hub we've built to interact with it as a
designer.

[SLIDE: Soon: guides on...]
Subsequent videos will go through the mechanics of using Godot or our tooling to
accomplish specific tasks:
1. How to create a new level, select a tileset, and add maps with collision;
2. How to define and place new items;
3. How NPCS definition, configuration, and placement works;
4. How to add new conversations in Dialogic, what a Dialogic variable is, and how to use them;
5. and finally an introduction to simple switch use ... followed by some starting pointers for more complex use.

With that out of the way: onward!

[SLIDE: How TGO is Built]

As an artist, level, or gameplay designer your goal is to realize the creative
vision of TGO. For the engineering team our goal is to build the tooling that
will let you do that. Unfortunately the process of translating your grand
schemes into the cold reality of code that has actually been written may not
be the most intuitive process at all times and so understanding how things work
will help you to reason about how to solve narrative, puzzle, or other design
problems.

[TGO Major Components]

As a game TGO is a platform balanced on three pillars. We'll first name
and then explain them...

1. Foundational systems
2. Gameplay mechanics
3. And world state management

Gameplay mechanics are fully in the realm of engineering and covers the things
that the player can do: run, push boxes, pick up items, talk to NPCs etc. As a designer
you can think of these as the verbs or actions that Devin can take as part
of the story you're telling.

Foundational systems are the ways in which the human player experiences the world
through Devin's eyes. They're things like Inventory, Quests, Dialogue, Controller
input handling, and the Journal. These are not directly actions that Devin takes
but a way to mediate between the player intent and Devin. As a designer you'll use
these to communicate with the player: Devin has picked an item up, learned
something new from the world or an NPC resulting on a Quest or Journal update,
and the like. You don't need to worry about how these work internally but there
will be mechanisms that allow you to interrogate and change their state.

...Which leads directly into world state management. If the world was a static thing
there would be no story because nothing could happen. State management is broadly
a set of tools that allow as 


While building we've been thinking of TGO as the interplay of three different

TGO foundational systems
TGO gameplay mechanics
TGO game state