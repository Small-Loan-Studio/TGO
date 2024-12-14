@tool
class_name ObjectsHelperSwitchDetails
extends VBoxContainer

const SWITCH_SCENE = preload("res://Scenes/Components/SimpleSwitch.tscn")
const TMPL_NONE = "None"
const TMPL_TOGGLE_BOOL = "Toggle Boolean"
const TMPL_INSTANT_BOOL = "Autorelease Boolean"
const TMPL_SET_VAR = "Set Variable"
const COND_NONE = 0
const COND_PLAYER_HAS_ITEM = 1
const COND_OTHER_HAS_ITEM = 2
const COND_VARIABLE = 3
const COND_QUEST = 4

var _all_condition_elements: Array[Control]

@onready var switch_name: LineEdit = $NameHBox/Margin/Name
@onready var sensor_size_x: SpinBox = $SizeHBox/Margin/SwitchSizeX
@onready var sensor_size_y: SpinBox = $SizeHBox/Margin3/SwitchSizeY
@onready var single_fire: CheckBox = $SingleFire
@onready var visible_checkbox: CheckBox = $Visual
@onready var color_margin := $ColorMargin
@onready var default_color: ColorPickerButton = $ColorMargin/ColorHBox/DefaultColor
@onready var active_color: ColorPickerButton = $ColorMargin/ColorHBox/ActiveColor
@onready var template_dropdown: OptionButton = $BehaviorHBox/OptionButton
@onready var variable_margin := $VariableMargin
@onready var behavior_var_dropdown: OptionButton = %BehaviorVariableDropdown
@onready var toggle_desc := $VariableMargin/VariableVBox/ToggleDesc
@onready var autorelease_desc := $VariableMargin/VariableVBox/AutoreleaseDesc

# condition template sections
@onready var condition_margin: MarginContainer = $ConditionConfig
@onready var inventory_group := $ConditionConfig/VBox/InventoryID
@onready var item_group := $ConditionConfig/VBox/Item
@onready var var_group := $ConditionConfig/VBox/Variable
@onready var var_value_group := $ConditionConfig/VBox/Variable/ValueHBox
@onready var quest_group := $ConditionConfig/VBox/Quest
@onready var quest_state_group := $ConditionConfig/VBox/Quest/StateHBox

@onready var condition_dropdown: OptionButton = %ConditionDropdown
@onready var inventory_id: LineEdit = %InventoryIDEdit
@onready var item_select_dropdown: OptionButton = %ItemSelectDropdown
@onready var condition_var_dropdown: OptionButton = %ConditionVariableDropdown
@onready var condition_var_value_bool: CheckButton = %ConditionVarBoolValue
@onready var condition_var_value_bool_string: Label = %ConditionVarBoolString
@onready var condition_var_value_generic: LineEdit = %ConditionVarGenericValue
@onready var condition_quest_id_dropdown: OptionButton = %QuestIDDropdown
@onready var condition_quest_state: OptionButton = %QuestStateDropdown


func _ready() -> void:
	_all_condition_elements = [

	]


func _on_visual_toggled(is_on: bool) -> void:
	if is_on:
		color_margin.show()
	else:
		color_margin.hide()


func _get_template() -> String:
	var index := template_dropdown.selected
	return template_dropdown.get_item_text(index)


func _get_variable() -> String:
	var index := behavior_var_dropdown.selected
	return behavior_var_dropdown.get_item_text(index)


func _on_template_selected(index: int) -> void:
	var selection := template_dropdown.get_item_text(index)

	match selection:
		TMPL_NONE:
			variable_margin.hide()
			toggle_desc.hide()
			autorelease_desc.hide()

		TMPL_TOGGLE_BOOL:
			variable_margin.show()
			toggle_desc.show()
			autorelease_desc.hide()
			behavior_var_dropdown.clear()
			for k in _get_bool_variables():
				behavior_var_dropdown.add_item(k)

		TMPL_INSTANT_BOOL:
			variable_margin.show()
			toggle_desc.hide()
			autorelease_desc.show()
			behavior_var_dropdown.clear()
			for k in _get_bool_variables():
				behavior_var_dropdown.add_item(k)

		TMPL_SET_VAR:
			variable_margin.show()
			toggle_desc.hide()
			autorelease_desc.hide()
			behavior_var_dropdown.clear()
			for kv: Array in _list_variables_and_type():
				var k: String = kv[0]
				behavior_var_dropdown.add_item(k)

		_:
			printerr("Unexpected selection: %s" % [selection])


func _get_bool_variables() -> Array[String]:
	var res: Array[String] = []
	for kv: Array in _list_variables_and_type():
		var k: String = kv[0]
		var tk: Variant.Type = kv[1]
		if tk == TYPE_BOOL:
			res.push_back(k)
	return res


func _ersatz_dialogic_get_var(path: String) -> Variant:
	var parts := path.split(".")

	var folder: Dictionary = ProjectSettings.get_setting("dialogic/variables", {}).duplicate(true)
	while len(parts) > 1:
		var dict_name: String = parts[0]
		parts = parts.slice(1)
		folder = folder[dict_name]

	var v: Variant = folder[parts[0]]
	return [v, typeof(v)]


