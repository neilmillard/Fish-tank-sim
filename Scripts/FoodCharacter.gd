class_name FoodCharacter extends Item

@export var type: String = "Generic"
@export var doesFloat: bool = true
@export var sinkTime: float = 50
@export var doesSwim: bool = false
@export var move_speed : float = 10
@export var rotTime: float = 4000
@export var nutritionValue: Nutrition
@export var animSprite: bool = false

func get_sprite() -> CompressedTexture2D:
	return ResourceLoader.load("res://Resources/food/%s.png" % type)
