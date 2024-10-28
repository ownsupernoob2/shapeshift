extends Control

func _ready():
	hide()
	modulate.a = 1.0  # Ensure it starts fully opaque for next time

func start_progress():
	show()  # Show the bar
	modulate.a = 1.0  # Reset opacity to fully visible
	
	var tween = create_tween()
	tween.tween_method(set_value, 100.0, 0.0, 1.5)  # Progress from 100 to 0
	# When progress hits 0, fade out
	tween.chain().tween_property(self, "modulate:a", 0.0, 0.3)
	tween.finished.connect(func(): hide())

func set_value(value):
	$TextureProgressBar.value = value
	
