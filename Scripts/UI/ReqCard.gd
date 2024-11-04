extends HBoxContainer
class_name ReqCard

@onready var description: RichTextLabel = $description
@onready var status: Label = $status


func set_text(new_text: String) -> void:
	if new_text:
		description.clear()
		description.add_text(new_text)


func set_status(new_status: String) -> void:
	if new_status:
		status.text = new_status
