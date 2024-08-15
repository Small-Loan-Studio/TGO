extends PanelContainer

class_name Card
@onready var photo_holder : TextureRect = $HBoxContainer/photo
@onready var label_holder : Label  = $HBoxContainer/VBoxContainer/Label
@onready var detail_holder : RichTextLabel = $HBoxContainer/VBoxContainer/details

func set_details(label:String,details:String,photo:Texture2D)->void:
	label_holder.text = label
	photo_holder.texture = photo
	detail_holder.text = details
	
	return
