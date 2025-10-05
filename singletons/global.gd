extends Node

const DEFAULT_MULTIPLIER: int = 1

var bounce_count: int = 0
var total_score: int = 0
var base_multiplier := DEFAULT_MULTIPLIER
var current_multiplier: int = base_multiplier

var max_hook_count: int = 1

var powerup_timer: Timer = Timer.new()

func _ready():
	EventBus.connect("update_bounce_count", _on_update_bounce_count)
	
	total_score = 0
	
	initialize_powerup_timer(10)
	
func initialize_powerup_timer(time_sec: int):
	powerup_timer.one_shot = true
	powerup_timer.wait_time = time_sec
	powerup_timer.connect("timeout", _on_powerup_timer_timeout)
	get_tree().current_scene.add_child(powerup_timer)
	
func _on_update_bounce_count(new_count: int):
	bounce_count = new_count
	update_current_multiplier()

func update_total_score(delta: int):
	total_score += delta

func update_current_multiplier():
	current_multiplier = base_multiplier * pow(2, bounce_count)

func reset_bounce_count():
	bounce_count = 0
	update_current_multiplier()

func reset_max_hook_count():
	max_hook_count = 1

func increase_max_hook_count(delta: int = 1, time_sec: int = 10):
	max_hook_count += delta
	powerup_timer.start(time_sec)

func _on_powerup_timer_timeout():
	#print("timeout!")
	reset_max_hook_count()
