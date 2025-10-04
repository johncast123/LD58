extends State

func update_physics_frame(delta: float):
	var to_base = (state_owner.start_global - state_owner.global_position)
	var dist = to_base.length()
	if dist > 0.001:
		var step = to_base.normalized() * state_owner.retract_speed * delta
		if step.length() > dist:
			step = to_base
		state_owner.global_position += step
		if state_owner.carried_gem:
			state_owner.carried_gem.global_position = state_owner.global_position
	state_owner._update_line()
	if state_owner.global_position.distance_to(state_owner.start_global) <= 6.0:
		state_owner._deliver_and_die()
