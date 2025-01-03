extends CharacterBody2D

@export var speed = 130.0
@export var push_force = 2000.0
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
@export var has_key = false
var unit_direction: Vector2
var gravity = Vector2.ZERO
var dead = false
var key_position = Vector2.ZERO
var can_pickup_key = true
var can_switch = true  

var action
var type = Types.CIRCLE
var state = States.FALLING
var prev_state = null
var state_timeout = false
var previous_platform_pos: Vector2

@onready var wall_delay: Timer = $WallDelay
@onready var state_change_timer: Timer = $StateChangeTimer
@onready var death_timer: Timer = $DeathTimer
@onready var switch_timer: Timer = $SwitchTimer  
@onready var key_drop_timer: Timer = $"KeyDropTimer"
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

var previous_move

func _ready():
	switch_timer = Timer.new()
	switch_timer.wait_time = 1
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


	if state == States.CEILING and _ray_up():
		for i in get_slide_collision_count():
			var collision = get_slide_collision(i)
			var platform = collision.get_collider()
			if platform is AnimatableBody2D:
				if previous_platform_pos == Vector2.ZERO:
					previous_platform_pos = platform.position
					return
					
				var platform_movement = platform.position - previous_platform_pos
				platform_movement.x = clamp(platform_movement.x, -10, 10)
				position.x += platform_movement.x
				
				previous_platform_pos = platform.position
	else:
		previous_platform_pos = Vector2.ZERO
		_update_state()
		_process_animation(delta)
		for i in get_slide_collision_count():
			var c = get_slide_collision(i)
			if type == Types.SQUARE:
				if c.get_collider() is RigidBody2D:
					c.get_collider().apply_central_impulse(-c.get_normal() * push_force)

func _process_input(delta: float):
	if Input.is_action_just_pressed("triangle") and can_switch and allow_triangle:
		if type != Types.TRIANGLE:
			start_switch(Types.TRIANGLE)
			
	if Input.is_action_just_pressed("square") and can_switch and allow_square:
		if type != Types.SQUARE:
			start_switch(Types.SQUARE)
		
	if Input.is_action_just_pressed("circle") and can_switch:
		if type != Types.CIRCLE:
			start_switch(Types.CIRCLE)
			
	if type == Types.CIRCLE:
		_handle_circle_movement(delta)
	else:
		_handle_default_movement(delta)

func start_switch(new_type):
	if can_switch and $Switch.finished:
		can_switch = false
		health_bar.start_progress()
		var tween = create_tween()
		tween.tween_method(set_switch_progress, 100.0, 0.0, 1)
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

