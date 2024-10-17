[SLIDE: TGO titlecard]

Boxes! Get your boxes here!
Moving boxes, grey boxes, named boxes, I got 'em all.

[SLIDE: Agenda]

By the end of this video you should understand:

1. What a greybox is / why you would use one
2. How to place a moving box and why you might name it

Let's return to Godot and take a look at our demo level.
[GODOT: TutorialDemoLevel.tscn]

Okay, that's a nice .. field... or whatever. It's a map. It's devart.
This is why you're making levels not me.

But anyway we want to put a placeholder here. It's going to be a building
or something large that takes up space but for some reason doesn't make
sense to break into tiles or we need to be able to relocate it more easily
than a block of tiles. We also don't have an asset for it yet so we're
going to use a generic block.

Because this is something that doesn't go into the tilemap it will live in
the objects subtree. So let's select that...

[GODOT: Select objects substree]

and then check out the control dock!

You'll notice that it has now given us a collection of buttons indicating the
type of object we want to add. In this case we're adding a generic standin so
let's go with a Greybox.

[GODOT: Click Generic Greybox]

As you can see there are several ways to customize the box being created.
- The name is how this new object will be referenced in the scene tree
- Size is obviously how large it will be but it's worth noting that this is
  measured in "units". We're considering one unit to be 32 pixes so a 1x1
	greybox is 32x32 pixels. A greybox can be anywhere from 1 to 10 units large
	on the X or Y axes and increases in increments of .5 (ar 16 pixels)
- The three check boxes are variations on how this greybox behaves:
  - blocks movement will, obviously, prevent Devin from walking over it
	- blocks light will (eventually) cause it to cast a shadow and limit visibility
    to things behind it
	- and marking it as interactable means it can be configured once placed to
	  have some effect when the player tries to "use" it
- And finally you can tint the greybox in the event it's helpful to distinguish
  them from each other in some way

So let's go ahead and make a little stand-in for an alter that will teleport the
player when used.

[GODOT: Make an alter using a few greyboxes]

Cool, so now let's make it a little harder to get to -- we can do that by adding
moveable boxes that initially prevent access.

[GODOT: Click Pushable boxes]

As you see here there are some familiar options, let's just add a few and
use them to block the entrance.

[GODOT: Add some boxes of varying sizes]

Aaaaand there we go. Let's give this a test run by hitting F5 and see if it works.
Good.

One last thing is that we want it to teleport the player, let's pick a location
and add a reference under markers.

[GODOT: Add TeleportDest Node2D]

And then go back to the altar greybox with interactable set. Look over in the
Node Inspector you'll see a collapsed section called "Interactable Configuration."
That's where we'll be making changes.

First set the verb to "use" because that's what you'll be doing -- using the alter.

Next add an entry into the array of interaction effects. We won't go into detail
now but Effects are one of the building blocks we talked about in the first video
that let you impact world state.

In this case we just want to add a teleport effect so we click that...
and then on the newly added effect we can click into it to configure how it
behaves. Each effect has different options but for teleport we need only
to select a destination.

Okay then. Now we can do another test run and see how it works.