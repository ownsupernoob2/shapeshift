extends Node2D

class_name GameManager

signal toggle_game_paused(is_paused:bool)

@export var current_level:int = 1
@export var level_paths:Array = [
	"res://scenes/level_1.tscn",
	"res://scenes/level_2.tscn",
	"res://scenes/level_3.tscn",
	"res://scenes/level_4.tscn"
]

var game_paused:bool = false:
	get:
		return game_paused
	set(value):
		game_paused = value
		get_tree().paused = game_paused
		emit_signal("toggle_game_paused", game_paused)

func _ready() -> void:
	AudioPlayer.stop()

func _input(event: InputEvent):
	if Input.is_action_just_pressed("reset"):
		get_tree().reload_current_scene()
	if(event.is_action_pressed("ui_cancel")):
		game_paused = !game_paused

func get_next_level() -> String:
	if current_level + 1 < level_paths.size():
		current_level += 1
		return level_paths[current_level]
	return "" 
