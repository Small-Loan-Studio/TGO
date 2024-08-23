class_name Item
extends Resource

@export var id: int = -1
@export var name: String = ""
## Unused property currently, will be necessary later on probably
@export var type: Enums.ItemType
@export_multiline var description: String = ""
@export var stackable: bool = false
@export var stack_size: int = 1:
	set(value):
		if stack_size > 1 && !stackable:
			printerr("Item %s has a stack_size of %s but has not set stackable to true" % [name, stack_size])
			stack_size = 1
		else:
			stack_size = value

@export var icon: Texture2D

func _to_string() -> String:
	return name
