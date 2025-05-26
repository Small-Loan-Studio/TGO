@tool
extends DialogicLayoutLayer

## A layer that allows showing up to 10 choices.
## Choices are positioned in the center of the screen.

@export_group("Text")
@export_subgroup('Font')
@export var font_use_global: bool = true
@export_file('*.ttf', '*.tres') var font_custom: String = ""
@export_subgroup('Size')
@export var font_size_use_global: bool = true
@export var font_size_custom: int = 16
@export_subgroup('Color')
@export var text_color_use_global: bool = true
@export var text_color_custom: Color = Color.WHITE
@export var text_color_pressed: Color = Color.WHITE
@export var text_color_hovered: Color = Color.GRAY
@export var text_color_disabled: Color = Color.DARK_GRAY
@export var text_color_focused: Color = Color.WHITE

@export_group('Boxes')
@export_subgroup('Panels')
@export_file('*.tres') var boxes_stylebox_normal: String = "res://addons/dialogic/Modules/DefaultLayoutParts/Layer_VN_Choices/choice_panel_normal.tres"
@export_file('*.tres') var boxes_stylebox_hovered: String = "res://addons/dialogic/Modules/DefaultLayoutParts/Layer_VN_Choices/choice_panel_hover.tres"
@export_file('*.tres') var boxes_stylebox_pressed: String = ""
@export_file('*.tres') var boxes_stylebox_disabled: String = ""
@export_file('*.tres') var boxes_stylebox_focused: String = "res://addons/dialogic/Modules/DefaultLayoutParts/Layer_VN_Choices/choice_panel_focus.tres"
@export_subgroup('Modulate')
@export_subgroup('Size & Position')
@export var boxes_v_separation: int = 10
@export var boxes_fill_width: bool = true
@export var boxes_min_size: Vector2 = Vector2()

@export_group('Sounds')
@export_range(-80, 24, 0.01) var sounds_volume: float = -10
@export_file("*.wav", "*.ogg", "*.mp3") var sounds_pressed: String = "res://addons/dialogic/Example Assets/sound-effects/typing1.wav"
@export_file("*.wav", "*.ogg", "*.mp3") var sounds_hover: String = "res://addons/dialogic/Example Assets/sound-effects/typing2.wav"
@export_file("*.wav", "*.ogg", "*.mp3") var sounds_focus: String = "res://addons/dialogic/Example Assets/sound-effects/typing4.wav"

## Portrait text box info

enum Alignments {LEFT, CENTER, RIGHT}
enum LimitedAlignments {LEFT=0, RIGHT=1}

@export_group('Text')
@export_subgroup("Text")
@export var text_alignment: Alignments = Alignments.LEFT
@export_subgroup('Size')
@export var text_use_global_size: bool = true
@export var text_custom_size: int = 15
@export_subgroup('Color')
@export var text_use_global_color: bool = true
@export var text_custom_color: Color = Color.WHITE
@export_subgroup('Fonts')
@export var use_global_fonts: bool = true
@export_file('*.ttf', '*.tres') var custom_normal_font: String = ""
@export_file('*.ttf', '*.tres') var custom_bold_font: String = ""
@export_file('*.ttf', '*.tres') var custom_italic_font: String = ""
@export_file('*.ttf', '*.tres') var custom_bold_italic_font: String = ""

@export_group('Name Label')
@export_subgroup("Color")
enum NameLabelColorModes {GLOBAL_COLOR, CHARACTER_COLOR, CUSTOM_COLOR}
@export var name_label_color_mode: NameLabelColorModes = NameLabelColorModes.GLOBAL_COLOR
@export var name_label_custom_color: Color = Color.WHITE
@export_subgroup("Behaviour")
@export var name_label_alignment: Alignments = Alignments.LEFT
@export var name_label_hide_when_no_character: bool = false
@export_subgroup("Font & Size")
@export var name_label_use_global_size: bool = true
@export var name_label_custom_size: int = 15
@export var name_label_use_global_font: bool = true
@export_file('*.ttf', '*.tres') var name_label_customfont: String = ""

@export_group('Box')
@export_subgroup("Box")
@export_file('*.tres') var box_panel: String = this_folder.path_join("default_stylebox.tres")
@export var box_modulate_global_color: bool = true
@export var box_modulate_custom_color: Color = Color(0.47247135639191, 0.31728461384773, 0.16592600941658)
@export var box_size: Vector2 = Vector2(600, 160)
@export var box_distance: int = 25

@export_group('Portrait')
@export_subgroup('Portrait')
@export var portrait_stretch_factor: float = 0.3
@export var portrait_position: LimitedAlignments = LimitedAlignments.LEFT
@export var portrait_bg_modulate: Color = Color(0, 0, 0, 0.5137255191803)

func get_choices() -> VBoxContainer:
	return %Choices


func get_button_sound() -> DialogicNode_ButtonSound:
	return %DialogicNode_ButtonSound


