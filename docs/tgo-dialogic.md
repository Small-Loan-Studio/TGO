# TGO & Dialogic

## Introduction

We use Dialogic 2 to support our in-game dialog and to store game state. It's
a widely adopted system within the Godot-community which is good! There are a
lot of community provided tutorials on how to use it, e.g., [Learn Dialogic Fast!][ldf]
and [How to use Dialogic 2][htdl2].

For general introductory material we'll rely on those tutorials. However there are
several custom integrations that we will use to allow the TGO Narrative team to
interact with the state of the game world.

## Survey Video

To start let's review the [TGO Dialogic video][tdlv] where we start to expolre using
TGO specific additions. In the segment I've linked to you can see that we are using a
custom expression to check inventory state.

## Using Supported Exressions

In the video I show the basic expression structure:
1. Surround by braces `{` & `}`
2. Use `TGO` to indicate you're using our custom logic
3. Use `.` to indicate you're moving on to the next part of your request, e.g., `TGO.player_inventory.has` can be read as:
    - I want to use `TGO` specific logic, and then
    - I want to interact with the `player_inventory`, and then
    - I want to check if it `has` some item
4. Use `(` `)` to indicate the specifics of our request, e.g., from our video example `TGO.player_inventory.has("ALTER_POTION")` is checking if `"ALTER_POTION"` is in our inventory.
    - If you have multiple things you need to specify break them up with `,`: `TGO.player_inventory.has("ALTER_POTION", 3)` will check if the player is carrying at least 3 ALTER_POTIONS
5. Each of these questions may return some answer. That answer depends on the question being asked.

### Inventory

#### 
#### Access the player's inventory
#### Access an arbitrary inventory

### Quests

### Time of Day


[ldf]: https://www.youtube.com/watch?v=7PuPU0Mrl_g
[htdl2]: https://www.youtube.com/watch?v=0JPNmQ27uwA&list=PLPwlXx18zF7EKPb4sVu4gZ9S7XS0-ad_a
[tdlv]: https://youtu.be/uX23Jbmh7WU?t=722