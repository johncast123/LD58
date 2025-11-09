extends State

class_name RetractState

func update_physics_frame(delta: float):
	var hook := state_owner
	var to_base_vec = (hook.fixed_points[hook.fixed_points.size()-1] - hook.global_position)
	var to_base_dist = to_base_vec.length()
	if to_base_dist > 0.001:
		var step = to_base_vec.normalized() * hook.retract_speed * delta
		if step.length() > to_base_dist:
			step = to_base_vec
		hook.global_position += step
		hook.update_carried_gems_pos(hook.global_position)
	else:
		hook.fixed_points.remove_at(hook.fixed_points.size()-1)
	hook.update_line()
	if hook.global_position.distance_to(hook.start_global) <= 6.0:
		hook._deliver_and_die()
