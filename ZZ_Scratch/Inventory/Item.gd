class_name Item
extends Resource
## A resource representing a single item
##
## The resource will contain all of the information
## about our items

## The name of this item
@export var name: String

## The type of item this resource belongs to.
## Key items are quest items, or items that cannot be lost or otherwise discarded by the player.
## Consumables are consumed or used up to provide buffs or something similar
## Equippables are items that can be worn or wielded, and may or may not be rendered in the actual 2D space 
@export_enum("Key", "Consumable", "Equippable") var type: int

## The scene we want to load when this item is initiated in the game
@export var scene: PackedScene

## The icon that will represent this item in our inventory and hotbars
@export var icon: Texture2D

## The amount of items that can stack in a single slot. 1 denotes a nonstackable item,
## while anything more than 1 denotes that many items
@export var stack_size: int = 1:
	get:
		return stack_size
	set(value):
		# NOTE Set this to max of 1 and value to prevent setting it to less than 0
		# Unsure if this is the best way to do this, might be changed or moved in the future
		stack_size = max(1, value)

## TODO: Come back to this later. This is probably really bad way of doing this and we should brainstorm
## a better way of doing it.

## The amount of the item, or quantity. This can be edited on a per item basis to give more to a item world object
## If you want to use this to change how many items should be added when picked up, right click the
## resource in the Editor and click "Make Unique". Otherwise it will change it for every single instance of this file
@export var count: int = 1
