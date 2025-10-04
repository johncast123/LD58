extends Area2D

class_name Gem

@export var bounces_before_enabled: int = 0
@onready var label = $Label

func _ready():
	_on_bounce_count_update(0)
	EventBus.connect("update_bounce_count", _on_bounce_count_update)
	label.text = str(bounces_before_enabled)

func _on_bounce_count_update(_new_count: int):
	if Global.bounce_count >= bounces_before_enabled:
		_enable_self()
	else:
		_disable_self()

func _disable_self():
	monitorable = false

func _enable_self():
	monitorable = true
