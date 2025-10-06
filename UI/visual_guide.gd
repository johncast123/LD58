extends CanvasLayer

signal window_closed

func _on_button_pressed():
	emit_signal("window_closed")
