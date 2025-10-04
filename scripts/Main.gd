# scripts/Main.gd
extends Node2D

var score: int = 0
@onready var hud: Label = $CanvasLayer/Label

func _ready() -> void:
	add_to_group("main_root")
	_update_hud()

func on_gem_collected(gem: Node) -> void:
	if is_instance_valid(gem):
		gem.queue_free()
	score += 1
	_update_hud()

func _update_hud() -> void:
	if hud:
		hud.text = "Score: %d   ←/→ to aim, Space to fire" % score
