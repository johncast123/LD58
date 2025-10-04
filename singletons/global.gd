extends Node

var bounce_count: int

func _ready():
	EventBus.connect("update_bounce_count", _on_update_bounce_count)
	
func _on_update_bounce_count(new_count: int):
	bounce_count = new_count
