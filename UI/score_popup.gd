extends Control

class_name ScorePopup

const DURATION_SEC: int = 1.5

const BASE_FONT_SIZE = 12

var comment_list = ["Oh no!", "Nice", "Good!", "Beautiful!", "Fantastic!", "AMAZING!", "UNBELIEVABLE!"]

@onready var label = $VBoxContainer/Label
@onready var comment = $VBoxContainer/Comment

func set_popup(score: int):
	if score > 0:
		label.text = "+" + str(score)
	else: label.text = "-" + str(abs(score))
	
	var comment_index = get_comment_index(score)
	comment.text = comment_list[comment_index]
	set_font_size(max(BASE_FONT_SIZE * (comment_index + 1), 12))
	
	show_and_fade()

func get_comment_index(score: int) -> int:
	# Define thresholds in increasing order
	var thresholds = [0, 50, 200, 800, 2000, 5000]
	
	for i in range(thresholds.size()):
		if score < thresholds[i]:
			return i  # return index for current range
	
	# if score exceeds all thresholds → return last index ("UNBELIEVABLE!")
	return comment_list.size() - 1

func show_and_fade():
	modulate.a = 1
	var a = get_tree().create_tween().set_parallel(true).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_OUT)
	a.tween_property(self, "global_position", global_position + Vector2.UP * 20, DURATION_SEC)
	a.tween_property(self, "modulate:a", 0, DURATION_SEC)

func set_font_size(font_size: int):
	$VBoxContainer/Label.add_theme_font_size_override("font_size", font_size)
	$VBoxContainer/Comment.add_theme_font_size_override("font_size", font_size)
