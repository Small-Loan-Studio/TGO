extends Control
class_name pop_up

@onready var text : Label = $PanelContainer/VBoxContainer/HBoxContainer/Label

func change_label_text(new_text:String)->void:
	text.text = new_text

func _on_close_pressed()->void:
	self.hide()
	return


func _on_ok_pressed()->void:
	self.hide()
	return
