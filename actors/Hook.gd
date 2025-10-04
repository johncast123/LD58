# scripts/Hook.gd
extends Area2D

class_name Hook

signal update_line_points(global_points: PackedVector2Array)
signal hook_queue_freed

enum State { IDLE, EXTENDING, RETRACTING }

@export var extend_speed: float = 500.0
@export var retract_speed: float = 650.0
@export var max_length: float = 500.0
@export var max_bounces: int = 8   # how many wall bounces allowed during extension

@onready var state_machine = $StateMachine

var start_global: Vector2
var dir: Vector2
var carried_gem: Gem = null
var bounces: int = 0:
	set(value):
		bounces = value
		EventBus.update_bounce_count.emit(value)
var traveled: float = 0.0  # total distance traveled while extending

var fixed_points: PackedVector2Array # points where Line2D should always pass through

func begin(_start_global: Vector2, _direction: Vector2) -> void:
	start_global = _start_global
	global_position = start_global
	_add_fixed_point(start_global)
	dir = _direction.normalized()
	bounces = 0
	traveled = 0.0
	state_machine.init()

func _physics_process(delta: float) -> void:
	state_machine.update_physics_frame(delta)

func _update_line() -> void:
	var total_points = fixed_points.duplicate()
	total_points.append(global_position)
	update_line_points.emit(total_points)

func _add_fixed_point(new_global_point: Vector2):
	fixed_points.append(new_global_point)

func _on_Hook_area_entered(area: Area2D) -> void:
	if state_machine.current_state is ExtendingState and carried_gem == null and area is Gem:
		carried_gem = area
		state_machine.change_state("retracting")
		carried_gem.monitoring = false
		carried_gem.set_snatched()

func _check_wall_bounce() -> void:
	var bounced := false
	
	var position_snapshot := global_position
	# Move a bit in the direction and check collision
	var space_state = get_world_2d().direct_space_state
	var query = PhysicsRayQueryParameters2D.create(global_position, global_position + dir.normalized() * 15)
	#query.collide_with_areas = true
	query.collide_with_bodies = true

	var result = space_state.intersect_ray(query)

	if result:
		# Get collision point + normal
		global_position = result.position
		var normal: Vector2 = result.normal

		# Reflect direction across the wall normal
		dir = dir.bounce(normal).normalized()
		bounced = true

	if bounced:
		_add_fixed_point(position_snapshot)
		bounces += 1
		# Optional: small nudge to avoid getting stuck on a corner
		global_position += dir * 0.5

func _deliver_and_die() -> void:
	if carried_gem:
		carried_gem.set_collected()
	hook_queue_freed.emit()
	queue_free()

func _ready() -> void:
	area_entered.connect(_on_Hook_area_entered)
