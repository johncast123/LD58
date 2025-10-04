# scripts/Hook.gd
extends Area2D

enum State { IDLE, EXTENDING, RETRACTING }

@export var extend_speed: float = 500.0
@export var retract_speed: float = 650.0
@export var max_length: float = 500.0
@export var max_bounces: int = 8   # how many wall bounces allowed during extension

var start_global: Vector2
var dir: Vector2
var state: State = State.IDLE
var carried_gem: Node = null
var bounces: int = 0
var traveled: float = 0.0  # total distance traveled while extending

@onready var line: Line2D = $Line2D

func begin(_start_global: Vector2, _direction: Vector2) -> void:
	start_global = _start_global
	global_position = start_global
	dir = _direction.normalized()
	state = State.EXTENDING
	bounces = 0
	traveled = 0.0
	line.points = [Vector2.ZERO, Vector2.ZERO]

func _physics_process(delta: float) -> void:
	match state:
		State.EXTENDING:
			var step_vec := dir * extend_speed * delta
			global_position += step_vec
			traveled += step_vec.length()

			_check_wall_bounce()
			_update_line()

			if traveled >= max_length or bounces > max_bounces:
				state = State.RETRACTING

		State.RETRACTING:
			var to_base = (start_global - global_position)
			var dist = to_base.length()
			if dist > 0.001:
				var step = to_base.normalized() * retract_speed * delta
				if step.length() > dist:
					step = to_base
				global_position += step
				if carried_gem:
					carried_gem.global_position = global_position
			_update_line()
			if global_position.distance_to(start_global) <= 6.0:
				_deliver_and_die()

func _update_line() -> void:
	# Draw a straight cable (simple for now). We can segment later if you want.
	var to_base = to_local(start_global)
	line.points = [Vector2.ZERO, to_base]

func _on_Hook_area_entered(area: Area2D) -> void:
	if state == State.EXTENDING and carried_gem == null and area.is_in_group("gem"):
		carried_gem = area
		state = State.RETRACTING
		carried_gem.monitoring = false

func _check_wall_bounce() -> void:
	# Reflect off the visible viewport edges
	var sz: Vector2 = get_viewport().get_visible_rect().size
	var bounced := false

	if global_position.x <= 0.0:
		global_position.x = 0.0
		dir = dir.bounce(Vector2.RIGHT)   # normal pointing right
		bounced = true
	elif global_position.x >= sz.x:
		global_position.x = sz.x
		dir = dir.bounce(Vector2.LEFT)    # normal pointing left
		bounced = true

	if global_position.y <= 0.0:
		global_position.y = 0.0
		dir = dir.bounce(Vector2.DOWN)    # normal pointing down
		bounced = true
	elif global_position.y >= sz.y:
		global_position.y = sz.y
		dir = dir.bounce(Vector2.UP)      # normal pointing up
		bounced = true

	if bounced:
		bounces += 1
		# Optional: small nudge to avoid getting stuck on a corner
		global_position += dir * 0.5

func _deliver_and_die() -> void:
	if carried_gem:
		var main := get_tree().get_first_node_in_group("main_root")
		if main:
			main.call_deferred("on_gem_collected", carried_gem)
	queue_free()

func _ready() -> void:
	area_entered.connect(_on_Hook_area_entered)
