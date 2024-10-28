extends Control
@onready var click: AudioStreamPlayer = $AudioStreamPlayer

func _ready():
	AudioPlayer.play_music_level()

func _on_play_pressed() -> void:
	click.play()
	get_tree().change_scene_to_file("res://scenes/level_select.tscn")


func _on_options_pressed() -> void:
	click.play()
	get_tree().change_scene_to_file("res://scenes/options_menu.tscn")


func _on_exit_pressed() -> void:
	get_tree().quit()
