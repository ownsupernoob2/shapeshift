extends GridContainer

var player_list_with_pos = []
@export var level: int = 1
var links: Array[String] = ['0', 'shapeshift-level_1-9PYe', 'shapeshift-level_2-xgIe', 'shapeshift-level_3-JE59', 'shapeshift-level_4-Ivrs', 'shapeshift-level_5-rASI',]  


func _ready() -> void:
	load_leaderboard(level)

func load_leaderboard(level: int) -> void:
	for child in get_children():
		child.queue_free()
	
	if level > 1:
		await get_tree().create_timer(level).timeout
	if level > 2:
		await get_tree().create_timer(level).timeout
	if level > 3:
		await get_tree().create_timer(1).timeout
	if level > 4:
		await get_tree().create_timer(2).timeout
	if level > 6:
		await get_tree().create_timer(3).timeout
	
	var current_link = links[level]
	print("Loading leaderboard for level ", level, " with link: ", current_link)
	
	var sw_result: Dictionary = await Leaderboards.get_scores(current_link)
	player_list_with_pos = sw_result.scores
	print(sw_result.scores)
	add_player_to_grid(player_list_with_pos)

func add_player_to_grid(player_list):
	var pos_vbox = VBoxContainer.new()
	var name_vbox = VBoxContainer.new()
	var score_vbox = VBoxContainer.new()
	
	for score_data in player_list_with_pos:
		var pos_label = Label.new()
		pos_label.text = str(score_data["rank"])
		pos_label.show()
		pos_vbox.add_child(pos_label)
	add_child(pos_vbox)
	
	for score_data in player_list_with_pos:
		var name_label = Label.new()
		name_label.text = str(score_data["name"])
		name_label.show()
		name_vbox.add_child(name_label)
	add_child(name_vbox)
	
	for score_data in player_list_with_pos:
		var score_label = Label.new()
		score_label.text = str(score_data["score"])
		score_label.show()
		score_vbox.add_child(score_label)
	add_child(score_vbox)

func sort_by_score_ascending(a, b):
	return a["score"] < b["score"]

func sort_players_and_add_position(player_list):
	player_list.sort_custom(sort_by_score_ascending)
	
	var position = 1
	for player in player_list:
		player["rank"] = position
		position += 1
		
	return player_list

func on_tab_selected(tab: int) -> void:
	var level = tab + 1
	load_leaderboard(level)

func load_all_leaderboards(max_level: int) -> void:
	for level in range(1, max_level + 1):
		await load_leaderboard(level)
