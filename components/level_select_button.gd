class_name LevelSelectButton
extends Button

## Pressed signal with the pressed node (button) as argument.
signal pressed_with_node(button: Button)

@export var scene: String


func _on_pressed() -> void:
	pressed_with_node.emit(self)
