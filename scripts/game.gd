extends Node2D

class_name GameManager

signal toggle_game_paused(is_paused:bool)

func _ready() -> void:
	AudioPlayer.stop()

@export var current_level:int = 0

var game_paused:bool = false:
	get:
		return game_paused
	set(value):
		game_paused = value
		get_tree().paused = game_paused
		emit_signal("toggle_game_paused", game_paused)

func _input(event: InputEvent):
	if Input.is_action_just_pressed("reset"):
		get_tree().reload_current_scene()
	if(event.is_action_pressed("ui_cancel")):
		game_paused = !game_paused
