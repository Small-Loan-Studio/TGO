class_name InteractMenu
extends Container

signal closed
signal opened

const InteractOptionScene: PackedScene = preload("./interact_option.tscn")

var actions: Array[Enums.ActionVerb]
var layout := InteractOption.LAYOUT_RIGHT
var options: Array[InteractOption]:
	get:
		var values: Array[InteractOption] = []
		for child in self._container.get_children():
			if child is InteractOption:
				values += [child]
		return values

var _container: BoxContainer = null

## Public


func collapse() -> void:
	self.hide()
	closed.emit()


func expand() -> void:
	self.show()
	opened.emit()


## Override


func _ready() -> void:
	collapse()
	_container = VBoxContainer.new()
	for action in self.actions:
		var option := InteractOptionScene.instantiate()
		option.label = Enums.action_verb_name(action)
		option.layout = layout
		option.symbol = Enums.input_action_symbol(Enums.InputAction.INTERACT)
		_container.add_child(option)
	self.add_child(_container)
