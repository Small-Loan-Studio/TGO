class_name StateChange
extends RefCounted

var next_state: State
var ctx: Variant


static func mk(ns: State, st_ctx: Variant = null) -> StateChange:
	var sc := StateChange.new()
	sc.next_state = ns
	sc.ctx = st_ctx
	return sc
