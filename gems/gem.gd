extends Area2D

class_name Gem

signal collected(gem: Gem)

enum GEM_TYPE{SILVER_COIN, GOLD_COIN, RUBY, EMERALD, DIAMOND}

@export var gem_info: GemInfo = preload("res://gems/gem_info/silver_coin.tres")
@onready var animated_sprite_2d = $AnimatedSprite2D

var point: int = 0

func _ready():
	point = gem_info.point
	animated_sprite_2d.sprite_frames = gem_info.sprite_frame
	animated_sprite_2d.play("idle")

func _disable_self():
	monitorable = false

func _enable_self():
	monitorable = true

func set_collected():
	collected.emit(self)
	animated_sprite_2d.play("collected")
