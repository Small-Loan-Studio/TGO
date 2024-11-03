@tool
class_name SimpleSwitch
extends Switch

@export var track_variable: String = ""
@export var sensor_size: Vector2

@export_category("Visual Feedback")
@export var feedback_enabled := false
@export var default_color := Color.GRAY
@export var active_color := Color.DARK_GREEN

@onready var poly: Polygon2D = $Polygon2D
@onready var shape: CollisionShape2D = $CollisionShape2D


func _ready() -> void:
	poly.color = default_color
	var x := sensor_size.x / 2
	var y := sensor_size.y / 2
	poly.polygon = [
		Vector2(-x, -y),
		Vector2(x, -y),
		Vector2(x, y),
		Vector2(-x, y),
	]
	var rs2d := RectangleShape2D.new()
	rs2d.size = sensor_size
	shape.shape = rs2d


func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		poly.visible = feedback_enabled
		return

	if track_variable != "":
		# TODO: this is probably not super performant but good enough for now
		_set_activation(Dialogic.VAR.get_variable(track_variable))


func _on_triggered(_id: String, state: bool) -> void:
	_set_activation(state)


func _set_activation(state: bool) -> void:
	if state:
		poly.color = active_color
	else:
		poly.color = default_color
