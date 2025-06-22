class_name DevPrefs
extends Resource

@export var autoload_level: String = ""


func save() -> void:
	var result := ResourceSaver.save(self, Utils.dev_prefs_path())
	print("Saving DefPrefs to %s: %s" % [Utils.dev_prefs_path(), result])


static func load() -> DevPrefs:
	if !FileAccess.file_exists(Utils.dev_prefs_path()):
		print("Creating new DevPrefs since none exists")
		return DevPrefs.new()

	var res := ResourceLoader.load(Utils.dev_prefs_path()) as DevPrefs
	return res
