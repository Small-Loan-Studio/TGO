class_name QuestDebugger
extends HBoxContainer

var _mgr: QuestManager


@onready var _status_group := $QuestStatus
@onready var _quest_dropdown: OptionButton = $QuestOption
@onready var _current_status: Label = $QuestStatus/CurrentQuestState
@onready var _next_state: OptionButton = $QuestStatus/MarginContainer/HBoxContainer/NewQuestState


func setup(quest_mgr: QuestManager) -> void:
	_mgr = quest_mgr
	_mgr.quest_updated.connect(_sync_quest)
	var ids := _mgr.get_all_quest_ids()
	ids.sort()

	for id in ids:
		_quest_dropdown.add_item(id)

	for state: Enums.QuestState in Enums.QuestState.values():
		_next_state.add_item(Enums.quest_state_name(state))


func _get_selected_state() -> Enums.QuestState:
	var cur_id := _next_state.get_selected_id()
	var cur_txt := _next_state.get_item_text(cur_id)
	return Enums.quest_state_from_str(cur_txt)


func _get_selected_quest() -> String:
	var cur_id := _quest_dropdown.get_selected_id()
	return _quest_dropdown.get_item_text(cur_id)


func _on_set_state_btn_pressed() -> void:
	var cur_quest_id := _get_selected_quest()
	if cur_quest_id == "":
		return
	var next_state := _get_selected_state()

	var quest := _mgr.quest_by_id(cur_quest_id)
	if quest.state == next_state:
		return

	quest.set_state(next_state)


func _on_quest_option_item_selected(idx: int) -> void:
	var quest_id := _quest_dropdown.get_item_text(idx)
	if quest_id == "":
		_status_group.hide()
		return
	_status_group.show()

	var quest := _mgr.quest_by_id(quest_id)
	_current_status.text = Enums.quest_state_name(quest.state)


func _sync_quest(_quest_id: String) -> void:
	# if the updated quest was selected this will refresh the active state;
	# otherwise we don't really care
	_on_quest_option_item_selected(_quest_dropdown.get_selected_id())