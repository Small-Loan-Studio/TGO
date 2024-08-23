@tool
extends Node2D

@export var item: Item:
	set(value):
		item = value
		# Update Sprite Icon if our Item Resource is changed in the Editor
		if sprite:
			sprite.texture = item.icon
		update_configuration_warnings()

@export var quantity: int:
	set(value):
		quantity = value
		update_configuration_warnings()

@export var interactable_radius: int = 1:
	set(value):
		interactable_radius = value
		if collision_shape:
			collision_shape.shape.radius = interactable_radius
		update_configuration_warnings()

var _stack: ItemStack

@onready var sprite := $Sprite2D
@onready var interactable := $Interactable
@onready var collision_shape := $Interactable/CollisionShape2D

func _ready() -> void:
	sprite.texture = item.icon
	collision_shape.radius = interactable_radius
	interactable.set_collision_layer_value(2, true)

	# Create our Action for the Interactable
	var action := InteractablePickup.new()
	_stack = ItemStack.new()
	_stack.item = item
	_stack.quantity = quantity
	action.dest_path = self.get_path()
	action.item = _stack
	interactable.actions.append(action)


func _get_configuration_warnings() -> PackedStringArray:
	var errors: Array[String] = []
	if !item:
		errors.append("Item Scene requires an Item resource to be attached in the Editor")
	if item && quantity > item.stack_size:
		errors.append("Item quantity cannot be higher than the max stack size of the Item")
	elif quantity < 1:
		errors.append("Item quantity cannot be lower than 1")
	if interactable_radius < 0:
		errors.append("Interactable radius is set to 0. This is probably unattended")
	return errors
