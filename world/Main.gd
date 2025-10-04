# scripts/Main.gd
extends Node2D

@onready var hud: Label = $CanvasLayer/Label
@onready var current_multiplier = $CanvasLayer/CurrentMultiplier


func _ready() -> void:
	add_to_group("main_root")
	_update_hud()

func _update_hud() -> void:
	if hud:
		hud.text = "Score: %d   ←/→ to aim, Space to fire" % Global.total_score

func _on_gem_manager_score_calculated():
	_update_hud()

func _update_current_multiplier():
	if current_multiplier:
		current_multiplier.text = "Current Multiplier: X%d" % Global.current_multiplier

func _process(delta):
	_update_current_multiplier()
