extends CharacterBody2D

@export var speed = 130.0
@export var push_force = 100.0
@export var MAX_SPEED = 30.0
@export var jump_speed = -160.0
@export var gravity_speed = 170.0
@export var MAX_FALL = 10.0
@export var MAX_DASH = 2.0
@export var DASH_MODIFIER = 1.5
@export var DASH_SPEED = Vector2(300, 300)
@onready var body: AnimatedSprite2D = $Body
@onready var face: AnimatedSprite2D = $Face
signal key_picked_up

@export var acceleration = 700
@export var deceleration = 70
@export var jump_force = 180

var unit_direction: Vector2
var gravity = Vector2.ZERO
var dead = false
var has_key = false
var key_position = Vector2.ZERO
var can_pickup_key = true

var action
var type = Types.CIRCLE
var state = States.FALLING
var prev_state = null
var state_timeout = false
var dash_timeout = false
var dash_charge = 0
var charging = false

@onready var key_drop_timer: Timer = $"../KeyDropTimer"
var key_node: Node2D = null
const OFF_SCREEN_POSITION = Vector2(-1000, -1000)

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
	DASHING,
	FALLING
}

enum Actions {
	MOVE_LEFT,
	MOVE_RIGHT,
	MOVE_UP,
	MOVE_DOWN,
	DASH,
	FALL,
	IDLE
}

func _physics_process(delta: float) -> void:
	if dead:
		print("hi")
		return
	_process_input(delta)
	_process_gravity()
	velocity += gravity * delta
	move_and_slide()
	#_process_collisions()
	_update_state()
	_process_animation(delta)
	
	for i in get_slide_collision_count():
		var c = get_slide_collision(i)
		#if type == Types.SQUARE:
			#set_collision_mask_value(1, false) 
#
		#else:
			#set_collision_mask_value(1, true) 
		if c.get_collider() is RigidBody2D and type == Types.SQUARE:
			c.get_collider().apply_central_impulse(-c.get_normal() * push_force)

func _process_input(delta: float):
	if Input.is_action_just_pressed("e"):
		if type != Types.TRIANGLE:
			switch_type(Types.TRIANGLE)
			
	if Input.is_action_just_pressed("r"):
		if type != Types.SQUARE:
			switch_type(Types.SQUARE)
		
	if Input.is_action_just_pressed("q"):
		if type != Types.CIRCLE:
			switch_type(Types.CIRCLE)
			
	if type == Types.CIRCLE:
		_handle_circle_movement(delta)
	else:
		_handle_default_movement()

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
			States.DASHING:
				gravity = Vector2.ZERO 
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
		if not _ray_down() and state != States.DASHING and state != States.FALLING:
			_enter_state(States.FALLING)
	else:
		if not _ray_left() and not _ray_right() and not _ray_down() and not _ray_up() and not (state == States.DASHING or state == States.FALLING):
			_enter_state(States.FALLING)

	if state == States.DASHING and dash_charge <= 0:
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
	if (body.name == "Player2"):
		get_tree().reload_current_scene()
		
func _on_key_body_entered(body: Node2D) -> void:
	print("Key body entered by: ", body.name)
	if can_pickup_key and body == self and not has_key:
		print("Picking up key")
		has_key = true
		key_position = global_position
		
		key_node = get_parent().get_node("Key")
		if key_node:
			print("Moving key off-screen")
			key_node.global_position = OFF_SCREEN_POSITION
		else:
			print("Could not find Key node in the scene")
		
		emit_signal("key_picked_up")
		print("Key picked up: ", has_key)
	else:
		print("Cannot pick up key. can_pickup_key: ", can_pickup_key, ", body is self: ", body == self, ", has_key: ", has_key)

func switch_type(new_type):
	if has_key:
		drop_key()
	
	type = new_type
	
	match new_type:
		Types.CIRCLE:
			body.play("circle")
			face.play("circle")
			speed = 100
		Types.SQUARE:
			body.play("square")
			face.play("square")
			speed = 50
		Types.TRIANGLE:
			body.play("triangle")
			face.play("triangle")
			speed = 100

func drop_key():
	if has_key and key_node:
		has_key = false
		can_pickup_key = false
		
		key_node.global_position = global_position
		
		key_drop_timer.start()

func _on_key_drop_timer_timeout():
	can_pickup_key = true
