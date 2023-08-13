class_name Placeable extends StaticBody2D

const SHADER_MATERIAL = preload(
	"res://Resources/Shaders/Materials/PlaceableShaderMaterial.tres"
	)
const SHADER_PARAM_PREVIEW = "PREVIEW"
const SHADER_PARAM_PLACEABLE = "PLACEABLE"

@onready var sprite: Sprite2D = $Sprite2D
@onready var body = $Body

var category: String = ""
var type: String = ""

var previewing: bool:
	get:
		return previewing
	set(new_value):
		previewing = new_value
		_update_shader()

var can_place: bool = true:
	get:
		return can_place
	set(new_value):
		can_place = new_value
		_update_shader()


func _ready() -> void:
	_setup_shader()

func init(item_to_place: PlaceableItem) -> void:
	await ready
	category = item_to_place.category
	type = item_to_place.name
	body.myCharacter = item_to_place
	
func _setup_shader() -> void:
	sprite.material = SHADER_MATERIAL.duplicate()
	_update_shader()

func _update_shader() -> void:
	if sprite.material == null:
		return
	
	sprite.material.set_shader_parameter(SHADER_PARAM_PREVIEW, previewing)
	sprite.material.set_shader_parameter(SHADER_PARAM_PLACEABLE, can_place)

# Add to saveFile and record position
func set_stats(stats: Resource = null) -> void:
	if stats == null:
		stats = GameManager.new_resource(category, type)
		body.stats = stats
		stats.globalPosition = global_position
	else:
		await ready
		body.stats = stats
	
