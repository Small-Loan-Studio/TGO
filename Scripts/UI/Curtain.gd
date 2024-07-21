class_name Curtain
extends ColorRect

## Indicates the requested fade was completed. Parameter indicates if the final state
## is opaque or not.
signal fade_complete(opaque: bool)

const IN_COLOR = Color.WHITE
const OUT_COLOR = Color(255, 255, 255, 0)

func fade_in(fade_time: float) -> Signal:
	_do_fade(IN_COLOR, fade_time)
	return fade_complete

func fade_out(fade_time: float) -> Signal:
	_do_fade(OUT_COLOR, fade_time)
	return fade_complete

func _do_fade(tgt: Color, fade_time: float) -> void:
	if fade_time > 0:
		var tween := get_tree().create_tween()
		tween.tween_property(self, 'modulate', tgt, fade_time)
		await tween.finished
	else:
		modulate = tgt
	fade_complete.emit(IN_COLOR == tgt)
