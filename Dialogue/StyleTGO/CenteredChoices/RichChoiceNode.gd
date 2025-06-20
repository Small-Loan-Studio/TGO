extends DialogicNode_ChoiceButton


## Called when the text changes.
func _set_text_changed(new_text: String) -> void:
	for entry: Dictionary in Dialogic.History.get_simple_history():
		if entry['event_type'] == 'Choice':
			if entry['text'] == new_text:
				text_node.set_strikethrough()
	text_node.set_rich_text(new_text)
	text_node.set_button_size(get_size().x, get_size().y)
