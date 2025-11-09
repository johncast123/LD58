extends State

class_name ExtendingState

func update_physics_frame(delta: float):
	var hook := state_owner
	var step_distance := hook.extend_speed * delta
	var remaining := step_distance

	# NOTE: Collision/bounce checks should happen before actually executing the moving! 
	while remaining > 0 and hook.bounces < hook.max_bounces:
		# Configure ray to check the next travel segment
		hook.ray.global_position = hook.global_position
		hook.ray.target_position = hook.dir * remaining
		hook.ray.force_raycast_update()

		if hook.ray.is_colliding():
			var collision_point = hook.ray.get_collision_point()
			var normal = hook.ray.get_collision_normal()
			var distance_to_hit = hook.global_position.distance_to(collision_point)
			
			# Move to collision point
			hook.global_position = collision_point
			hook.add_fixed_point(collision_point)

			# Bounce
			hook.dir = hook.dir.bounce(normal).normalized()
			hook.bounces += 1
			remaining -= distance_to_hit
			
			# Play bounce sound
			var sfx_index = clamp(hook.bounces - 1, 0, AudioManager.bouncing_sfx_array.size() - 1)
			AudioManager.play_bounce_sfx(sfx_index)

			# Slight offset to avoid re-colliding instantly
			hook.global_position += hook.dir * 0.1
		else:
			# No collision — move the rest of the way
			hook.global_position += hook.dir * remaining
			hook.traveled += remaining
			remaining = 0
	
	hook.update_line()
	
	hook.get_node("Sprite2D").rotation = hook.dir.angle() + Vector2.UP.angle()
	
	hook.update_carried_gems_pos(hook.global_position)
	# Reached max length?
	if hook.traveled >= hook.max_length or hook.bounces >= hook.max_bounces:
		hook.state_machine.change_state("retracting")
	
