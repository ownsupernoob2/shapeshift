extends Control

@onready var http_request: HTTPRequest = $HTTPRequest
var username
@onready var tname: LineEdit = $name
@onready var err: Label = $err

func _ready():
	http_request.request_completed.connect(_on_request_completed)
	err.text = ""

func url_encode(text: String) -> String:
	return text.replace(" ", "%20")

func make_request():
	var url = "https://profanity-filter-by-api-ninjas.p.rapidapi.com/v1/profanityfilter?text=" + url_encode(tname.text)
	var headers = [
		"X-Rapidapi-Key: 3ad2202020msh8d5bab82e780228p1295d2jsn66dfd8356489",
		"X-Rapidapi-Host: profanity-filter-by-api-ninjas.p.rapidapi.com",
		"User-Agent: GodotEngine/4.3"
	]
	err.text = "Breathing helps you live..."
	http_request.request(url, headers)

func _on_request_completed(result, response_code, headers, body):
	if response_code == 200:
		var json = JSON.parse_string(body.get_string_from_utf8())
		print(json)
		if json["has_profanity"]:
			tname.clear()
			Global.clown = true
			err.text = "Did your parents name you that?"
		else:
			username = tname.text
			err.text = "Loading..."
			var submitted_count = 0
			
			# Only submit scores for levels with times > 0
			if Global.level_times[1] > 0:
				await Leaderboards.post_guest_score("shapeshift-level_1-9PYe", Global.level_times[1], username)
				submitted_count += 1
			if Global.level_times[2] > 0:
				await Leaderboards.post_guest_score("shapeshift-level_2-xgIe", Global.level_times[2], username)
				submitted_count += 1
			if Global.level_times[3] > 0:
				await Leaderboards.post_guest_score("shapeshift-level_3-JE59", Global.level_times[3], username)
				submitted_count += 1
			if Global.level_times[4] > 0:
				await Leaderboards.post_guest_score("shapeshift-level_4-Ivrs", Global.level_times[4], username)
				submitted_count += 1
			if Global.level_times[5] > 0:
				await Leaderboards.post_guest_score("shapeshift-level_5-rASI", Global.level_times[5], username)
				submitted_count += 1
				
			if submitted_count > 0:
				err.text = "Added your scores successfully (refresh by going back)"
			else:
				err.text = "No valid times to submit"
	else:
		print("Request failed with response code:", response_code)

func submit():
	if tname.text == "Mina":
		err.text = "Woah! Who is that guy?"
		Global.moai = true
	elif tname.text == "Gojo":
		err.text = "Nah, name taken lil bro"
		Global.gojo = true
	elif tname.text == "Sukuna":
		err.text = "Grr, that's my boy >:("
		Global.gojo = true
	else:
		if Global.clown:
			err.text = "Guess what? Chicken butt!"
		else:
			$Save.disabled = true
			err.text = "Loading..."
			
			# Check if there's at least one completed level
			var has_valid_time = false
			for i in range(1, Global.level_times.size()):
				if Global.level_times[i] > 0:
					has_valid_time = true
					break
					
			if Global.allow_submit == true:
				if has_valid_time:
					Global.allow_submit = false
					if tname.text == "":
						err.text = "Put a name for yourself"
					else:
						await make_request()
				else:
					err.text = "Complete at least one level to submit your time"
			else:
				err.text = "At least beat your time in one of the levels bro"
			$Save.disabled = false

func _on_line_edit_text_submitted(new_text: String) -> void:
	submit()

func _on_save_pressed() -> void:
	submit()

func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://menu.tscn")
