extends Control

@export var game_manager:GameManager

func _ready() -> void:
	hide()


func complete(is_shown:bool):
	if(is_shown):
		show()
		$CompleteSFX.play()
		$Panel/Label2.text = Global.speedrun_time + " sec"
	else:
		hide()

func _on_exit_button_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/level_select.tscn")


func _on_resume_button_pressed() -> void:
	hide()
	get_tree().paused = false
	get_tree().reload_current_scene()


func _on_next_button_pressed() -> void:
	get_tree().paused = false
	var next_level = game_manager.current_level + 1
	if next_level < 5:
		get_tree().change_scene_to_file('res://scenes/levels/level_' + str(next_level) + '.tscn')
	else:
		get_tree().change_scene_to_file('res://scenes/level_select.tscn')
