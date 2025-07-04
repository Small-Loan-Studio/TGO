class_name StateChange
extends RefCounted

var next_state: State
var ctx: Variant


func _to_string() -> String:
	if next_state == null:
		return "[null]"

	return "[-> %s(%s)]" % [next_state.name, ctx]


static func mk(ns: State, st_ctx: Variant = null) -> StateChange:
	var sc := StateChange.new()
	sc.next_state = ns
	sc.ctx = st_ctx
	return sc
