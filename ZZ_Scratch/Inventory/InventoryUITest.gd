class_name InventoryUITest
extends Node2D

@onready var _controller: InputController = %Input
@onready var _inv_control: ItemSelectControl = %ItemSelectControl

@export var _items: Array[Item] = []

func _ready() -> void:
	call_deferred("_setup")

func _setup() -> void:
	print("_controller: ", typeof(_controller))
	print("_controller: ", _controller)
	print("_controller.setup: ", _controller._setup)
	_controller.setup([
		Enums.InputAction.LEFT,
		Enums.InputAction.RIGHT,
		Enums.InputAction.UP,
		Enums.InputAction.DOWN,
	],
	[
		Enums.InputAction.LEFT,
		Enums.InputAction.RIGHT,
		Enums.InputAction.UP,
		Enums.InputAction.DOWN,
		Enums.InputAction.DEFAULT,
		Enums.InputAction.SECONDARY,
		Enums.InputAction.INTERACT_CANCEL,
		Enums.InputAction.SPRINT,
		Enums.InputAction.MENU,
		Enums.InputAction.LEFT_ITEM,
		Enums.InputAction.RIGHT_ITEM,
	])

	_inv_control.setup(4, 1, _controller, _items, [Enums.InputAction.LEFT, Enums.InputAction.RIGHT])


func _process(_delta: float) -> void:
	pass