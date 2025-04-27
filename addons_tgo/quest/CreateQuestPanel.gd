@tool
class_name QuestIDPanel
extends PanelContainer

## Fired when either the create or cancel button is pressed. Create will send
## a non-empty [quest_id, quest_title] to use, cancel will send an empty array.
signal completed(quest_data: Array[String])

var _in_err := false
var _all_ids: Array[String] = []

@onready var _id_edit: LineEdit = %IDEdit
@onready var _title_edit: LineEdit = %TitleEdit
@onready var _create_button := %QuestIDCreate
@onready var _err_label := %QuestIDErrLabel


func display(at_pos: Vector2) -> void:
	_all_ids = QuestManager.tool_all_ids()
	_id_edit.text = ""
	_check_err("")
	_id_edit.grab_focus()

	var x_off := size.x / 2
	var y_off := size.y / 2
	global_position = at_pos - Vector2(x_off, y_off)
	show()


func _on_cancel_pressed() -> void:
	var data: Array[String] = []
	completed.emit(data)
	hide()


func _on_create_pressed() -> void:
	if _in_err:
		return

	var title := _title_edit.text.strip_edges()
	if title == "":
		title = _id_edit.text.strip_edges()
	var data: Array[String] = [_id_edit.text.strip_edges(), title]
	completed.emit(data)
	hide()


func _on_id_edit_text_changed(prospective_id: String) -> void:
	_check_err(prospective_id)


func _on_id_edit_text_submitted(new_text: String) -> void:
	if !_check_err(new_text):
		_on_create_pressed()


func _check_err(prospective_id: String) -> bool:
	var txt := ""
	if prospective_id in _all_ids:
		txt = "ID already in use"
		_in_err = true
	elif prospective_id.strip_edges() == "":
		txt = "ID may not be empty"
		_in_err = true
	else:
		txt = ""
		_in_err = false
	_err_label.text = txt
	_create_button.disabled = _in_err
	return _in_err


func _process(_delta: float) -> void:
	if !visible:
		return
	if Input.is_action_just_pressed("ui_cancel"):
		_on_cancel_pressed()
		return
