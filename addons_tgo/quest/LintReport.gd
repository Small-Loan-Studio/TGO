@tool
extends RichTextLabel


func _on_meta_clicked(meta: Variant) -> void:
	print(typeof(meta))
	print(TYPE_STRING)
	print(meta)