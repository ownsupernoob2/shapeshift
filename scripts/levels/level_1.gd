extends Node2D

@export var game_manager:GameManager

func _ready() -> void:
	game_manager.current_level = 1
