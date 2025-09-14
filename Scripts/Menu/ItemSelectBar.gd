class_name ItemSelectBar
extends VBoxContainer


@onready var _item_name: Label = %ItemName


var text: String:
	set(value):
		_item_name.text = value


func _ready() -> void:
	pass


func _process(_delta: float) -> void:
	pass
