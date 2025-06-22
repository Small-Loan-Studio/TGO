class_name Enums
extends RefCounted

enum CheckOp {
	EXISTS,
	LT,
	LTE,
	EQ,
	GTE,
	GT,
}

enum TriggerFailure { ID_MASK, CONDITIONS }

enum Direction {
	NORTH,
	SOUTH,
	EAST,
	WEST,
	NORTH_EAST,
	NORTH_WEST,
	SOUTH_EAST,
	SOUTH_WEST,
}

enum DirectionMode { FOUR, EIGHT }

enum MoveMode {
	WALK,
	SPRINT,
	PUSH_PULL,
}

enum InputAction {
	UP,
	DOWN,
	LEFT,
	RIGHT,
	INTERACT,
	SPRINT,
	MENU,
	LEFT_ITEM,
	RIGHT_ITEM,
	EXAMINE,
}

enum LightLevel {
	OFF,
	NORMAL,
	BRIGHT,
	SPECIAL,
}

enum TimeOfDay {
	DAWN,
	DAY,
	DUSK,
	NIGHT,
}

enum AudioBus {
	MASTER,
	BACKGROUND_MUSIC,
	SOUND_EFFECTS,
}

enum ItemType {
	# Key or Quest items, essentials to story progression. Do not allow discarding of these
	KEY,
	# Things we can use or consume
	CONSUMABLE,
	# This might be stubbed out further in the future Items.Helmet, Items.Gloves, if we have those
	EQUIPPABLE,
}

enum GearSlot {
	LEFT,
	RIGHT,
}

enum TargetType {
	NONE,
	INTERACTABLE,
	MOVEABLE_BLOCK,
}

enum ActionVerb {
	DEFAULT,
	PICK_UP,
	TALK,
	PUSH_PULL,
	RELEASE,
	USE,
	EXAMINE,
	SPEAK,
	SHOW_ITEM,
	GIVE_ITEM,
}

const ACTION_VERB_NAMES = {
	ActionVerb.EXAMINE:   "Examine",
	ActionVerb.PICK_UP:   "Pick Up",
	ActionVerb.TALK:      "Talk",
	ActionVerb.USE:       "Use",
	ActionVerb.PUSH_PULL: "Grab",
	ActionVerb.RELEASE:   "Release",
	ActionVerb.DEFAULT:   "Interact",
	ActionVerb.SPEAK:     "Speak",
	ActionVerb.SHOW_ITEM: "Show Item",
	ActionVerb.GIVE_ITEM: "Give Item",
}

static func action_verb_name(av: ActionVerb) -> String:
	return ACTION_VERB_NAMES.get(av, "Interact")


static func action_verb_from_str(action_str: String) -> Enums.ActionVerb:
	for key: ActionVerb in ACTION_VERB_NAMES.keys():
		if action_str == ACTION_VERB_NAMES[key]:
			return key

	printerr("Unknown action verb: ", action_str)
	return ActionVerb.DEFAULT


enum QuestState { DORMANT, ACTIVE, FAILED, COMPLETED }
enum QuestConditionType { VARIABLE, INVENTORY }

enum Stat { HEALTH, STAMINA }

const AUDIO_BUS_INFO = {
	AudioBus.MASTER: [0, "Global"],
	AudioBus.BACKGROUND_MUSIC: [1, "Background Music"],
	AudioBus.SOUND_EFFECTS: [2, "Sound Effects"],
}

const DIRECTION_PUSH_PULL_AXIS := {
	Direction.NORTH: Vector2(0, 1),
	Direction.SOUTH: Vector2(0, 1),
	Direction.EAST: Vector2(1, 0),
	Direction.WEST: Vector2(1, 0),
}

const QUEST_STATE_NAME = {
	"dormant": QuestState.DORMANT,
	"active": QuestState.ACTIVE,
	"failed": QuestState.FAILED,
	"completed": QuestState.COMPLETED,
}

const STAT_NAME = {
	"Health": Stat.HEALTH,
	"Stamina": Stat.STAMINA,
}

# gdlint:ignore=class-variable-name
static var DIRECTION_VECTOR := {
	Direction.NORTH: Vector2(0, -1),
	Direction.SOUTH: Vector2(0, 1),
	Direction.EAST: Vector2(1, 0),
	Direction.WEST: Vector2(-1, 0),
	Direction.NORTH_EAST: Vector2(1, -1).normalized(),
	Direction.SOUTH_EAST: Vector2(1, 1).normalized(),
	Direction.NORTH_WEST: Vector2(-11, -1).normalized(),
	Direction.SOUTH_WEST: Vector2(-1, 1).normalized(),
}


static func direction_name(da: Direction) -> String:
	match da:
		Direction.NORTH:
			return "north"
		Direction.SOUTH:
			return "south"
		Direction.EAST:
			return "east"
		Direction.WEST:
			return "west"
		Direction.NORTH_EAST:
			return "northeast"
		Direction.NORTH_WEST:
			return "northwest"
		Direction.SOUTH_EAST:
			return "southeast"
		Direction.SOUTH_WEST:
			return "southwest"
	assert(false, "Unexpected Direction value: " + str(da))
	return "north"


