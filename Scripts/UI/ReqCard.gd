extends HBoxContainer
class_name ReqCard

@onready var text :RichTextLabel = $text
@onready var status :Label = $status

func set_text(new_text:String)->void:
	text.text = new_text
func set_status(new_status:String)->void:
	status.text = new_status
