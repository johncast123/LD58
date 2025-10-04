# scripts/Cannon.gd
extends Node2D

@export var rotate_speed_deg: float = 360.0     # used only for smooth aiming
@export var min_angle_deg: float = -160.0       # up-left limit (global degrees)
@export var max_angle_deg: float = -20.0        # up-right limit (global degrees)
@export var hook_scene: PackedScene
@export var fire_cooldown: float = 0.25
@export var use_smooth_mouse_aim: bool = true   # set false to snap-aim

var can_fire := true

@onready var muzzle: Node2D = $Muzzle
@onready var line_2d = $Line2D

func _physics_process(delta: float) -> void:
	_aim_with_mouse(delta)

	# Fire with Space or Left Click
	if can_fire and (Input.is_action_just_pressed("fire") or Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)):
		_fire_hook()

func _aim_with_mouse(delta: float) -> void:
	var mouse_pos = get_global_mouse_position()
	var desired_rad = (mouse_pos - global_position).angle()
	var desired_deg = rad_to_deg(desired_rad)

	# clamp to your allowed aiming window
	desired_deg = clamp(desired_deg, min_angle_deg, max_angle_deg)

	if use_smooth_mouse_aim:
		# smooth rotate toward desired angle (shortest path)
		var current = deg_to_rad(rotation_degrees)
		var target = deg_to_rad(desired_deg)
		var max_step = deg_to_rad(rotate_speed_deg) * delta
		var new_rad = move_toward_angle(current, target, max_step)
		rotation_degrees = rad_to_deg(new_rad)
	else:
		# snap instantly
		rotation_degrees = desired_deg

func _fire_hook() -> void:
	if not hook_scene:
		push_error("hook_scene not assigned on Cannon")
		return
	can_fire = false
	var hook = hook_scene.instantiate()
	add_child(hook)
	hook.connect("update_line_points", update_line_points)
	hook.connect("hook_queue_freed", _on_hook_queue_freed)
	var dir = Vector2.RIGHT.rotated(global_rotation)  # +X is forward
	hook.begin(muzzle.global_position, dir)
	_start_cooldown()

func _start_cooldown() -> void:
	var t := get_tree().create_timer(fire_cooldown)
	t.timeout.connect(func(): can_fire = true)

# Helper: like lerp_angle but with a max step (deg)
func move_toward_angle(from: float, to: float, delta_step: float) -> float:
	var diff = wrapf(to - from, -PI, PI)
	var step = clamp(diff, -delta_step, delta_step)
	return from + step

func update_line_points(global_point_array: PackedVector2Array):
	line_2d.clear_points()
	for point in global_point_array:
		line_2d.add_point(to_local(point))

func _on_hook_queue_freed():
	line_2d.clear_points()
