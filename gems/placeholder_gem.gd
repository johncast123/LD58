extends Node2D

class_name PlaceHolderGem

@onready var animated_sprite_2d = $AnimatedSprite2D

func play_effect():
	animated_sprite_2d.play("collected")
