@tool
class_name SimpleSwitchConfig
extends SwitchConfig

@export var track_variable: String = ""
@export var sensor_size: Vector2

@export_category("Visual Feedback")
@export var feedback_enabled := false:
	set(value):
		feedback_enabled = value
		_sync_feedback()

@export var default_color := Color.GRAY
@export var active_color := Color.DARK_GREEN

var _delegate: Node
var _switch_poly: Polygon2D
var _switch_shape: CollisionShape2D

func _ready() -> void:
	super()

	_switch = $Switch
	_switch_poly = $Switch/Polygon2D
	_switch_shape = $Switch/CollisionShape2D
	_delegate = $SignalDelegate
	if !Engine.is_editor_hint():
		_delegate.configure(self, _switch_poly)

	_sync_feedback()

	_switch_poly.color = default_color
	var x := sensor_size.x / 2
	var y := sensor_size.y / 2
	_switch_poly.polygon = [
		Vector2(-x, -y),
		Vector2(x, -y),
		Vector2(x, y),
		Vector2(-x, y),
	]
	var rs2d := RectangleShape2D.new()
	rs2d.size = sensor_size
	_switch_shape.shape = rs2d

func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		_switch_poly.visible = feedback_enabled
		return

	if track_variable != "":
		# TODO: this is probably not super performant but good enough for now
		_delegate._set_activation(Dialogic.VAR.get_variable(track_variable))

func _sync_feedback() -> void:
	if _switch_poly != null:
		_switch_poly.visible = feedback_enabled