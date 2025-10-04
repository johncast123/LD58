extends State

class_name ExtendingState

func update_physics_frame(delta: float):
	var step_vec := state_owner.dir * state_owner.extend_speed * delta
	state_owner.global_position += step_vec
	state_owner.traveled += step_vec.length()

	state_owner._check_wall_bounce()
	state_owner._update_line()

	if state_owner.traveled >= state_owner.max_length or state_owner.bounces > state_owner.max_bounces:
		state_owner.state_machine.change_state("retracting")
