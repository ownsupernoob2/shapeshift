extends Control

@export var game_manager:GameManager

func _ready() -> void:
	hide()


func complete(is_shown:bool):
	if(is_shown):
		show()
		$Panel/Label2.text = Global.speedrun_time + " sec"
	else:
		hide()

func _on_exit_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/level_select.tscn")


func _on_resume_button_pressed() -> void:
	hide()
	get_tree().reload_current_scene()
