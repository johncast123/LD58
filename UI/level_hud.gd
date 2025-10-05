extends CanvasLayer

class_name LevelHUD

@export var base_multiplier_font_size: int = 12

@onready var score = $Score
@onready var current_multiplier = $CurrentMultiplier
@onready var multiplier_number = $CurrentMultiplier/MultiplierNumber
@onready var time_left = $TimeLeft
@onready var level_end_message = $LevelEndMessage

func initialize():
	self.show()
	hide_level_end_message()
	initialize_buttons()

func update_score(new_score: int):
	score.text = "Score: %d" % new_score

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
	for child in $ButtonsContainer.get_children():
		child.show()
	hide_buttons()
	
func hide_buttons():
	$ButtonsContainer.hide()

func show_buttons():
	$ButtonsContainer.show()

func set_and_show_buttons(outcome: String):
	match outcome:
		"win":
			$ButtonsContainer/Next.show()
		"lose":
			$ButtonsContainer/Next.hide()
	show_buttons()
	$Backboard.show()

func _on_restart_pressed():
	get_tree().reload_current_scene()

func _on_next_pressed():
	Global.go_to_next_level()
	
func _on_menu_pressed():
	pass # Replace with function body.
