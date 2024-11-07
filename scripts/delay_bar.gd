extends Control

func _ready():
	hide()
	modulate.a = 1.0  

func start_progress():
	show() 
	modulate.a = 1.0  
	var tween = create_tween()
	tween.tween_method(set_value, 100.0, 0.0, 1) 
	tween.chain().tween_property(self, "modulate:a", 0.0, 0.3)
	tween.finished.connect(func(): hide())

func set_value(value):
	$TextureProgressBar.value = value
	
