extends Node

const DEFAULT_MULTIPLIER: int = 1

var bounce_count: int = 0
var total_score: int = 0
var base_multiplier := DEFAULT_MULTIPLIER
var current_multiplier: int = base_multiplier

func _ready():
	EventBus.connect("update_bounce_count", _on_update_bounce_count)
	
	total_score = 0
	
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
