class_name FishCharacter extends Resource

@export var type: String = "Generic"
@export var maxSize: float = 2.0
@export var swimSpeed: int = 60
@export var fleeSpeed: int = 100
@export var rotationSpeed: float = 40.0
@export var maxHealth: float = 100.0
@export var growthThreshold: float = 5.0
@export var spriteScale: float = 4.0
@export var idleFoodDistanceThreshold: float = 400
@export var preferredTemp: float = 25.0
@export var toleranceRange: float = 8.0
@export var matingEnergyThreshold: float = 50.0
@export var mateSize: float = 1.8
@export var growBabyTime: float = 300.0
@export var minChildren: int = 2
@export var maxChildren: int = 5

func get_sprite() -> CompressedTexture2D:
	return ResourceLoader.load("res://Resources/fish/%s.png" % type)
