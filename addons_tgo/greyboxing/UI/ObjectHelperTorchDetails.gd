@tool
class_name ObjectsHelperTorchDetails
extends VBoxContainer

const TORCH_SCENE = preload("res://Scenes/Components/Torch.tscn")
const DEFAULT_TEX = preload("res://Art/Stub/stub_torch.png")

@onready var _radius_spinner: SpinBox = %Radius
@onready var _sprite_check: CheckBox = %HasSprite
@onready var _height_spinner: SpinBox = %Height
@onready var _color_btn: ColorPickerButton = %Color
@onready var _energy_bar: HSlider = %Energy


func _on_has_sprite_toggled(toggled_on: bool) -> void:
	_height_spinner.editable = toggled_on


func has_display() -> bool:
	return _sprite_check.toggle_mode


func build() -> Torch:
	var scn: Torch = TORCH_SCENE.instantiate()
	scn._point_light_2d = scn.get_node("PointLight2D")
	scn._sprite_2d = scn.get_node("Sprite2D")
	scn._animated_sprite = scn.get_node("AnimatedSprite2D")
	scn.light_color = _color_btn.color
	scn.light_energy = _energy_bar.value

	if !has_display():
		scn.sprite_texture = null
		scn.sprite_frames = null
	else:
		scn.sprite_texture = DEFAULT_TEX
		scn.display_height = _height_spinner.value as int

	scn.light_size = _radius_spinner.value

	return scn


func reset() -> void:
	_radius_spinner.value = 1
	_sprite_check.toggle_mode = true
	_height_spinner.value = 0
