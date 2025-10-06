extends CanvasLayer

class_name LevelHUD

const GAP_SEC: float = 1.5

@export var base_multiplier_font_size: int = 24

@onready var score = $Score
@onready var current_multiplier = $CurrentMultiplier
@onready var multiplier_number = $CurrentMultiplier/MultiplierNumber
@onready var time_left = $TimeLeft
@onready var level_end_message = $LevelEndMessage
@onready var buttons_container = $VBoxContainer/ButtonsContainer
@onready var total_score_container = $VBoxContainer/TotalScoreContainer

var internal_score_delta: int = 0:
	set(value):
		internal_score_delta = value
		$VBoxContainer/TotalScoreContainer/Delta.text = "+%d" % value
var internal_total_score: int = 0:
	set(value):
		internal_total_score = value
		$VBoxContainer/TotalScoreContainer/TotalScore.text = "%06d" % value

func initialize():
	self.show()
	hide_level_end_message()
	initialize_buttons()
	total_score_container.hide()

func update_score(new_score: int, threshold: int):
	score.text = "Score: %d/%d" % [new_score, threshold]

func update_multiplier(new_multiplier: int):
	multiplier_number.text = "x" + str(new_multiplier)
	multiplier_number.add_theme_font_size_override("font_size", sqrt(new_multiplier) * base_multiplier_font_size)

func update_timeleft(new_time_sec: int):
	time_left.text = "Time Left: %d" % new_time_sec

func set_and_show_level_end_message(message: String):
	level_end_message.text = message
	level_end_message.show()

func hide_level_end_message():
	level_end_message.hide()

func initialize_buttons():
	$Backboard.hide()
	for child in buttons_container.get_children():
		child.show()
	enable_all_buttons()
	hide_buttons()
	
func hide_buttons():
	$Backboard.hide()
	hide_level_end_message()
	buttons_container.hide()

func show_buttons():
	$Backboard.show()
	buttons_container.show()

func set_and_show_buttons(outcome: String):
	get_tree().paused = true
	match outcome:
		"win":
			set_and_show_level_end_message("Victory!")
			$VBoxContainer/ButtonsContainer/Continue.hide()
			$VBoxContainer/ButtonsContainer/Next.show()
			$VBoxContainer/TotalScoreContainer.show()
		"lose":
			set_and_show_level_end_message("You failed...")
			$VBoxContainer/ButtonsContainer/Continue.hide()
			$VBoxContainer/ButtonsContainer/Next.hide()
			$VBoxContainer/TotalScoreContainer.hide()
		"pause":
			set_and_show_level_end_message("Paused")
			$VBoxContainer/ButtonsContainer/Continue.show()
			$VBoxContainer/ButtonsContainer/Next.hide()
			$VBoxContainer/TotalScoreContainer.hide()
	show_buttons()

func update_total_score(delta: int):
	internal_total_score = Global.total_score
	internal_score_delta = delta
	
func _on_restart_pressed():
	AudioManager.play_sfx("ui_click")
	get_tree().paused = false
	get_tree().reload_current_scene()

func _on_next_pressed():
	AudioManager.play_sfx("ui_click")
	get_tree().paused = false
	
	disable_all_buttons()
	Global.update_total_score(internal_score_delta)
	var a = get_tree().create_tween().set_parallel()
	a.tween_property(self, "internal_score_delta", 0, GAP_SEC)
	a.tween_property(self, "internal_total_score", Global.total_score, GAP_SEC)
	var b = get_tree().create_tween().set_loops(10)
	b.tween_callback(play_tally_sfx).set_delay(0.15)
	await a.finished
	$VBoxContainer/TotalScoreContainer/Delta.hide()
	await get_tree().create_timer(1).timeout
	Global.go_to_next_level()
	
func _on_menu_pressed():
	AudioManager.play_sfx("ui_click")
	get_tree().paused = false
	#get_tree().change_scene_to_packed(preload("res://UI/MainMenu.tscn"))
	pass # Replace with function body.

func disable_all_buttons():
	for child: Button in buttons_container.get_children():
		child.disabled = true

func enable_all_buttons():
	for child: Button in buttons_container.get_children():
		child.disabled = false

func _on_continue_pressed():
	AudioManager.play_sfx("ui_click")
	get_tree().paused = false
	hide_buttons()

func play_tally_sfx():
	AudioManager.play_sfx("score_tally")
