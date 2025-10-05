# scripts/Main.gd
extends Node2D

class_name Level

const SCORE_POPUP = preload("res://UI/score_popup.tscn")

@export var level_name: String
@export var next_level: PackedScene
@export var total_time_sec: int = 20
@export var score_threshold: int

@onready var level_hud = $LevelHUD
@onready var countdown_timer = $CountdownTimer
@onready var cannon = $Cannon

var time_left_sec: int = total_time_sec
var level_score: int = 0

func _ready() -> void:
	Global.set_next_level(next_level)
	level_hud.initialize()
	initialize_countdown()
	level_score = 0
	_update_hud("all")
	Global.player_can_move = true
	start_countdown()
	
func _update_hud(element_name: String) -> void:
	match element_name:
		"score":
			level_hud.update_score(level_score, score_threshold)
		"multiplier":
			level_hud.update_multiplier(Global.current_multiplier)
		"time_left":
			level_hud.update_timeleft(time_left_sec)
		"all":
			level_hud.update_score(level_score, score_threshold)
			level_hud.update_multiplier(Global.current_multiplier)
			level_hud.update_timeleft(time_left_sec)

func _on_gem_manager_score_calculated(gem_score: int):
	level_score += gem_score
	_update_hud("score")
	if abs(gem_score) <= 5: # if smaller than a certain threshold, do not display the popup
		return
	var a = SCORE_POPUP.instantiate() as ScorePopup
	add_child(a)
	a.global_position = cannon.global_position + Vector2.LEFT * 25
	a.set_popup(gem_score)

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
		Global.player_can_move = false
		if check_if_score_met(level_score, score_threshold):
			level_hud.set_and_show_buttons("win")
			level_hud.update_total_score(level_score)
		else:
			level_hud.set_and_show_buttons("lose")
		#get_tree().paused = true

func check_if_score_met(player_score: int, score_threshold: int):
	return player_score >= score_threshold

func _input(event):
	if event is InputEvent and Input.is_action_just_pressed("pause"):
		level_hud.set_and_show_buttons("pause")
		get_tree().paused = true
