extends Area2D

var time: float = 0.0
var key_node: Node2D = null
@export var game_manager: GameManager
var correct_time: float = 0.0
const PLAYER_PATH = "res://scenes/player.tscn"
var is_door_open: bool = false
var is_player_near: bool = false

@onready var left_door: CharacterBody2D = $LeftDoor
@onready var right_door: CharacterBody2D = $RightDoor
@onready var door_sensor: Area2D = $DoorSensor

@export var open_distance: float = 20.0
@export var open_speed: float = 30.0



func _physics_process(delta: float) -> void:
	time += delta
	update_ui()
	if is_door_open:
		if right_door.position.x > -open_distance / 2:
			right_door.position.x -= open_speed * delta
			left_door.position.x += open_speed * delta
	else:
		if right_door.position.x < 0:
			right_door.position.x += open_speed * delta
			left_door.position.x -= open_speed * delta


func _on_door_sensor_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		var player_instance = get_node(body.get_path())
		key_node = get_parent().get_node("Key")
		if key_node:
			if player_instance.has_key:
				is_door_open = true  
			else:
				is_door_open = false
		else:
			is_door_open = true

func _on_door_sensor_body_exited(body: Node2D) -> void:
	if body.name == "Player":
		is_door_open = false  
		print("Player exited, closing doors")
		
func update_ui() -> void:
	var formatted_time: String = str(time)
	var decimal_index: int = formatted_time.find(".")

	if decimal_index > 0:
		formatted_time = formatted_time.left(decimal_index + 3)

	Global.speedrun_time = formatted_time
	correct_time = time
	$Label.text = formatted_time

	if game_manager == null:
		$Label.modulate = Color(1.0, 1.0, 1.0)  
	else:
		var current_time: float = Global.level_times[game_manager.current_level]
		if current_time == 0:
			$Label.modulate = Color(1.0, 1.0, 1.0)  
		elif current_time < correct_time:
			$Label.modulate = Color(1.0, 0.303, 0.317)  
		else:
			$Label.modulate = Color(0.224, 0.696, 0.321)


func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		key_node = get_parent().get_node("Key")
		var player_instance = get_node(body.get_path())
		var formatted_time: String = str(time)
		var decimal_index: int = formatted_time.find(".")
		if decimal_index > 0:
			formatted_time = formatted_time.left(decimal_index + 3)
		var current_time: float = Global.level_times[game_manager.current_level]
		if key_node:
			if player_instance.has_key:
				print(correct_time)
				print(current_time)
				if correct_time < current_time or current_time == 0.0:
					$"../../CompleteScreen".complete(true)
					Global.allow_submit = true
					Global.level_times[game_manager.current_level] = float(formatted_time)
					pause_game()
			else:
				print('stoopid')
		else:
			$"../../CompleteScreen".complete(true)
			print(Global.level_times[game_manager.current_level])
			if correct_time < current_time or current_time == 0.0:
				Global.allow_submit = true
				Global.level_times[game_manager.current_level] = float(formatted_time)
			pause_game()

func pause_game() -> void:
	get_tree().paused = true
