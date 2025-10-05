extends Node

const DEFAULT_MULTIPLIER: int = 1

var player_can_move: bool = true

var bounce_count: int = 0
var total_score: int = 0
var base_multiplier := DEFAULT_MULTIPLIER
var current_multiplier: int = base_multiplier

var max_hook_count: int = 1
var powerup_timer: Timer = Timer.new()

var scope_enabled: bool = false
var scope_timer: Timer = Timer.new()

var next_level: PackedScene

func _ready():
	EventBus.connect("update_bounce_count", _on_update_bounce_count)
	
	total_score = 0
	
	initialize_powerup_timer(10)
	initialize_scope_timer(5)
	
func initialize_powerup_timer(time_sec: int):
	powerup_timer.one_shot = true
	powerup_timer.wait_time = time_sec
	powerup_timer.connect("timeout", _on_powerup_timer_timeout)
	add_child(powerup_timer)

func initialize_scope_timer(time_sec: int):
	scope_timer.one_shot = true
	scope_timer.wait_time = time_sec
	scope_timer.connect("timeout", _on_scope_timer_timeout)
	add_child(scope_timer)
	
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

func enable_scope(time_sec: int = 5):
	scope_enabled = true
	scope_timer.start(time_sec)

func _on_scope_timer_timeout():
	scope_enabled = false

func go_to_next_level():
	if next_level:
		get_tree().change_scene_to_packed(next_level)

func set_next_level(packed_level: PackedScene):
	if packed_level:
		next_level = packed_level
