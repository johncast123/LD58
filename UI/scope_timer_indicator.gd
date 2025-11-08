extends Sprite2D

class_name PowerupTimerIndicator

@onready var texture_progress_bar = $TextureProgressBar

var total_time_sec: int = 10

@onready var timer = $Timer

func init(time_sec: int = 10):
	total_time_sec = time_sec
	texture_progress_bar.max_value = total_time_sec
	texture_progress_bar.value = texture_progress_bar.max_value
	#timer.start()

func _on_timer_timeout():
	total_time_sec -= 1
	texture_progress_bar.value = total_time_sec
	if total_time_sec < 0:
		hide()
