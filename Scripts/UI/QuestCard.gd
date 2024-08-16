extends VSplitContainer

@onready var title := $Title
@onready var quest_description := $VBoxContainer/QuestDescription
@onready var status := $VBoxContainer/Status

func update(quest:Quest)->void:
	title.text = quest.title
	quest_description.text = quest.description
	if quest.is_completed:
		status.text = "Quest Completed"
	else:
		status.text = "Quest In Progress"
