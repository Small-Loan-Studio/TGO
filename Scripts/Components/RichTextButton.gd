class_name RichTextButton
extends Button

var _open_tags: String = ""
var _close_tags: String = ""
var _label_text: String = "Default"

@onready var label: RichTextLabel = $HBoxContainer/RTL
@onready var arrow: TextureRect = %Arrow
@onready var bar: ColorRect = $HBoxContainer/RTL/Strikethrough


func update_button() -> void:
	label.parse_bbcode("%s %s %s" % [_open_tags, _label_text, _close_tags])


func set_button_size(width: float, length: float) -> void:
	custom_minimum_size = Vector2(width, length)


func set_rich_text(new_text: String) -> void:
	_label_text = new_text
	update_button()


func set_text_color(color: String) -> void:  # color is hexcode format XXXXXX
	var idx: int = _open_tags.find("[color")
	if idx >= 0:
		_open_tags = _open_tags.erase(idx, 15)
	_close_tags = _close_tags.replace("[/color]", "")

	_open_tags = (_open_tags + "[color=#%s]" % [color])
	_close_tags = "[/color]" + _close_tags
	update_button()


func remove_text_color() -> void:
	var idx: int = _open_tags.find("[color")
	if idx >= 0:
		_open_tags = _open_tags.erase(idx, 15)
	_close_tags = _close_tags.replace("[/color]", "")
	update_button()


func set_strikethrough() -> void:
	bar.visible = true
	# _open_tags = _open_tags + "[s]"
	# _close_tags = "[/s]" + _close_tags

	update_button()


func clear_strikethrough() -> void:
	bar.visible = false
	# _open_tags = _open_tags.replace("[s]", "")
	# _close_tags = _close_tags.replace("[/s]", "")
	update_button()


func set_italics() -> void:
	_open_tags = _open_tags + "[i]"
	_close_tags = "[/i]" + _close_tags
	update_button()


func clear_italics() -> void:
	_open_tags = _open_tags.replace("[i]", "")
	_close_tags = _close_tags.replace("[/i]", "")
	update_button()


func set_bold() -> void:
	_open_tags = _open_tags + "[b]"
	_close_tags = "[/b]" + _close_tags
	update_button()


func clear_bold() -> void:
	_open_tags = _open_tags.replace("[b]", "")
	_close_tags = _close_tags.replace("[/b]", "")
	update_button()


func focus_color() -> void:
	set_bold()
	set_text_color("FFFFFF")
	_show_arrow()


func exit_focus_color() -> void:
	clear_bold()
	set_text_color("BBBBBB")
	_hide_arrow()


func _show_arrow() -> void:
	arrow.modulate.a = 1


func _hide_arrow() -> void:
	arrow.modulate.a = 0
