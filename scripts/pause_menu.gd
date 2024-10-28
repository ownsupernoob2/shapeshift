extends Control

@export var game_manager:GameManager

func _ready() -> void:
	hide()
	game_manager.connect("toggle_game_paused", _on_game_manager_toggle_game_paused)


func _process(delta: float) -> void:
	pass

func _on_game_manager_toggle_game_paused(is_paused:bool):
	if(is_paused):
		show()
	else:
		hide()


func _on_exit_button_pressed() -> void:
	game_manager.game_paused = false
	get_tree().change_scene_to_file("res://scenes/level_select.tscn")


func _on_resume_button_pressed() -> void:
	game_manager.game_paused = false
