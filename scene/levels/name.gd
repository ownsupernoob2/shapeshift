extends Label

@export var fade_duration: float = 1.0  
@export var fade_delay: float = 0.5    

func _ready():
	modulate.a = 1.0
	
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_LINEAR)
	
	if fade_delay > 0:
		tween.tween_interval(fade_delay)
	
	tween.tween_property(self, "modulate:a", 0.0, fade_duration)
