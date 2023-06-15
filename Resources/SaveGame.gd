extends Resource
class_name SaveGame

@export var version: int = 1
@export var tankData: TankData

func write_savegame() -> void:
	ResourceSaver.save(self, GameManager.get_save_path())

static func save_exists() -> bool:
	return ResourceLoader.exists(GameManager.get_save_path())

static func load_savegame() -> Resource:
	var save_path := GameManager.get_save_path()
	return ResourceLoader.load(save_path, "", ResourceLoader.CACHE_MODE_IGNORE)
	