static func direction_vector(da: Direction) -> Vector2:
	return DIRECTION_VECTOR[da]


static func direction_push_pull_axis(d: Direction) -> Vector2:
	return DIRECTION_PUSH_PULL_AXIS[d]


static func input_action_name(ia: InputAction) -> String:
	match ia:
		InputAction.UP:
			return "up"
		InputAction.DOWN:
			return "down"
		InputAction.LEFT:
			return "left"
		InputAction.RIGHT:
			return "right"
		InputAction.INTERACT:
			return "interact"
		InputAction.SPRINT:
			return "sprint"
		InputAction.MENU:
			return "load_menu"
		InputAction.LEFT_ITEM:
			return "left_item"
		InputAction.RIGHT_ITEM:
			return "right_item"
	assert(false, "Invalid Input action: " + str(ia))
	return ""


static func input_action_symbol_texture(ia: InputAction) -> CompressedTexture2D:
	match ia:
		InputAction.EXAMINE:
			return preload("res://Art/interacting/symbol_square.png")
		InputAction.INTERACT:
			return preload("res://Art/interacting/symbol_cross.png")
		_:
			return null


static func time_of_day_name(tod: TimeOfDay) -> String:
	match tod:
		TimeOfDay.DAWN:
			return "dawn"
		TimeOfDay.DAY:
			return "day"
		TimeOfDay.DUSK:
			return "dusk"
		TimeOfDay.NIGHT:
			return "night"
	assert(false, "Invalid time of day: " + str(tod))
	return ""


static func time_of_day_from_str(time_str: String) -> TimeOfDay:
	time_str = time_str.to_lower().strip_edges()
	match time_str:
		"dawn":
			return TimeOfDay.DAWN
		"day":
			return TimeOfDay.DAY
		"dusk":
			return TimeOfDay.DUSK
		"night":
			return TimeOfDay.NIGHT
		_:
			printerr("Invalid time of tay: %s" % [time_str])
			return TimeOfDay.DAY


static func gear_slot_name(slot: GearSlot) -> String:
	match slot:
		GearSlot.LEFT:
			return "left"
		GearSlot.RIGHT:
			return "right"
	return "unknown"


static func gear_slot_from_str(name: String) -> GearSlot:
	var gs: GearSlot
	match name:
		"left":
			gs = GearSlot.LEFT
		"right":
			gs = GearSlot.RIGHT
		_:
			printerr("Unknown gear slot: %s" % [name])
	return gs


static func check_op_eval_int(op: CheckOp, x: int, y: int) -> bool:
	var res := false
	match op:
		CheckOp.LTE:
			res = x <= y
		CheckOp.LT:
			res = x < y
		CheckOp.EQ:
			res = x == y
		CheckOp.GT:
			res = x > y
		CheckOp.GTE:
			res = x >= y
		CheckOp.EXISTS:
			printerr("EXISTS not defined without context")
	return res


static func check_op_eval_float(op: CheckOp, x: float, y: float) -> bool:
	var res := false
	match op:
		CheckOp.LTE:
			res = x <= y
		CheckOp.LT:
			res = x < y
		CheckOp.EQ:
			res = x == y
		CheckOp.GT:
			res = x > y
		CheckOp.GTE:
			res = x >= y
		CheckOp.EXISTS:
			printerr("EXISTS not defined without context")
	return res


static func check_op_eval_bool(op: CheckOp, x: bool, y: bool) -> bool:
	if op == CheckOp.EQ:
		return x == y
	printerr("%s not supported as a boolean comparison" % [op])
	return false


static func check_op_eval_str(op: CheckOp, x: String, y: String) -> bool:
	var res := false
	match op:
		CheckOp.LTE:
			res = x <= y
		CheckOp.LT:
			res = x < y
		CheckOp.EQ:
			res = x == y
		CheckOp.GT:
			res = x > y
		CheckOp.GTE:
			res = x >= y
		CheckOp.EXISTS:
			printerr("EXISTS not defined without context")
	return res


static func quest_state_name(st: QuestState) -> String:
	match st:
		QuestState.DORMANT:
			return "dormant"
		QuestState.ACTIVE:
			return "active"
		QuestState.FAILED:
			return "failed"
		QuestState.COMPLETED:
			return "completed"
	printerr("Unknown quest state converted to string: ", st)
	return "unknown"


static func quest_state_from_str(state_str: String) -> QuestState:
	state_str = state_str.to_lower()
	if QUEST_STATE_NAME.has(state_str):
		return QUEST_STATE_NAME[state_str]
	printerr("Unable to resolve quest state %s, returning default" % [state_str])
	return QuestState.DORMANT


static func stat_name(st: Stat) -> String:
	match st:
		Stat.STAMINA:
			return "Stamina"
		Stat.HEALTH:
			return "Health"
	printerr("Unknown stat: %s" % [st])
	return "Unknown"


static func stat_from_name(name: String) -> Stat:
	return STAT_NAME[name]
