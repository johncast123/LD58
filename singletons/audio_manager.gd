extends Node

@onready var bgm_player = $BGMPlayer
@onready var sfx_player = $SFXPlayer

const BGM: Dictionary = {
	
}

const SFX: Dictionary = {
	"score_tally": preload("res://sound/score_tally.wav"),
	"fire": preload("res://sound/cannonfire.wav"),
	"explosion": preload("res://sound/explosion.wav"),
	"pickup_gem": preload("res://sound/pickupgem.wav"),
	"pickup_coin": preload("res://sound/pickupCoin.wav"),
	"pickup_item": preload("res://sound/pickup_item.wav"),
	"ui_click": preload("res://sound/click.wav")
}

var bouncing_sfx_array: Array = [
	preload("res://sound/random (1).wav"),
	preload("res://sound/random (2).wav"),
	preload("res://sound/random (3).wav"),
	preload("res://sound/random (4).wav"),
	preload("res://sound/random (5).wav"),
	preload("res://sound/random (6).wav"),
	preload("res://sound/random (7).wav"),
	preload("res://sound/random (8).wav")
]

func play_bgm(track_name: String):
	var bgm = BGM.get(track_name)
	if bgm: 
		bgm_player.stream = bgm
		bgm_player.play()

func play_sfx(effect_name: String):
	var sfx = SFX.get(effect_name)
	if sfx: 
		sfx_player.stream = sfx
		sfx_player.play()

func play_bounce_sfx(index: int):
	sfx_player.stream = bouncing_sfx_array[index]
	sfx_player.play()
