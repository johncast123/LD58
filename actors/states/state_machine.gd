extends Node2D

class_name StateMachine

var current_state: State

@export var starting_state_name: String
@export var states: Dictionary[String, State]

func add_state(state_name: String, state: State):
	states[state_name] = state

func get_current_state() -> State:
	if current_state: return current_state
	else: return null

func init():
	change_state(starting_state_name)

func update_frame(delta: float) -> void:
	if current_state: current_state.update_frame(delta)

func update_physics_frame(delta: float) -> void:
	if current_state: current_state.update_physics_frame(delta)

func process_input(event: InputEvent):
	if current_state: current_state.process_input(event)

func change_state(new_state_name: String):
	if current_state:
		current_state.exit()
	current_state = get_state(new_state_name)
	if current_state:
		current_state.enter()
		
func get_state(state_name: String) -> State:
	var state = states.get(state_name, null)
	if state:
		return state
	else:
		push_warning("No State with name '%s' is found in the states dictionary -- state_machine.gd", state_name)
	return null
