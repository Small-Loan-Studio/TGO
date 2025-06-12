@tool

class_name Devin
extends Character

var _ak_helper: AKHelper


func _ready() -> void:
	super._ready()
	if Engine.is_editor_hint():
		return
	_ak_helper = AKHelper.new(self)
	stats.get_stat(Enums.Stat.HEALTH).stat_changed.connect(_on_health_change)


func _on_health_change() -> void:
	var value := stats.get_stat(Enums.Stat.HEALTH).value
	_ak_helper.send_param(AK.GAME_PARAMETERS.PLAYERHEALTH_RTPC, value as float)


func _process(delta: float) -> void:
	super._process(delta)

	if _audio_node != null:
		var cur_level := _level()
		if cur_level != null:
			var map_coords: Vector2i = cur_level.get_map_coords(global_position)
			if _last_reported != map_coords:
				_last_reported = map_coords
				var mat := _find_tile_mat(cur_level, map_coords)
				if mat != "":
					_audio_node.set_switch("GroundMaterialSwitch", mat)

	
var _last_reported := Vector2i.ZERO

func _level() -> LevelBase:
	var driver := Driver.instance()
	if driver != null:
		return driver.get_current_level()
	return null


func _find_tile_mat(level: LevelBase, map_coords: Vector2i) -> String:
	var tm: TileMap = level.tilemap
	var mat := ""
	for layer: int in range(tm.get_layers_count()):
		var td: TileData = tm.get_cell_tile_data(layer, map_coords)
		if td != null:
			var maybe_mat: Variant = td.get_custom_data("material")
			if maybe_mat != null:
				mat = maybe_mat as String
	return mat