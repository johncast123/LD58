extends Node2D

@export var first_level: PackedScene

func _ready():
	Global.set_next_level(first_level)

func _on_start_pressed():
	if first_level:
		Global.go_to_next_level()
