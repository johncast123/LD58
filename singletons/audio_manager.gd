extends Node

@onready var bgm_player = $BGMPlayer
@onready var sfx_player = $SFXPlayer

const BGM: Dictionary = {
	
}

const SFX: Dictionary = {
	
}
func play_bgm(track_name: String):
	var bgm = BGM.get(track_name)
	if bgm: bgm_player.play()

func play_sfx(effect_name: String):
	var sfx = SFX.get(effect_name)
	if sfx: sfx_player.play()
