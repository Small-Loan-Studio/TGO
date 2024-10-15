[SLIDE: TGO titlecard]

Hi folks, let's talk about levels!

[SLIDE: Agenda]

Specifically by the end of this video you should understand:

1. What a "Level" is for TGO
2. What the components in the scene tree are
3. How to create a new empty level
4. How to add geography to your level
5. The layers of our tilemap (and what that even means)
6. And, finally, how to test your level

[GODOT: Pristine]
Let's return to godot and walk through starting a new level.

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

Now what?

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
composed of a set of layered tiles. Each tile will also have 