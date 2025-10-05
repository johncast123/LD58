extends Node2D

class_name GemManager

signal score_calculated

var gem_folder: Array[Gem] = []

func register_all_gems():
	for child in get_children():
		if child is Gem:
			child.connect("collected", _on_gem_collected)
			gem_folder.append(child)

func _ready():
	register_all_gems()

func _on_gem_collected(gem: Gem):
	if gem.gem_info.extra_function_index >= 0: # if there is some extra function to execute
		gem.gem_info.execute_extra_function(gem.gem_info.extra_function_index)
	Global.update_total_score(calculate_score(gem.point, Global.current_multiplier))
	gem.queue_free()
	score_calculated.emit()

func calculate_score(raw_points: int, multiplier: int):
	return raw_points * multiplier
