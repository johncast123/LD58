extends CanvasLayer

class_name LevelHUD

@export var base_multiplier_font_size: int = 12

@onready var score = $Score
@onready var current_multiplier = $CurrentMultiplier
@onready var multiplier_number = $CurrentMultiplier/MultiplierNumber
@onready var time_left = $TimeLeft

func update_score(new_score: int):
	score.text = "Score: %d" % new_score

func update_multiplier(new_multiplier: int):
	multiplier_number.text = "x" + str(new_multiplier)
	multiplier_number.add_theme_font_size_override("font_size", sqrt(new_multiplier) * base_multiplier_font_size)

func update_timeleft(new_time_sec: int):
	time_left.text = "Time Left: %d" % new_time_sec
