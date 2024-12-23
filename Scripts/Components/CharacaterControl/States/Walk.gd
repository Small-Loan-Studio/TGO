extends State

var _ctx: StateMachine.CharacterContext

@export var idle_state: State

func run_tick(_delta: float) -> State:
	if _ctx.controller.get_vector() == Vector2.ZERO:
		return idle_state
	
	return null