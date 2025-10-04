extends Resource

class_name GemInfo

@export_enum("Silver Coin", "Gold Coin", "Ruby", "Emerald", "Diamond") var gem_name: String = "Silver Coin"
@export var sprite_frame: SpriteFrames = preload("res://gems/silver_coin.tres")
@export var point: int = 10
