class_name RichTextButton
extends Button

@onready var label: RichTextLabel = $RTL
var openTags: String = ""
var closeTags: String = ""
var labelText: String = "Default"

func _ready()->void:
	#update_button()
	pass

func update_button()->void:
	label.parse_bbcode("%s %s %s" % [openTags, labelText, closeTags])
	#custom_minimum_size = Vector2(label.get_content_width(),label.get_content_height())

func set_button_size(width: float, length: float) -> void:
	custom_minimum_size = Vector2(width,length)

func set_rich_text(nText: String)->void:
	labelText = nText
	update_button()

func set_text_color(color: String)->void: # color is hexcode format XXXXXX
	openTags = (openTags + "[color=#%s]" % [color])
	closeTags = "[/color]" + closeTags

func set_strikethrough()->void:
	openTags = openTags + "[s]"
	closeTags = "[/s]" + closeTags

func clear_strikethrough()->void:
	openTags = openTags.replace("[s]", "")
	closeTags = closeTags.replace("[/s]","")

func set_italics()->void:
	openTags = openTags + "[i]"
	closeTags = "[/i]" + closeTags

func clear_italics()->void:
	openTags = openTags.replace("[i]", "")
	closeTags = closeTags.replace("[/i]", "")
