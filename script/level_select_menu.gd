extends Control

signal level_select_chosen(level: String)
signal level_select_abort

const LEVEL_SELECT_BUTTON_NODE: PackedScene = preload("res://components/level_select_button.tscn")

@onready var vboxcontainer: VBoxContainer = $MarginContainer/ScrollContainer/VBoxContainer


func _ready() -> void:
	var level_list: Dictionary = load_level_list()
	for level: String in level_list:
		var button: LevelSelectButton = LEVEL_SELECT_BUTTON_NODE.instantiate()
		button.name = level
		button.text = level
		button.scene = level_list[level]
		button.pressed_with_node.connect(_on_level_button_pressed)
		vboxcontainer.add_child(button)

	# Remove placeholder button and set focus
	vboxcontainer.get_node("Button").queue_free()
	vboxcontainer.get_child(1).grab_focus()
	$MarginContainer/ScrollContainer.set_deferred("scroll_vertical", 0)

	#Controller.controller_status_changed.connect(_on_controller_changed)



func load_level_list() -> Dictionary:
	var json_as_text: String = FileAccess.get_file_as_string("res://levels.json")
	var json_as_dict: Dictionary = JSON.parse_string(json_as_text) 
	return json_as_dict



func _process(_delta: float) -> void:
	if not visible:
		return



	if Input.is_action_just_pressed("ui_end"):
		vboxcontainer.get_child(-1).grab_focus()
	elif Input.is_action_just_pressed("ui_home"):
		vboxcontainer.get_child(0).grab_focus()
	elif Input.is_action_just_pressed("ui_page_down"):
		_handle_pgup_pgdn(false)
	elif Input.is_action_just_pressed("ui_page_up"):
		_handle_pgup_pgdn(true)


func _handle_pgup_pgdn(up: bool = false) -> void:
	var focus_holder: Node = get_viewport().gui_get_focus_owner()
	if focus_holder is LevelSelectButton:
		var fh_idx: int = vboxcontainer.get_children().find(focus_holder)
		var new_fh_idx: int

		if up:
			new_fh_idx = max(fh_idx - 8, 0)
		else:
			new_fh_idx = min(fh_idx + 8, vboxcontainer.get_child_count() - 1)

		vboxcontainer.get_child(new_fh_idx).grab_focus()


func _on_level_button_pressed(button: LevelSelectButton) -> void:
	print(button.text)
	print(button.scene)
	level_select_chosen.emit(button.scene)

func enable_menu() -> void:
	show()
	$MarginContainer/ScrollContainer.set_deferred("scroll_vertical", 0)
	set_process(true)
	vboxcontainer.get_child(0).grab_focus()


func disable_menu() -> void:
	hide()
	set_process(false)
