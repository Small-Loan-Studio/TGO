extends Label


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	var player := Driver.instance().player

	var txt := ""

	for st in player.stats.stats:
		txt += "%s: %d / %d\n" % [Enums.stat_name(st.typ), st.value, st.max_value]

	text = txt
