@tool
extends GraphEdit


# Map[Quest.id, Quest]
var _quests := {}

## tracks which nodes are selected in the edit view for determining which gets
## focus in the inspector panel
var _selected_nodes: Array[String] = []

var _editor: EditorInterface

func _ready() -> void:
	_refresh_quests()


func setup(editor: EditorInterface) -> void:
	_editor = editor
	for q: Quest in _quests.values():
		var node := QuestNode.from_quest(q)
		add_child(node)
		node.setup(_editor, _quests)


func _refresh_quests() -> void:
	var quest_paths := Utils.walk_directory(Utils.QUEST_DIR, func(s: String) -> bool: return s.ends_with(".tres"))
	for path in quest_paths:
		var quest := ResourceLoader.load(Utils.QUEST_DIR.path_join(path)) as Quest
		if quest != null:
			_quests[quest.id] = quest

func _on_visibility_changed() -> void:
	if visible:
		for c in get_children():
			if c is QuestNode:
				c._sync_width()

func _node_selected(node: Node) -> void:
	if node is QuestNode:
		if node.id in _selected_nodes:
			return
		_selected_nodes.push_back(node.id)
	_update_selection()

func _node_deselected(node: Node) ->void:
	if node is QuestNode:
		_selected_nodes = _selected_nodes.filter(func (e_id: String) -> bool: return e_id != node.id)
	_update_selection()

func _update_selection() -> void:
	if _selected_nodes.size() == 1:
		_editor.edit_resource(_quests[_selected_nodes[0]])
	else:
		_editor.edit_node(null)