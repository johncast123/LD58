extends Node2D

class_name MoveManager

@export var enabled: bool = false
@export var move_range_px: int = 50
@export var direction: Vector2 = Vector2.RIGHT
@export var move_speed: float = 100.0

var _start_pos: Vector2
var _moving_forward := true
var _traveled_distance : float = move_range_px/2

func _ready() -> void:
	# Save the starting position of the parent
	if get_parent() == null:
		push_warning("MoveManager has no parent! It won’t move anything.")
		enabled = false
	else:
		_start_pos = get_parent().global_position
	direction = direction.normalized()

func _process(delta: float) -> void:
	if not enabled:
		return

	var parent = get_parent()
	if parent == null:
		return

	# Move in the current direction
	var step = direction * move_speed * delta * (1 if _moving_forward else -1)
	parent.global_position += step
	_traveled_distance += step.length()

	# Reverse direction when reaching move_range_px
	if _traveled_distance >= move_range_px:
		_moving_forward = !_moving_forward
		_traveled_distance = 0.0
