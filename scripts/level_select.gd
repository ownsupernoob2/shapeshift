extends Control

@export var is_full_screen: bool = false
@onready var click: AudioStreamPlayer = $AudioStreamPlayer


# THERE IS A WAY BETTER WAY TO DO THIS BUT IM LAZY (IN THE BAD WAY) BEYOND COMPHERHENSION

func _on_back_pressed() -> void:
		click.play()
		get_tree().change_scene_to_file("res://menu.tscn")



func _on_level_1_pressed() -> void:
	click.play()
	get_tree().change_scene_to_file("res://scenes/levels/level_1.tscn")




func _on_level_2_pressed() -> void:
	click.play()
	get_tree().change_scene_to_file("res://scenes/levels/demo.tscn")



func _on_level_3_pressed() -> void:
	click.play()



func _on_level_4_pressed() -> void:
	click.play()




func _on_level_1_mouse_entered() -> void:
	$Level1/Label.text = "Best: " + str(Global.time_1) + " sec"


func _on_level_2_mouse_entered() -> void:
	$Level2/Label.text = "Best: " + str(Global.time_2) + " sec"


func _on_level_3_mouse_entered() -> void:
	$Level3/Label.text = "Best: " + str(Global.time_3) + " sec"



func _on_level_4_mouse_entered() -> void:
	$Level4/Label.text = "Best: " + str(Global.time_4) + " sec"




func _on_level_1_mouse_exited() -> void:
	$Level1/Label.text = ""


func _on_level_2_mouse_exited() -> void:
	$Level2/Label.text = ""


func _on_level_3_mouse_exited() -> void:
	$Level3/Label.text = ""



func _on_level_4_mouse_exited() -> void:
	$Level4/Label.text = ""
