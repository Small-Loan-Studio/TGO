# TGO Inventory System

# Goals of the Inventory System implementation

- Modular - we should be able to attach an inventory to any actor or object that needs a container-like structure to hold items. This can be anywhere from our Player Controller to a Puzzle that requires an item to be slotted in.
- Easy-to-use - implementation should be easy to use in the Editor without mucking around in the code
- Separated UI - having unlinked UI and Code allows us to create things that would otherwise be annoying to work with, an example of this would be a puzzle that renders an object in the world.

## Implementation

The implementation will follow the this simple outline: Inventory → ItemStack → Item

All three of these objects will be resources that can be instantiated as normal throughout code.

I believe the plan right now is to have an InventoryManager class that handles the creation of the individual inventories, as well as possibly handle loading and saving of inventory information (TBD).

## Inventory

Inventory will represent the actual data that we will use to show the user the inventory as well as keep track of what they have/are holding. Currently the only two properties that matter are the array that holds all of our ItemStacks, and a integer size to determine how big the inventory can grow to (TBD).

There will be a few functions like inserting and removing Items, and anything that requires ItemStacks to be merged will be handled in ItemStack to keep the flow of the code clean. It’s plausible we will need to come back to this and add in a bunch of UI-related additions. Ex: Being able to split items on the mouse or using the scroll wheel to pick up a few items.

## ItemStack

ItemStack will represent our items in the inventory. They are made up of an Item Resource, and the quantity of that item. They’ll have a few methods to help deal with merging stacks of items and anything else of the like. They are VERY important when it comes to putting items in the world. You will create unique versions of these to have different quantities of items in the world at a time. 

# Item

Items will exist as a Resource that can be created and given initial values in the Editor. This will allow stream-lined access to the files, and should help catch errors before they happen due to the lack of strings being passed around. Whenever files are moved in Godot that are attached via the Editor, Godot will automatically update those references. If we move a scene file for an item or art file for someone, Godot will automatically update that for us. 

I strongly recommend anyone who is going to be working with these files a lot to use the “Edit Resources as Table 2” plugin from the Godot AssetLib. This allows you to view all files in a table-like structure, filter them by certain conditions (i.e. only shows items that are key items or start with “Pot”), and also edit multiple entries at once. Addon link: [https://github.com/don-tnowe/godot-resources-as-sheets-plugin/](https://github.com/don-tnowe/godot-resources-as-sheets-plugin/)

# Item Implementation

- Name: String - name of the item
- Description: String - description of the item, possibly for lore or narration
- Type: Enum - Enum flag to determine type (Not implemented yet but Planned)
- Stackable: bool - Whether or not this item can stack
- Stack_size: int - The amount this can stack to if stackable is true
- Icon: Texture2D (Image file) - The icon of the item. Used in displaying the item in UIs mostly.

# Other Considerations

- Do we want a slot-limited container, or slot-less (unlimited)?
- Do we want to be able to increase the size of the container through upgrades or otherwise?
- Do we want a Resident Evil-like central storage that can hold more items than the Players Inventory?
- Do we want to stub out stat-affecting items that can easily be created via the Editor?
- Do we want to stub out time-sensitive buffs and effects for easy Editor access as well?
- Do we want the player to have key items be apart of the normal inventory, or a special one? Should they be able to discard items, and if so should we automatically send those items to their storage, or should they have to find the item in the world again?
- Do we want an ItemStub scene that can dynamically load the resource we tell it to? Or should we create a scene for each item that we want to have. *This will need to be thought about a lot, there might be more implications to this than meets the eye.*
- How should we uniquely indentify inventories within the Manager, and how do we take that a step further to create a system that can be saved/loaded back into the game. Should we give containers unique IDs manually, or should we create them automatically via some deterministic way?
- How do we want to do a hotbar system? Should we take inspiration from Resident Evil where Hotbar slots exist as part of the normal inventory, or should we create a separate Hotbar inventory that people will drag items onto.
- ^ Same thing but for equipment (if we have equipment). How do we want to handle an equipment section?