@tool
extends DialogicEvent
class_name DialogicTgoExprEvent

# Define properties of the event here

var expr: String = ""

func _execute() -> void:
	print("TgoExpr._execute(%s)" % [expr])
	if expr.begins_with('{TGO.'):
		dialogic.Expressions.execute_string(expr, null, true)
	else:
		printerr('[Dialogic] TGO call does not begin with TGO.')
	finish()


#region INITIALIZE
################################################################################
# Set fixed settings of this event
func _init() -> void:
	event_name = "TGO Expression"
	event_category = "Logic"
	set_default_color('Color6')



#endregion

#region SAVING/LOADING
################################################################################
func get_shortcode() -> String:
	return "tgo_expr"

func get_shortcode_parameters() -> Dictionary:
	return {
		"expr": {"property": "expr", "default": ""},
	}

# You can alternatively overwrite these 3 functions: to_text(), from_text(), is_valid_event()
#endregion


#region EDITOR REPRESENTATION
################################################################################

func build_event_editor() -> void:
	add_header_edit(
		"expr",
		ValueType.SINGLELINE_TEXT,
		{
			"left_text": "Execute TGO Logic"
		},
	)

#endregion
