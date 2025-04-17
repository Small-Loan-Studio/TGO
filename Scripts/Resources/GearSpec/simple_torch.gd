class_name SimpleTorch
extends GearSpec

const TORCH_SCENE = preload("res://Scenes/Components/Torch.tscn")

@export var light_color: Color = Color.WHITE


static func get_torch(c: Character) -> Torch:
	for child in c.get_children():
		if child is Torch:
			return child
	return null


static func add_torch(c: Character, color: Color) -> Torch:
	if SimpleTorch.get_torch(c) != null:
		printerr("torch already added")
		return null
	var torch_node := TORCH_SCENE.instantiate() as Torch
	c.add_child(torch_node)
	# configure the torch
	torch_node.light_color = color
	torch_node.light_size = 3
	torch_node.sprite_texture = null
	torch_node.sprite_frames = null
	torch_node.toggle(false)
	return torch_node


static func remove_torch(c: Character) -> void:
	var torch_node := SimpleTorch.get_torch(c)
	if torch_node == null:
		printerr("no torch attached")
		return
	c.remove_child(torch_node)
	torch_node.queue_free()


func on_equip(c: Character) -> void:
	SimpleTorch.add_torch(c, light_color)


func on_remove(c: Character) -> void:
	SimpleTorch.remove_torch(c)


func on_use(c: Character) -> void:
	var torch := SimpleTorch.get_torch(c)
	if torch != null:
		torch.toggle(!torch.is_lit())
	else:
		printerr("Expected to find torch, did not")


func save_state(c: Character) -> Dictionary:
	var torch := SimpleTorch.get_torch(c)
	if torch == null:
		return {}

	return {
		"active": torch.is_lit(),
		"energy": torch.light_energy,
		"color":
		[
			torch.light_color.r,
			torch.light_color.g,
			torch.light_color.b,
			torch.light_color.a,
		]
	}


func load_state(c: Character, data: Variant) -> void:
	# if we don't have any saved data it was a case where the player had
	# two equipped torches which suggests either bug or direct gear editing
	if len(data) == 0:
		return
	var torch := SimpleTorch.get_torch(c)

	if torch == null:
		printerr("Trying to restore torch state before equipped")
		return

	torch.toggle(data["active"])
	torch.light_energy = data["energy"]
	var saved_color := Color()
	saved_color.r = data["color"][0]
	saved_color.g = data["color"][0]
	saved_color.b = data["color"][0]
	saved_color.a = data["color"][0]
	torch.light_color = saved_color
