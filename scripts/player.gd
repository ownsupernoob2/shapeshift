extends CharacterBody2D

@export var speed = 130.0
@export var push_force = 100.0
@export var MAX_SPEED = 30.0
@export var jump_speed = -160.0
@export var gravity_speed = 170.0
@export var MAX_FALL = 10.0

@onready var body: AnimatedSprite2D = $Body
@onready var face: AnimatedSprite2D = $Face
@onready var health_bar: Control = $HealthBar 
signal key_picked_up

@export var acceleration = 700
@export var deceleration = 70
@export var jump_force = 180
@export var allow_square = true
@export var allow_triangle = true
var unit_direction: Vector2
var gravity = Vector2.ZERO
var dead = false
var has_key = false
var key_position = Vector2.ZERO
var can_pickup_key = true
var can_switch = true  # New variable to control switching

var action
var type = Types.CIRCLE
var state = States.FALLING
var prev_state = null
var state_timeout = false

@onready var state_change_timer: Timer = $StateChangeTimer
@onready var death_timer: Timer = $DeathTimer
@onready var switch_timer: Timer = $SwitchTimer  # New timer for switch delay
@onready var key_drop_timer: Timer = $"../KeyDropTimer"
var key_node: Node2D = null
const OFF_SCREEN_POSITION = Vector2(-1000, -1000)
@onready var walk: CPUParticles2D = $walk

enum Types {
	SQUARE,
	CIRCLE,
	TRIANGLE
}

enum States {
	FLOOR,
	WALL_LEFT,
	WALL_RIGHT,
	CEILING,
	FALLING
}

enum Actions {
	MOVE_LEFT,
	MOVE_RIGHT,
	MOVE_UP,
	MOVE_DOWN,
	FALL,
	IDLE
}

func _ready():
	switch_timer = Timer.new()
	switch_timer.wait_time = 1.6
	switch_timer.one_shot = true
	switch_timer.connect("timeout", _on_switch_timer_timeout)
	add_child(switch_timer)

func _physics_process(delta: float) -> void:
	if dead != true:
		if is_on_floor():
			walk.emitting = true
		else:
			walk.emitting = false
		_process_input(delta)
		_process_gravity()
		velocity += gravity * delta
		move_and_slide()
		_update_state()
		_process_animation(delta)
	
		for i in get_slide_collision_count():
			var c = get_slide_collision(i)
			print(c)
			if type == Types.SQUARE and not _ray_down():
				set_collision_mask_value(1, false) 
			else:
				set_collision_mask_value(1, true) 

func _process_input(delta: float):
	if Input.is_action_just_pressed("triangle") and can_switch:
		if type != Types.TRIANGLE:
			start_switch(Types.TRIANGLE)
			
	if Input.is_action_just_pressed("square") and can_switch:
		if type != Types.SQUARE:
			start_switch(Types.SQUARE)
		
	if Input.is_action_just_pressed("circle") and can_switch:
		if type != Types.CIRCLE:
			start_switch(Types.CIRCLE)
			
	if type == Types.CIRCLE:
		_handle_circle_movement(delta)
	else:
		_handle_default_movement()

func start_switch(new_type):
	if can_switch and $Switch.finished:
		can_switch = false
		health_bar.start_progress()
		var tween = create_tween()
		tween.tween_method(set_switch_progress, 100.0, 0.0, 1.5)
		switch_timer.start()
		switch_type(new_type)
		await switch_timer.timeout

func set_switch_progress(value: float):
	health_bar.set_value(value)
	if value < 100:
		health_bar.show()


func _on_switch_timer_timeout():
	can_switch = true

func _handle_circle_movement(delta: float):
	if not is_on_floor():
		velocity.y += gravity_speed * delta
	
	if Input.is_action_just_pressed("move_up") and is_on_floor() and type == Types.CIRCLE:
		velocity.y = -jump_force
	
	var input_direction = Input.get_axis("move_left", "move_right")
	if input_direction != 0:
		velocity.x = move_toward(velocity.x, input_direction * speed, acceleration * delta)
	else:
		velocity.x = move_toward(velocity.x, 0, deceleration * delta)
	
	velocity.x = clamp(velocity.x, -speed, speed)

func _handle_default_movement():
	if state == States.FLOOR or state == States.CEILING or state == States.FALLING:
		if state != States.FALLING:
			velocity.x = 0
		else:
			velocity.x = clamp(velocity.x, -MAX_SPEED, MAX_SPEED)

		if Input.is_action_pressed("move_right"):
			velocity.x += speed
		if Input.is_action_pressed("move_left"):
			velocity.x -= speed

		if Input.is_action_pressed("move_up") and type == Types.CIRCLE and state == States.FLOOR:
			velocity.y = jump_speed
		if type == Types.TRIANGLE:
			if Input.is_action_pressed("move_up") and state == States.FLOOR:
				if _ray_right():
					_enter_state(States.WALL_RIGHT)
				if _ray_left():
					_enter_state(States.WALL_LEFT)

			if state == States.CEILING:
				if Input.is_action_pressed("move_down"):
					if _ray_right():
						_enter_state(States.WALL_RIGHT)
					elif _ray_left():
						_enter_state(States.WALL_LEFT)
					else:
						return

	if type == Types.TRIANGLE and (state == States.WALL_LEFT or state == States.WALL_RIGHT):
		velocity.y = 0 

		if Input.is_action_pressed("move_down"):
			velocity.y += speed
		if Input.is_action_pressed("move_up"):
			velocity.y -= speed

	if _ray_down():
		if Input.is_action_pressed("move_right") and not _ray_right():
			_enter_state(States.FLOOR)
		elif Input.is_action_pressed("move_left") and not _ray_left():
			_enter_state(States.FLOOR)

	elif _ray_up():
		if Input.is_action_pressed("move_right") and not _ray_right():
			_enter_state(States.CEILING)
		elif Input.is_action_pressed("move_left") and not _ray_left():
			_enter_state(States.CEILING)

	else:
		if not _ray_right() and Input.is_action_pressed("move_right"):
			_enter_state(States.FALLING)
		elif not _ray_left() and Input.is_action_pressed("move_left"):
			_enter_state(States.FALLING)

