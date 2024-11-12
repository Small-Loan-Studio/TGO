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

### Displaying data

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

### Reacting to user action

Now that we have a model for displaying data how do we get information about
user interactions with the interface that we've built? Many things can be handled
internally--e.g., selecting a specific quest to view more information--but
not everything is so self contained.

If we think back to our guiding principles and how we want to maintain low
coupling the first answer we should reach for is "use a signal." And in many cases
that is the right answer:

- clicked "New Game"? Signal
- Toggle fullscreen mode? Signal
- Abandon a Quest? Signal
- etc.

Your signal handlers will typically be connected by the scene containing your
interface as it likely has access to all relevant parties that would be involved
in executing the requested action. But this is programming and there is definitely
more than one way to solve a problem. Let's say that we don't want to deal with
signal handlers or the associated plumbing though. Is there a better way without
making an unusable mess? Probably, yes!

Let's pull "Abandon Quest" out of there. That feels like something that might
be annoying to plumb signal handling for and that won't yield much benefit. We
still want low coupling but the observer pattern doesn't benefit us much. In
this case we also already have direct access to the QuestManager and Quest objects.
Because we have a well defined abstraction on how to interact with quests there
is already a `QuestManager.abandon_quest(quest_id: int) -> void` function. So
instead of having to use a signal we can treat the reference to QuestManager as
an entry point to safely manipulate the data model.

> Note that there actually isn't an `abandon_quest` method, I don't think that's
> going to be an option for TGO so I didn't bother to write it but it's still
> a reasonable example of when you might use function calls to handle user action
> from within an interface.

### Deciding: signals vs function call

Okay, so there are clearly at least two clean, maintainable, ways to handle user
actions in your UI. The question then is how do you choose which one to use in
your specific circumstance. It mostly comes down to the following questions:

1. Do you already have access to the methods you need to call because they're
   hanging off the objects used while constructing your interface contents?
2. When the user takes an action is there one obvious endpoint that will care
   about what just happened?

If the answer to both of these is "yes" then using a function is likely to be
quicker, easier, and cleaner. If, on the other hand, you have to do a bunch of
plumbing to get access to the method you want called, there are lot of functions
that will need to be invoked, or you don't know all the places that will need
to be notified then use a signal.

### Where do I store my signals?

I don't have enough experience with Godot to make this claim with meaningful
authority so it's mostly intuition here but:

1. By default assume your signal should live in the class that manages your
   interface. By and large the things that are most interested probably have
   direct access to this and can handle wiring any listeners or making that
   signal available
2. If the burden of plumbing necessary to make (1) work is too onerous consider
   a signalbus

Signal Busses are super nifty and it's reasonable to ask "why would I ever want
something different?!"

Mostly it's because having your signals separated from
the relevant code means you lose a little of your encapsulation and finding out
what all the relevant egress points for a component are depends significantly
on how consistent you are following whatever convention you've adopted to track
it. And then at the far edge once you've slid fully down the bus slope you
start to lose the ability to reliably track call paths because "I think this signal
is still connected / should be connected by now." This paired with the mediocre
"compile-time" enforcement in GDScript means that you're giving up quite a bit
in exchange for the flexibility.

Still cool though.

> For more reading: When folks say [event or signal bus](https://www.gdquest.com/tutorial/godot/design-patterns/event-bus-singleton/)
> in godot they're describing a variation on a [pub/sub pattern](https://en.wikipedia.org/wiki/Publish%E2%80%93subscribe_pattern).