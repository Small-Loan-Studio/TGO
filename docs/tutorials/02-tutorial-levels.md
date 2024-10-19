[SLIDE: TGO titlecard]

Welcome back! Today we're going to take about ...

[SLIDE: Levels]

Levels!

[SLIDE: Agenda]

Specifically by the end of this video you should understand:

1. What a "Level" is for TGO
2. What the components in the scene tree are
3. How to create a new empty level
4. The layers of our tilemap (and what that even means)
5. How to add geography to your level
6. And, finally, how to take your level for a test run

[SLIDE: Why Levels?]
Intuitively we probably all know what a level is -- it's a physical space for
our character to explore. We populate it with people, clues, and environmental
story telling to add depth.

From a designer's perspective it's also the unit sizing of what one person will be
assigned to build. For technical reasons it's non-trivial for multiple people to
make changes to a level at the same time and coordination is required if a team
will be working together. This kind of overhead means that our levels will be
limited by the team's ability and willingness to handle the communication hurdles
more than technical constraints on size.

In some cases we'll likely be willing to eat that cost to enable a large expansive
areas (e.g. Oakshaw proper perhaps) and in the long run we may be able to find
ways to stitch smaller sections together but that's more hope than promise right
now.

So in summary -- a level is, hopefully, pretty much what you'd expect. Now let's
talk about how to build them and what they can contain.

[GODOT: Creating A Level]

To do that we'll switch to Godot.

All levels start with a common set of features that are defined in something called
the LevelBase. In Godot we call that the "parent" scene to your level. So naturally
in order to create a new level we will inherit from our parent. To do that:
1. go to the "Scene" menu;
2. click 'New Inherited Scene';
3. and then select `Scenes/Components/LevelBase.tscn` as your base;
4. click open and you have a new empty level!
5. Go ahead and save that with Ctrl-S or by the Scene > Save Scene menu entry.
   Levels should be saved into the `Scenes/Levels` directory. We'll call this one
   `TutorialDemoLevel.tscn`

Congrats! You've just created your first level for TGO...

Now what do all the things you inherit even mean?

[SLIDE: Levels: Structure]

Well, a level is composed of three main groupings:

1. A tile map
2. Objects
3. Markers

Objects we'll get into more deeply with subsequent videos but broadly these are
"things that Devin interacts with." Markers mostly what they sound like: named
positions in the Level.

All Levels require at least one marker called "PlayerStart" so we'll be adding
one pretty soon.

And the TileMap is the vast majority of the world -- it's the things that don't
change very much -- roads, buildings, trees, water, bridges, benches, etc. It's
composed of a set of layered tiles each layer has a specific purpose and is drawn
at a specific depth...

Let's first take a look at an example and then we can make some changes to our
new level.

[SLIDE: TileMap]

Layer 0: This is the base layer; it will be drawn below everything. You don't have
   to use it but if you do it'll probably be for water or unwalkable void.
Layer 1: This is the ground by default this is probably going to end up being your
   most used layer, it'll typically include stuff like the grass and paths that
	 Devin can walk but also things that block movement like coastline. It's drawn
	 above Layer 0.
Layer 2: Basically still just the ground but an added layer if we have ornamentation
   that we want to add. Drawn above Layer 1.
Layer 3: This is where things start to get interesting -- the Placeable layer, layer 3,
   is where things start to be y-sorted with non-tilemap objects in the world. That
	 may sound complicated but basically it just means that an object can appear in front
	 or behind something in layer 3. It will always be drawn on top of Layer 2 and has
	 a dynamic relationship with other game objects.
 Layer 4: The canopy is special because it appears above everything. The intent here
   is to caputer things like clouds, tree tops, the roofs of buildings, etc. Generally
	 it something doesn't make sense to be "under" anything else it can get put into
	 the canopy.

Now let's head back to Godot and see how all of these gets used.

[GODOT: TutorialDemoLevel.tscn]

Open up `TutorialDemoLevel` in the 2d scene view and let's start by setting up the
tilemap with the appropriate tileset.

[GODOT: select the tileset]

For this demo I'm using `simple_tileset.tres` but if we have art assets relevant
to your level you should use those. Generally you will want to use an existing
tileset because each tileset has setup that needs to be done and we probably won't
make a tutorial covering that in the near future.

Now that that's done let's make a little room and I'll talk through the simple
tileset.

[GODOT: make NxM room with some pillars and a table in the middle]

This white tile is a 1x1 which the player can walk over and see through
The grey tile is a 1x1 which the player can not walk through but _can_ see through
And the black tile is a 1x1 which will block player movement and visibility / light

Below that are 1x3 tiles which can be used to stand in for larger items such as
pillars or trees. They are configured so that the bottom 1x1 section has the same
behavior as the 1x1 above. So that means, left to right, you have:

- a 1x3 that does not block movement or visibility
- a 1x3 that blocks moves movement in the bottom 1x1 section but not visibility, and
- a 1x3 that blocks both movement and visibility in the lower 1x1 section.

That probably is all a bit confusing so in a moment we'll drop these into the level
to see how they behave.

Before that though we need to add a player start location so: with `Markers`
selected hit Ctrl-A and add a Node2D. Once it's added rename it as `PlayerStart`

[GODOT: Add a PlayerStart Node2D]

Now let's go ahead and add the sample tiles. For the 1x1 we'll add these in the
Ground layer and for the 1x3 tiles let's use Placeable layer so that we can
see the y-sorting behavior.

[GODOT: place one of each tile]

Okay, we're almost ready. If you were to playtest now you'd get the debugging
launcher instead of your level. We'll eventually have a better solution but, for
now, open up the driver...

And if the tab isn't available you can Ctrl-P and type `Driver.tscn` to find it.

[GODOT: Open Driver.tscn]

Once you're here make sure `Driver` is selected in the Scene Tree on the left
sidebar and that the inspector tab is open on the right sidebar. Then for the
autoload scene select the level you're working on.

[GODOT: Add TutorialDemoLevel.tscn]

Make sure everything is saved and you should be able to hit F5 and run your
work in progress level. The Driver wiring will drop the player in the location
specified by PlayerStart and you can walk around to see how each tile behaves
and how y-sort works.

[GODOT: walk around]

It's a masterpiece.

Hit F8 to quit.

