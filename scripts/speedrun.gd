extends Area2D

var time: float = 0.0
var key_node: Node2D = null
@export var game_manager: GameManager
var correct_time: float = 0.0
const PLAYER_PATH = "res://scenes/player.tscn"

func _physics_process(delta: float) -> void:
	time += delta
	update_ui()

func update_ui() -> void:
	var formatted_time: String = str(time)
	var decimal_index: int = formatted_time.find(".")

	if decimal_index > 0:
		formatted_time = formatted_time.left(decimal_index + 3)

	Global.speedrun_time = formatted_time
	correct_time = time
	$Label.text = formatted_time

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		key_node = get_parent().get_node("Key")
		var player_instance = get_node(body.get_path())
		var formatted_time: String = str(time)
		var decimal_index: int = formatted_time.find(".")
		$"../../CompleteScreen".complete(true)
		if decimal_index > 0:
			formatted_time = formatted_time.left(decimal_index + 3)
		var current_time: float = Global.level_times[game_manager.current_level]
		if key_node:
			if player_instance.has_key:
				if correct_time < current_time or current_time == 0.0:
					Global.level_times[game_manager.current_level] = float(formatted_time)
					pause_game()
			else:
				print('stoopid')
		else:
			print(Global.level_times[game_manager.current_level])
			Global.level_times[game_manager.current_level] = float(formatted_time)
			pause_game()

func pause_game() -> void:
	get_tree().paused = true