func move_toward(current, target, max_delta):
	if abs(target - current) <= max_delta:
		return target
	return current + sign(target - current) * max_delta

func _process_gravity():
	if type == Types.SQUARE:
		gravity = Vector2(0, gravity_speed * 1.2)  
	elif type == Types.TRIANGLE:
		match state:
			(States.WALL_RIGHT or States.WALL_LEFT) and States.FLOOR:
				gravity = Vector2(0, +gravity_speed * 100)
			States.WALL_RIGHT:
				gravity = Vector2(gravity_speed * 100, 0)
			States.WALL_LEFT:
				gravity = Vector2(-gravity_speed * 100, 0)
			States.CEILING:
				gravity = Vector2(0, -gravity_speed * 100)  
			_:
				if _ray_down():
					gravity = Vector2(0, gravity_speed * 100)
				else:
					gravity = Vector2(0, gravity_speed)
	else:
		gravity = Vector2(0, gravity_speed)

func _update_state():
	if type == Types.CIRCLE or type == Types.SQUARE:
		if not _ray_down() and state != States.FALLING:
			_enter_state(States.FALLING)
	else:
		if not _ray_left() and not _ray_right() and not _ray_down() and not _ray_up() and not (state == States.FALLING):
			_enter_state(States.FALLING)



	if _ray_down():
		_enter_state(States.FLOOR)
	if type == Types.TRIANGLE:
		if _ray_up() or (_ray_left() or _ray_right()):
			_enter_state(States.CEILING)
		if _ray_left() and not _ray_up():
			_enter_state(States.WALL_LEFT)
		if _ray_right() and not _ray_up():
			_enter_state(States.WALL_RIGHT)

func _process_collisions():
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)

func die():
	dead = true
	face.play("dead")
	$Explosion.emitting = true
	$ExplosionSFX.play()
	
	death_timer.start()
	print("u died")

func _enter_state(new_state):
	if new_state != prev_state or state_timeout:
		prev_state = state
		state = new_state
		state_timeout = true

func _on_StateChangeTimer_timeout():
	state_timeout = false

func _ray_up():
	return $Raycasts/RayUp.is_colliding() or $Raycasts/RayUp2.is_colliding()

func _ray_down():
	return $Raycasts/RayDown.is_colliding() or $Raycasts/RayDown2.is_colliding()

func _ray_left():
	return $Raycasts/RayLeft.is_colliding() or $Raycasts/RayLeft2.is_colliding()

func _ray_right():
	return $Raycasts/RayRight.is_colliding() or $Raycasts/RayRight2.is_colliding()

func _process_animation(delta: float):
	if type == Types.CIRCLE:
		var rotation_speed = velocity.x * 0.05 
		body.rotate(rotation_speed * delta)
		face.rotate(rotation_speed * delta)
	else:
		match state:
			States.WALL_LEFT:
				body.rotation_degrees = 90
				face.rotation_degrees = 90 
			States.WALL_RIGHT:
				body.rotation_degrees = -90
				face.rotation_degrees = -90
			States.CEILING:
				body.rotation_degrees = 180
				face.rotation_degrees = 180 
			_:  
				body.rotation_degrees = 0
				face.rotation_degrees = 0

func _on_kill_body_entered(body: Node2D) -> void:
	print("bruh?")
	if (body == self):
		die()

func _on_key_body_entered(body: Node2D) -> void:
	if can_pickup_key and body == self and not has_key:
		has_key = true
		key_position = global_position
		
		key_node = get_parent().get_node("Key")
		if key_node:
			key_node.global_position = OFF_SCREEN_POSITION		
		emit_signal("key_picked_up")
		$KeySFX.play()


func switch_type(new_type):
	if has_key:
		drop_key()
	
	type = new_type
	
	match new_type:
		Types.CIRCLE:
			walk.color = Color(0.373,0.569,1)
			body.play("circle")
			face.play("circle")
			speed = 100
		Types.SQUARE:
			walk.color = Color(1,0,0.11)
			body.play("square")
			face.play("square")
			speed = 50
		Types.TRIANGLE:
			walk.color = Color(0.983,0.769,0)
			body.play("triangle")
			face.play("triangle")
			speed = 100
	$Switch.play()


func drop_key():
	if has_key and key_node:
		has_key = false
		can_pickup_key = false
		
		key_node.global_position = global_position
		
		key_drop_timer.start()

func _on_key_drop_timer_timeout():
	can_pickup_key = true

func _on_death_timer_timeout() -> void:
	get_tree().reload_current_scene()


func _on_door_body_entered(body: Node2D) -> void:
	key_node = get_parent().get_node("Key")
	if key_node:
		if has_key and body == self:
			Global.speedrun_time = 0
			$CompleteSFX.play()
	else:
		Global.speedrun_time = 0
		$CompleteSFX.play()
