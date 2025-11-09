# scripts/Cannon.gd
extends Node2D

const HOOKLINE = preload("res://actors/hook_line.tscn")

signal hook_retracted

@export var rotate_speed_deg: float = 360.0     # used only for smooth aiming
@export var min_angle_deg: float = -160.0       # up-left limit (global degrees)
@export var max_angle_deg: float = -20.0        # up-right limit (global degrees)
@export var hook_scene: PackedScene
@export var max_hook_count: int = 1
@export var use_smooth_mouse_aim: bool = true   # set false to snap-aim

var active_hooks: Array[Hook] = []
var active_indicators: Array[Node] = []
var hook_params: Dictionary = {}

@onready var muzzle: Node2D = $Muzzle
@onready var scope_timer_indicator = $ScopeTimerIndicator
@onready var multihook_timer_indicator = $MultihookTimerIndicator

func _ready():
	EventBus.connect("spawn_scope_indicator", _on_show_indicator.bind("scope"))
	EventBus.connect("spawn_multihook_indicator", _on_show_indicator.bind("multihook"))
	EventBus.connect("remove_all_buffs", _on_remove_all_buffs)

func _on_remove_all_buffs():
	scope_timer_indicator.hide()
	multihook_timer_indicator.hide()
	
func _on_show_indicator(indicator_name: String):
	match indicator_name:
		"scope":
			scope_timer_indicator.show()
			scope_timer_indicator.init()
			scope_timer_indicator.global_position = global_position + Vector2.RIGHT * 15
		"multihook":
			multihook_timer_indicator.show()
			multihook_timer_indicator.init()
			multihook_timer_indicator.global_position = global_position + Vector2.LEFT * 15

func _physics_process(delta: float) -> void:
	if Global.scope_enabled:
		$PreviewLine.visible = true
	else: $PreviewLine.visible = false
	
	max_hook_count = Global.max_hook_count
	_aim_with_mouse(delta)

	# Fire with Space or Left Click
	if _if_can_fire() and Input.is_action_just_pressed("fire"):
		_fire_hook()


func _aim_with_mouse(delta: float) -> void:
	var mouse_pos = get_global_mouse_position()
	var desired_rad = (mouse_pos - global_position).angle()
	var desired_deg = rad_to_deg(desired_rad)

	# force 180° down into -180°
	if desired_deg > 90.0:
		desired_deg -= 360.0
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
	
	# Preview line stuff
	var preview_dir = Vector2.RIGHT.rotated(deg_to_rad(desired_deg))
	var preview_points = get_hook_preview(global_position, preview_dir, 500, 8)
	$PreviewLine.points = preview_points

func _fire_hook() -> void:
	if !Global.player_can_move:
		return
	if not hook_scene:
		push_error("hook_scene not assigned on Cannon")
		return
	
	# instantiate hookline
	var line = HOOKLINE.instantiate()
	add_child(line)
	
	# instantiate hook
	var hook = hook_scene.instantiate() as Hook
	if _main_hook_exists(): #only the first active hook is main
		hook.is_main = false
	hook.can_pierce = Global.pierce_enabled
	active_hooks.append(hook)
	get_tree().current_scene.add_child(hook)
	hook.connect("update_line_points", update_line_points.bind(line))
	hook.connect("hook_queue_freed", _on_hook_queue_freed.bind(hook, line))
	var dir = Vector2.RIGHT.rotated(global_rotation)  # +X is forward
	# set hook to position but not launch yet
	hook.global_position = muzzle.global_position
	add_hook_dir(hook.name, [muzzle.global_position, dir])
	
	# only actually launch hooks if max count reached
	if active_hooks.size() >= max_hook_count:
		launch_hooks(active_hooks, hook_params)
	AudioManager.play_sfx("fire")

func add_hook_dir(hook_name: String, params: Array):
	hook_params[hook_name] = params

func launch_hooks(hook_array: Array[Hook], hook_params: Dictionary):
	for hook in hook_array:
		var param: Array = hook_params.get(hook.name, [])
		hook.begin(param[0], param[1])
		
func _main_hook_exists():
	for hook in active_hooks:
		if hook.is_main:
			return true
	return false

func _if_can_fire() -> bool:
	return active_hooks.size() < max_hook_count

# Helper: like lerp_angle but with a max step (deg)
func move_toward_angle(from: float, to: float, delta_step: float) -> float:
	var diff = wrapf(to - from, -PI, PI)
	var step = clamp(diff, -delta_step, delta_step)
	return from + step

func update_line_points(global_point_array: PackedVector2Array, line: Line2D):
	line.clear_points()
	for point in global_point_array:
		line.add_point(to_local(point))

func _on_hook_queue_freed(hook: Hook, line: Line2D):
	line.clear_points()
	if hook in active_hooks:
		active_hooks.erase(hook)
	# only reset multiplayer if all current hook count == 0
	if active_hooks.is_empty():
		Global.reset_bounce_count()
	
	if hook.is_main: # only fire signal if it's a main hook
		emit_signal("hook_retracted")

func get_hook_preview(start_pos: Vector2, direction: Vector2, max_length: float, max_bounces: int) -> PackedVector2Array:
	var points: Array[Vector2]
	var pos = start_pos
	var dir = direction.normalized()
	var traveled = 0.0
	var bounces = 0
	
	# Loop to ensure multiple bounces in one frame are all calculated
	while traveled < max_length and bounces < max_bounces:
		# Determine ray distance for this step
		var step_distance = 20.0  # small step for preview
		var space_state = get_world_2d().direct_space_state
		var physics_argument := PhysicsRayQueryParameters2D.create(pos, pos + dir * step_distance, 1)
		physics_argument.collide_with_bodies = true
		var result = space_state.intersect_ray(physics_argument)  # 1 = collision mask for walls
		
		if result:
			var collision_point = result.position
			var normal = result.normal
			points.append(collision_point)
			
			dir = dir.bounce(normal).normalized()
			pos = collision_point + dir * 0.1  # nudge off the wall
			# calculate the distance traveled from the previous point to the collision point (pos)
			traveled += pos.distance_to(points[points.size()-2])
			bounces += 1
		else:
			pos += dir * step_distance
			traveled += step_distance
			points.append(pos)
	
	# convert all points to local
	var local_points := PackedVector2Array(points.map(to_local))
	return local_points
