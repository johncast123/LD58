extends Node

class_name State

@export var state_owner: Hook
@export var state_name: String

func exit():
	pass

func enter():
	pass

func update_physics_frame(delta: float):
	pass

func update_frame(delta: float):
	pass

func process_input(event: InputEvent):
	pass