func _handle_default_movement(delta: float):
	if state == States.FLOOR or state == States.CEILING or state == States.FALLING:
		if state != States.FALLING:
			velocity.x = 0
		else:
			velocity.x = clamp(velocity.x, -MAX_SPEED, MAX_SPEED)

		if Input.is_action_pressed("move_right"):
			previous_move = "right"
			velocity.x += speed
		if Input.is_action_pressed("move_left"):
			previous_move = "left"
			velocity.x -= speed

		if Input.is_action_pressed("move_up") and type == Types.CIRCLE and state == States.FLOOR:
			velocity.y = jump_speed
			previous_move = "up"
		if type == Types.TRIANGLE:
			if Input.is_action_pressed("move_up") and state == States.FLOOR:
				previous_move = "up"
				if _ray_right():
					_enter_state(States.WALL_RIGHT)
				if _ray_left():
					_enter_state(States.WALL_LEFT)

			if state == States.CEILING:
				if Input.is_action_pressed("move_down"):
					previous_move = "down"
					if _ray_right():
						_enter_state(States.WALL_RIGHT)
					elif _ray_left():
						_enter_state(States.WALL_LEFT)
					else:
						return

	if type == Types.TRIANGLE and (state == States.WALL_LEFT or state == States.WALL_RIGHT):
		velocity.y = 0 
		if Input.is_action_pressed("move_down"):
			previous_move = "down"
			velocity.y += speed
		if Input.is_action_pressed("move_up"):
			previous_move = "up"
			velocity.y -= speed
	
	if _ray_top_right() and not _ray_up() and not _ray_right() and (previous_move == "left" or "up" ):
		global_position.y += -3
	if _ray_top_right() and not _ray_up() and not _ray_right() and (previous_move == "down" ):
		global_position.x += 5
		global_position.y += 2
	if _ray_bottom_right() and not _ray_down() and not _ray_right()  and (previous_move == "up"):
		global_position.x += 4
		global_position.y += -3
	if _ray_bottom_right() and not _ray_down() and not _ray_right()  and (previous_move == "left"):
		global_position.y += 3
		
	if _ray_top_left() and not _ray_up() and not _ray_left() and  (previous_move == "right" or "up" ):
		global_position.y += -3
	if _ray_top_left() and not _ray_up() and not _ray_left() and (previous_move == "down" ):
		global_position.x += -5
		global_position.y += 2
	if _ray_bottom_left() and not _ray_down() and not _ray_left()  and (previous_move == "up"):
		global_position.x += -4
		global_position.y += -3
	if _ray_bottom_left() and not _ray_down() and not _ray_left()  and (previous_move == "right"):
		global_position.y += 3
		

	
	if _ray_down():
		if Input.is_action_pressed("move_right") and not _ray_right():
			_enter_state(States.FLOOR)
		elif Input.is_action_pressed("move_left") and not _ray_left():
			_enter_state(States.FLOOR)
		elif (Input.is_action_pressed("move_left") or Input.is_action_pressed("move_left")) and (_ray_left() or _ray_right()):
			_enter_state(States.FLOOR)


	elif _ray_up():
		if Input.is_action_pressed("move_right") and not _ray_right():
			_enter_state(States.CEILING)
		elif Input.is_action_pressed("move_left") and not _ray_left():
			_enter_state(States.CEILING)

	else:
		pass
		#if not _ray_right() and Input.is_action_pressed("move_right"):
			#_enter_state(States.FALLING)
		#elif not _ray_left() and Input.is_action_pressed("move_left"):
			#_enter_state(States.FALLING)

func move_toward(current, target, max_delta):
	if abs(target - current) <= max_delta:
		return target
	return current + sign(target - current) * max_delta

func _process_gravity():
	if type == Types.SQUARE:
		gravity = Vector2(0, gravity_speed * 1.5)  
	elif type == Types.TRIANGLE:
		match state:
			(States.WALL_RIGHT or States.WALL_LEFT) and States.FLOOR:
				gravity = Vector2(0, gravity_speed * 100)
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
					gravity = Vector2(0, gravity_speed * 2)
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

func _enter_state(new_state):
	if new_state != prev_state or state_timeout:
		prev_state = state
		state = new_state
		state_timeout = true

func _on_StateChangeTimer_timeout():
	state_timeout = false


func _ray_top_right():
	return $Raycasts/RayTopRight.is_colliding()
	
	
func _ray_top_left():
	return $Raycasts/RayTopLeft.is_colliding()
	
	
func _ray_bottom_right():
	return $Raycasts/RayBottomRight.is_colliding()
	
func _ray_bottom_left():
	return $Raycasts/RayBottomLeft.is_colliding()


func _ray_up():
	return $Raycasts/RayUp.is_colliding()

func _ray_down():
	return $Raycasts/RayDown.is_colliding()

func _ray_left():
	return $Raycasts/RayLeft.is_colliding() 

func _ray_right():
	return $Raycasts/RayRight.is_colliding()

func _process_animation(delta: float):
	if type == Types.CIRCLE:
		var rotation_speed = velocity.x * 0.05 
		body.rotate(rotation_speed * delta)
		face.rotate(rotation_speed * delta)
	elif type == Types.TRIANGLE:
		match state:
			States.FLOOR:
				body.rotation_degrees = 0
				face.rotation_degrees = 0
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
	else:
		body.rotation_degrees = 0
		face.rotation_degrees = 0

func _on_kill_body_entered(body: Node2D) -> void:
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




func _on_wall_delay_timeout() -> void:
	if _ray_top_right():
		global_position.x + 100
