extends Node2D

@export var first_level: PackedScene

func _ready():
	AudioManager.play_bgm("Title")
	Global.set_next_level(first_level)

func _on_start_pressed():
	if first_level:
		AudioManager.play_sfx("ui_click")
		$VisualGuide.show()
		await $VisualGuide.window_closed
		Global.go_to_next_level()
