extends Node2D

@onready var sprite: Sprite2D = $Sprite2D
@onready var body = $Body

var category: String = ""
var type: String = ""

func set_stats(stats: Resource = null) -> void:
	if stats == null:
		stats = GameManager.new_resource(category, type)
		body.stats = stats
		stats.globalPosition = global_position
	else:
		await ready
		body.stats = stats
