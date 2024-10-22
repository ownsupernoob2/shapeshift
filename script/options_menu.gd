extends Control

@export var is_full_screen: bool = false
var music_bus = AudioServer.get_bus_index("Music")
var sfx_bus = AudioServer.get_bus_index("SFX")
@onready var click: AudioStreamPlayer = $AudioStreamPlayer


func _on_back_pressed() -> void:
		click.play()
		get_tree().change_scene_to_file("res://menu.tscn")


func _on_fullscreen_toggled(toggled_on: bool) -> void:
	click.play()
	if toggled_on == true:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)


func _on_music_value_changed(value: float) -> void:
	click.play()
	
	AudioServer.set_bus_volume_db(music_bus, value)
	if value == -30:
		AudioServer.set_bus_mute(music_bus,true)
	else:
		AudioServer.set_bus_mute(music_bus,false)

func _on_effect_value_changed(value: float) -> void:
	click.play()
	AudioServer.set_bus_volume_db(sfx_bus, value)
	if value == -30:
		AudioServer.set_bus_mute(sfx_bus,true)
	else:
		AudioServer.set_bus_mute(sfx_bus,false)
