extends Area2D

@export var amplitude: float = 5.0
@export var frequency: float = 2.0
@export var offset: float = 0.0

var time: float = 0.0
var base_y: float = 0.0 

func _ready() -> void:
	base_y = position.y

func _physics_process(delta: float) -> void:
	time += delta
	
	if abs(position.y - (base_y + amplitude * sin(time * frequency + offset))) > amplitude * 2:
		base_y = position.y
	
	var target_y = base_y + amplitude * sin(time * frequency + offset)
	position.y = lerp(position.y, target_y, 0.1)
