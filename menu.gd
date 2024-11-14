extends Control
@onready var click: AudioStreamPlayer = $AudioStreamPlayer
@onready var clown: Sprite2D = $Clown
@onready var clown_2: AudioStreamPlayer = $Clown/Clown2
@onready var moai: Sprite2D = $Moai
@onready var gojo: Sprite2D = $Gojo
@onready var gojo2: AudioStreamPlayer = $Gojo/Gojo
@onready var moai2: AudioStreamPlayer = $Moai/Moai/Moai2
@onready var gojo_2: Sprite2D = $Gojo2

func _ready():
	clown.hide()
	moai.hide()
	gojo.hide()
	gojo_2.hide()
	if Global.clown == true:
		clown.show()
		clown_2.play()
		AudioPlayer.stop()
	elif Global.moai == true:
		moai.show()
		moai2.play()
		AudioPlayer.stop()
	elif Global.gojo == true:
		gojo.show()
		gojo_2.show()
		gojo2.play()
		AudioPlayer.stop()
	else:
		AudioPlayer.play_music_level()

func _on_play_pressed() -> void:
	click.play()
	get_tree().change_scene_to_file("res://scenes/level_select.tscn")


func _on_options_pressed() -> void:
	click.play()
	get_tree().change_scene_to_file("res://scenes/options_menu.tscn")


func _on_exit_pressed() -> void:
	get_tree().quit()


func _on_leaderboard_pressed() -> void:
	click.play()
	get_tree().change_scene_to_file("res://scenes/leaderboard.tscn")
