extends Node2D

@export_file("*.tscn") var start_level_path # use scene path to avoid cyclical dependency
@export_file("*.tscn") var leaderboard_path

func _ready():
	$CanvasLayer/VBoxContainer/Score.text = "Total Score: %06d" % Global.total_score
	AudioManager.play_bgm("Level 4")
	
func _on_play_again_pressed():
	AudioManager.play_sfx("ui_click")
	Global.initialize_total_score()
	if start_level_path:
		get_tree().change_scene_to_file(start_level_path)


func _on_leaderboard_pressed():
	AudioManager.play_sfx("ui_click")
	if leaderboard_path:
		get_tree().change_scene_to_file(leaderboard_path)
