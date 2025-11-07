# scripts/Main.gd
extends Node2D

class_name Level

const SCORE_POPUP = preload("res://UI/score_popup.tscn")

@export var level_name: String
@export var next_level: PackedScene
@export_enum("time", "hook_count") var level_type: String = "hook_count"
@export var total_time_sec: int = 20
@export var total_hook_count: int = 5
@export var score_threshold: int

@onready var level_hud = $LevelHUD
@onready var countdown_timer = $CountdownTimer
@onready var cannon = $Cannon

var time_left_sec: int = total_time_sec
var hook_count_left: int = total_hook_count
var level_score: int = 0

func _ready() -> void:
	cannon.connect("hook_retracted", _on_hook_retracted)
	
	AudioManager.play_bgm(level_name)
	Global.set_next_level(next_level)
	EventBus.remove_all_buffs.emit()
	
	level_hud.initialize(level_type)
	initialize_game(level_type)
	level_score = 0
	_update_hud("all")
	start_game(level_type)
	
func _update_hud(element_name: String) -> void:
	match element_name:
		"score":
			level_hud.update_score(level_score, score_threshold)
		"multiplier":
			level_hud.update_multiplier(Global.current_multiplier)
		"time_left":
			level_hud.update_timeleft(time_left_sec)
		"hook_left":
			level_hud.update_hookleft(hook_count_left)
		"all":
			level_hud.update_score(level_score, score_threshold)
			level_hud.update_multiplier(Global.current_multiplier)
			level_hud.update_timeleft(time_left_sec)
			level_hud.update_hookleft(hook_count_left)

func _on_gem_manager_score_calculated(gem_score: int):
	level_score += gem_score
	_update_hud("score")
	if abs(gem_score) <= 5: # if smaller than a certain threshold, do not display the popup
		return
	var a = SCORE_POPUP.instantiate() as ScorePopup
	add_child(a)
	a.global_position = get_viewport_rect().size / 2 # screen center
	a.set_popup(gem_score)
	
	# check if score reaches threshold with every gem scored; end level early if score passes
	if check_if_score_met(level_score, score_threshold):
		game_over()

func _update_current_multiplier():
	_update_hud("multiplier")

func _process(delta):
	_update_current_multiplier()

func initialize_game(type: String):
	match type:
		"time":
			initialize_countdown()
		"hook_count":
			initialize_hook_count()
func initialize_countdown():
	time_left_sec = total_time_sec
func initialize_hook_count():
	hook_count_left = total_hook_count

func start_game(type: String):
	Global.player_can_move = true
	match type:
		"time":
			start_countdown()
		"hook_count":
			start_hook_count()
func start_countdown():
	countdown_timer.start()
func start_hook_count():
	pass

func _on_hook_retracted():
	if level_type != "hook_count":
		return
	hook_count_left -= 1
	_update_hud("hook_left")
	if hook_count_left <= 0:
		game_over()

func _on_countdown_timer_timeout():
	time_left_sec -= 1
	_update_hud("time_left")
	if time_left_sec <= 0:
		countdown_timer.stop()
		game_over()
		#get_tree().paused = true

func game_over():
	Global.player_can_move = false
	if check_if_score_met(level_score, score_threshold):
		level_hud.set_and_show_buttons("win")
		level_hud.update_total_score(level_score)
		AudioManager.play_bgm("Victory")
	else:
		level_hud.set_and_show_buttons("lose")
		AudioManager.play_bgm("Fail")
func check_if_score_met(player_score: int, score_threshold: int):
	return player_score >= score_threshold

func _input(event):
	if event is InputEvent and Input.is_action_just_pressed("pause"):
		level_hud.set_and_show_buttons("pause")
		get_tree().paused = true
