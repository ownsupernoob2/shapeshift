extends Control

@export var is_full_screen: bool = false
@onready var click: AudioStreamPlayer = $AudioStreamPlayer


func _on_back_pressed() -> void:
		click.play()
		get_tree().change_scene_to_file("res://menu.tscn")



func _on_level_1_pressed() -> void:
	click.play()
	get_tree().change_scene_to_file("res://scene/levels/level_1.tscn")




func _on_level_2_pressed() -> void:
	click.play()
	get_tree().change_scene_to_file("res://scene/levels/demo.tscn")



func _on_level_3_pressed() -> void:
	click.play()



func _on_level_4_pressed() -> void:
	click.play()
