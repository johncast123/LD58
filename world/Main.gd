# scripts/Main.gd
extends Node2D

class_name Level

@export var level_name: String
@export var total_time_sec: int = 20
@export var score_threshold: int

@onready var level_hud = $LevelHUD
@onready var countdown_timer = $CountdownTimer

var time_left_sec: int = total_time_sec

func _ready() -> void:
	initialize_countdown()
	
	_update_hud("all")
	start_countdown()

func _update_hud(element_name: String) -> void:
	match element_name:
		"score":
			level_hud.update_score(Global.total_score)
		"multiplier":
			level_hud.update_multiplier(Global.current_multiplier)
		"time_left":
			level_hud.update_timeleft(time_left_sec)
		"all":
			level_hud.update_score(Global.total_score)
			level_hud.update_multiplier(Global.current_multiplier)
			level_hud.update_timeleft(time_left_sec)

func _on_gem_manager_score_calculated():
	_update_hud("score")

func _update_current_multiplier():
	_update_hud("multiplier")

func _process(delta):
	_update_current_multiplier()

func initialize_countdown():
	time_left_sec = total_time_sec

func start_countdown():
	countdown_timer.start()

func _on_countdown_timer_timeout():
	time_left_sec -= 1
	_update_hud("time_left")
	if time_left_sec <= 0:
		countdown_timer.stop()
		print(check_if_score_met(Global.total_score, score_threshold))

func check_if_score_met(player_score: int, score_threshold: int):
	return player_score >= score_threshold
