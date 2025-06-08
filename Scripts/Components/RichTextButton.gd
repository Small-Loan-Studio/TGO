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
	var idx: int = openTags.find("[color")
	if idx >= 0:
		openTags = openTags.erase(idx, 15)
	closeTags = closeTags.replace("[/color]","")
	
	openTags = (openTags + "[color=#%s]" % [color])
	closeTags = "[/color]" + closeTags
	
	update_button()

func remove_text_color()->void:
	var idx: int = openTags.find("[color")
	if idx >= 0:
		openTags = openTags.erase(idx, 15)
	closeTags = closeTags.replace("[/color]", "")
	
	update_button()

func set_strikethrough()->void:
	openTags = openTags + "[s]"
	closeTags = "[/s]" + closeTags
	
	update_button()

func clear_strikethrough()->void:
	openTags = openTags.replace("[s]", "")
	closeTags = closeTags.replace("[/s]","")
	update_button()

func set_italics()->void:
	openTags = openTags + "[i]"
	closeTags = "[/i]" + closeTags
	update_button()

func clear_italics()->void:
	openTags = openTags.replace("[i]", "")
	closeTags = closeTags.replace("[/i]", "")
	update_button()

func set_bold()->void:
	openTags = openTags + "[b]"
	closeTags = "[/b]" + closeTags
	update_button()

func clear_bold()->void:
	openTags = openTags.replace("[b]", "")
	closeTags = closeTags.replace("[/b]", "")
	update_button()

func focus_color()->void:
	set_bold()
	set_text_color("FFFFFF")

func exit_focus_color()->void:
	clear_bold()
	set_text_color("BBBBBB")
