extends AudioStreamPlayer

const menu_music = preload("res://assets/music/menu.mp3")

@export var volume = 0.0

func _play_music(music: AudioStream, volume = 0.0):
	if stream == music:
		return
	stream = music
	volume_db = volume
	play()

	
func play_music_level():
	_play_music(menu_music)


func _on_finished() -> void:
	play()
