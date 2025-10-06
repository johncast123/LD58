extends Area2D

class_name Gem

signal collected(gem: Gem)

@export var gem_info: GemInfo = preload("res://gems/gem_info/silver_coin.tres")
@export var is_moving: bool = false

@onready var placeholder = preload("res://gems/placeholder_gem.tscn")
@onready var animated_sprite_2d = $AnimatedSprite2D

var point: int = 0
var sfx_name: String

func _ready():
	point = gem_info.point
	animated_sprite_2d.sprite_frames = gem_info.sprite_frame
	animated_sprite_2d.offset = gem_info.sprite_off_set
	animated_sprite_2d.play("idle")
	sfx_name = gem_info.sfx_name
	
	$MoveManager.enabled = is_moving

func _disable_self():
	monitorable = false

func _enable_self():
	monitorable = true

func set_collected():
	collected.emit(self)
	play_sfx()
	#play_collected_effect()

func play_collected_effect():
	var a = placeholder.instantiate()
	get_tree().current_scene.add_child(a)
	a.animated_sprite_2d.sprite_frames = gem_info.sprite_frame
	a.global_position = global_position
	a.play_effect()
	
func set_snatched():
	play_collected_effect()

func play_sfx():
	AudioManager.play_sfx(sfx_name)
