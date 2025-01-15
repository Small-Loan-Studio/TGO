class_name DebugDialogicAdapters
extends HBoxContainer

var _debug_active: bool = false
@onready var _button: Button = $Button


func toggle_dialog() -> void:
	if(_debug_active):
		printerr("Unable to begin debugging")
	Dialogic.timeline_ended.connect(_on_timeline_ended)
	_debug_active = true
	_button.set_text("Debugging Dialogic")
	Dialogic.start("res://ZZ_Scratch/DialogicValidation/debugging_timeline.dtl")


func _on_timeline_ended() -> void:
	Dialogic.timeline_ended.disconnect(_on_timeline_ended)
	_debug_active = false
	_button.set_text("Debug Dialogic")