## Method that applies all exported settings
func _apply_export_overrides() -> void:
	# apply text settings
	var layer_theme: Theme = Theme.new()

	# font
	if font_use_global and get_global_setting(&'font', false):
		layer_theme.set_font(&'font', &'Button', load(get_global_setting(&'font', '') as String) as Font)
	elif ResourceLoader.exists(font_custom):
		layer_theme.set_font(&'font', &'Button', load(font_custom) as Font)

	# font size
	if font_size_use_global:
		layer_theme.set_font_size(&'font_size', &'Button', get_global_setting(&'font_size', font_size_custom) as int)
	else:
		layer_theme.set_font_size(&'font_size', &'Button', font_size_custom)

	# font color
	if text_color_use_global:
		layer_theme.set_color(&'font_color', &'Button', get_global_setting(&'font_color', text_color_custom) as Color)
	else:
		layer_theme.set_color(&'font_color', &'Button', text_color_custom)

	layer_theme.set_color(&'font_pressed_color', &'Button', text_color_pressed)
	layer_theme.set_color(&'font_hover_color', &'Button', text_color_hovered)
	layer_theme.set_color(&'font_disabled_color', &'Button', text_color_disabled)
	layer_theme.set_color(&'font_pressed_color', &'Button', text_color_pressed)
	layer_theme.set_color(&'font_focus_color', &'Button', text_color_focused)


	# apply box settings
	if ResourceLoader.exists(boxes_stylebox_normal):
		var style_box: StyleBox = load(boxes_stylebox_normal)
		layer_theme.set_stylebox(&'normal', &'Button', style_box)
		layer_theme.set_stylebox(&'hover', &'Button', style_box)
		layer_theme.set_stylebox(&'pressed', &'Button', style_box)
		layer_theme.set_stylebox(&'disabled', &'Button', style_box)
		layer_theme.set_stylebox(&'focus', &'Button', style_box)

	if ResourceLoader.exists(boxes_stylebox_hovered):
		layer_theme.set_stylebox(&'hover', &'Button', load(boxes_stylebox_hovered) as StyleBox)

	if ResourceLoader.exists(boxes_stylebox_pressed):
		layer_theme.set_stylebox(&'pressed', &'Button', load(boxes_stylebox_pressed) as StyleBox)
	if ResourceLoader.exists(boxes_stylebox_disabled):
		layer_theme.set_stylebox(&'disabled', &'Button', load(boxes_stylebox_disabled) as StyleBox)
	if ResourceLoader.exists(boxes_stylebox_focused):
		layer_theme.set_stylebox(&'focus', &'Button', load(boxes_stylebox_focused) as StyleBox)

	get_choices().add_theme_constant_override(&"separation", boxes_v_separation)

	for child: Node in get_choices().get_children():
		if not child is DialogicNode_ChoiceButton:
			continue
		var choice: DialogicNode_ChoiceButton = child as DialogicNode_ChoiceButton

		if boxes_fill_width:
			choice.size_flags_horizontal = Control.SIZE_FILL
		else:
			choice.size_flags_horizontal = Control.SIZE_SHRINK_CENTER

		choice.custom_minimum_size = boxes_min_size

	set(&'theme', layer_theme)

	# apply sound settings
	var button_sound: DialogicNode_ButtonSound = get_button_sound()
	button_sound.volume_db = sounds_volume
	button_sound.sound_pressed = load(sounds_pressed)
	button_sound.sound_hover = load(sounds_hover)
	button_sound.sound_focus = load(sounds_focus)
	
	
	
	
	## Portrait settings start here
	var text_size: int = text_custom_size
	if text_use_global_size:
		text_size = get_global_setting(&'font_size', text_custom_size)

	var text_color: Color = text_custom_color
	if text_use_global_color:
		text_color = get_global_setting(&'font_color', text_custom_color)

	var normal_font: String = custom_normal_font
	if use_global_fonts and ResourceLoader.exists(get_global_setting(&'font', '') as String):
		normal_font = get_global_setting(&'font', '')

	## BOX SETTINGS
	var panel: PanelContainer = %Panel
	var portrait_panel: Panel = %PortraitPanel
	if box_modulate_global_color:
		panel.self_modulate = get_global_setting(&'bg_color', box_modulate_custom_color)
	else:
		panel.self_modulate = box_modulate_custom_color
	panel.size = box_size
	panel.position = Vector2(-box_size.x/2, -box_size.y-box_distance)
	portrait_panel.size_flags_stretch_ratio = portrait_stretch_factor

	var stylebox: StyleBoxFlat = load(box_panel)
	panel.add_theme_stylebox_override(&'panel', stylebox)

	## PORTRAIT SETTINGS
	var portrait_background_color: ColorRect = %PortraitBackgroundColor
	portrait_background_color.color = portrait_bg_modulate

	portrait_panel.get_parent().move_child(portrait_panel, portrait_position)

	## NAME LABEL SETTINGS
	var name_label: DialogicNode_NameLabel = %DialogicNode_NameLabel
	if name_label_use_global_size:
		name_label.add_theme_font_size_override(&"font_size", get_global_setting(&'font_size', name_label_custom_size) as int)
	else:
		name_label.add_theme_font_size_override(&"font_size", name_label_custom_size)

	var name_label_font: String = name_label_customfont
	if name_label_use_global_font and ResourceLoader.exists(get_global_setting(&'font', '') as String):
		name_label_font = get_global_setting(&'font', '')
	if !name_label_font.is_empty():
		name_label.add_theme_font_override(&'font', load(name_label_font) as Font)

	name_label.use_character_color = false
	match name_label_color_mode:
		NameLabelColorModes.GLOBAL_COLOR:
			name_label.add_theme_color_override(&"font_color", get_global_setting(&'font_color', name_label_custom_color) as Color)
		NameLabelColorModes.CUSTOM_COLOR:
			name_label.add_theme_color_override(&"font_color", name_label_custom_color)
		NameLabelColorModes.CHARACTER_COLOR:
			name_label.use_character_color = true

	name_label.horizontal_alignment = name_label_alignment as HorizontalAlignment
	name_label.hide_when_empty = name_label_hide_when_no_character
