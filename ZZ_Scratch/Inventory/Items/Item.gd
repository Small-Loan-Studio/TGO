@tool
extends Node2D

@export var item: Item
@export var quantity: int
@export var interactable_radius: int = 1

var _sprite: Sprite2D
var _circle: CircleShape2D
var _stack: ItemStack

func _ready() -> void:
	# Load our Sprite
	_sprite = Sprite2D.new()
	add_child(_sprite)
	_sprite.texture = item.icon
	
	# Create our Interactable and Collision
	var interactable := Interactable.new()
	add_child(interactable)
	var collision_shape := CollisionShape2D.new()
	_circle = CircleShape2D.new()
	_circle.radius = interactable_radius
	collision_shape.shape = _circle
	interactable.add_child(collision_shape)
	interactable.set_collision_layer_value(2, true)
	
	
	# Create our Action for the Interactable
	var action := InteractablePickup.new()
	_stack = ItemStack.new()
	_stack.item = item
	_stack.quantity = quantity
	action.dest_path = self.get_path()
	action.item = _stack
	interactable.actions.append(action)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		_sprite.texture = item.icon
		_circle.radius = interactable_radius
