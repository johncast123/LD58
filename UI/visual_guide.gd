extends CanvasLayer

signal window_closed

func _on_button_pressed():
	AudioManager.play_sfx("ui_click")
	emit_signal("window_closed")
