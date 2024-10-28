extends Area2D
 
var time = 0
@export var game_manager:GameManager
var correct_time = 0

func _physics_process(delta):
	time = float(time) + delta
	update_ui()
	
func update_ui():
	var formatted_time = str(time)
	var decimal_index = formatted_time.find(".")
	
	if decimal_index > 0:
		formatted_time = formatted_time.left(decimal_index + 3)  
	
	Global.speedrun_time = formatted_time
	
	correct_time = formatted_time
	$Label.text = formatted_time
 


func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		var current_time
		var L = game_manager.current_level
		# lol there is a better way to do this, this is a rpoblem that future me will fix
		if L == 1:
			current_time = Global.time_1
		elif L == 2:
			current_time = Global.time_2
		elif L == 3:
			current_time = Global.time_3
		elif L == 4:
			current_time = Global.time_4
		if int(correct_time) < int(current_time) or int(current_time) == 0:
			if L == 1:
				Global.time_1 = correct_time
			elif L == 2:
				Global.time_2 = correct_time
			elif L == 3:
				Global.time_3 = correct_time
			elif L == 4:
				Global.time_4 = correct_time
	$"../CompleteScreen".complete(true)
