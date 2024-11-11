# TGO User Interfaces

## Preface

In Godot circles you'll see a lot of talk about "Signal Up / Call Down" as a
best practice. That is basically shorthand that covers the following three
bits of design advice:

Signal Up:

1. Low Coupling &mdash; Avoid having your components need to know too deeply
   about things that don't concern them and instead...
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

Now that we know what 