func _list_variables_and_type() -> Array[Array]:
	var var_dict: Dictionary = ProjectSettings.get_setting("dialogic/variables", {}).duplicate(true)
	return _list_variables_and_type_helper("", var_dict)


func _list_variables_and_type_helper(path_prefix: String, var_dict: Dictionary) -> Array[Array]:
	var res: Array[Array] = []

	for k: String in var_dict.keys():
		var v: Variant = var_dict[k]

		match typeof(v):
			TYPE_DICTIONARY:
				var next_prefix := "%s%s." % [path_prefix, k]
				res += _list_variables_and_type_helper(next_prefix, v)
			_:
				res.push_back(["%s%s" % [path_prefix, k], typeof(v)])

	return res


func build() -> SimpleSwitchConfig:
	var scn: SimpleSwitchConfig = SWITCH_SCENE.instantiate()

	scn.single_fire = single_fire.button_pressed
	match _get_template():
		TMPL_TOGGLE_BOOL:
			scn.track_variable = _get_variable()
			var set_effect := ConditionalEffect.new()
			var var_condition := DialogicVarCondition.new()
			var_condition.variable_name = _get_variable()
			var_condition.check_type = Enums.CheckOp.EQ
			var_condition.check_value = "true"

			set_effect.condition = [var_condition]

			var was_true := SetVarEffect.new()
			was_true.variable_name = _get_variable()
			was_true.new_value = "false"
			set_effect.true_path = [was_true]

			var was_false := SetVarEffect.new()
			was_false.variable_name = _get_variable()
			was_false.new_value = "true"
			set_effect.false_path = [was_false]

			scn.on_pressed_effects = [set_effect]

		TMPL_INSTANT_BOOL:
			var set_effect := SetVarEffect.new()
			set_effect.variable_name = _get_variable()
			set_effect.new_value = "true"
			scn.on_pressed_effects = [set_effect]

			var unset_effect := SetVarEffect.new()
			unset_effect.variable_name = _get_variable()
			unset_effect.new_value = "false"
			scn.on_released_effects = [unset_effect]

		TMPL_SET_VAR:
			assert(false, "Not implemented")

	scn.sensor_size = Vector2(sensor_size_x.value, sensor_size_y.value)
	scn.feedback_enabled = visible_checkbox.button_pressed
	if visible_checkbox.button_pressed:
		scn.default_color = default_color.color
		scn.active_color = active_color.color
		scn.z_index = -1

	return scn


func reset() -> void:
	variable_margin.hide()
	toggle_desc.hide()
	autorelease_desc.hide()
	template_dropdown.select(0)
	behavior_var_dropdown.clear()
	visible_checkbox.button_pressed = false
	color_margin.hide()
	condition_margin.hide()


func _setup_cond_none() -> void:
	condition_margin.hide()
	_hide_all_cond_groups()


func _hide_all_cond_groups() -> void:
	inventory_group.hide()
	item_group.hide()
	var_group.hide()
	quest_group.hide()


func _setup_player_has_item() -> void:
	_hide_all_cond_groups()

	_populate_item_ids()

	item_group.show()
	condition_margin.show()


func _setup_other_has_item() -> void:
	_hide_all_cond_groups()

	_populate_item_ids()

	inventory_id.text = ""
	inventory_group.show()
	item_group.show()
	condition_margin.show()


func _setup_cond_variable() -> void:
	_hide_all_cond_groups()

	_populate_cond_variable_list()

	var_group.show()
	var_value_group.hide()
	condition_margin.show()


func _on_condition_selected(index:int) -> void:
	match index:
		COND_NONE:
			_setup_cond_none()

		COND_PLAYER_HAS_ITEM:
			_setup_player_has_item()

		COND_OTHER_HAS_ITEM:
			_setup_other_has_item()

		COND_VARIABLE:
			_setup_cond_variable()

		COND_QUEST:
			pass

		_:
			printerr("Hit unexpected condition case: ", index)
			_setup_cond_none()


func _populate_item_ids() -> void:
	var item_ids := Item.all_ids()
	item_select_dropdown.clear()
	for id in item_ids:
		item_select_dropdown.add_item(id)


func _populate_cond_variable_list() -> void:
	condition_var_dropdown.clear()
	condition_var_dropdown.add_item("")
	for kv: Array in _list_variables_and_type():
				var k: String = kv[0]
				condition_var_dropdown.add_item(k)
	condition_dropdown.select(0)

func _on_condition_var_selected(index: int) -> void:
	var var_name := condition_var_dropdown.get_item_text(index).strip_edges()
	if var_name == "":
		var_value_group.hide()
		return

	var var_info: Variant = _ersatz_dialogic_get_var(var_name)

	match var_info[1]:
		TYPE_STRING:
			print("string")

		TYPE_BOOL:
			print("bool")

		TYPE_FLOAT:
			print("float")