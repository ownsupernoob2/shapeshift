extends CharacterBody2D

const SPEED = 150.0
const JUMP_VELOCITY = -400.0
const GRAVITY = 1000
const CLIMB_SPEED = 150.0
const SURFACE_STICK_FORCE = 500.0

var is_climbing = false
var surface_cooldown = 0.0

# Helper function to check if touching any surface
func is_on_surface() -> bool:
	return is_on_floor() or is_on_wall() or is_on_ceiling()

# This function checks for ledges and smoothly transitions to the next surface.
func handle_surface_transition() -> void:
	for i in range(get_slide_collision_count()):
		var collision = get_slide_collision(i)
		if collision:
			# Get the normal of the current collision surface
			var normal = collision.get_normal()
			
			# If there's a normal and it's different from the current velocity, adjust the velocity
			if normal.dot(velocity.normalized()) < 0.0:
				# Project velocity onto the surface normal to maintain sticking
				velocity = velocity.slide(normal)

func _physics_process(delta: float) -> void:
	# Reset climbing state
	is_climbing = false
	
	# Handle surface cooldown logic
	if is_on_surface():
		surface_cooldown = 0.1  # Small cooldown to prevent immediate detachment
	elif surface_cooldown > 0:
		surface_cooldown -= delta
	
	# Apply gravity when not touching any surface
	if not is_on_surface() and surface_cooldown <= 0:
		velocity.y += GRAVITY * delta

	# Get input direction
	var direction = Input.get_axis("ui_left", "ui_right")

	# Handle horizontal movement
	if is_on_floor() or is_on_ceiling():
		# Allow regular movement on the floor or ceiling
		velocity.x = direction * SPEED
	elif is_on_wall() and not is_on_floor():
		# Stick to walls, no horizontal movement allowed
		velocity.x = 0
	else:
		# Allow free movement in the air
		velocity.x = direction * SPEED

	# Handle climbing and sticking to walls
	if is_on_wall():
		var up_input = Input.get_axis("ui_up", "ui_down")
		if up_input != 0:  # Climbing up or down
			velocity.y = up_input * CLIMB_SPEED
			is_climbing = true
		else:
			velocity.y = 0  # Stick to the wall when not climbing

		# Apply surface sticking force to walls
		for i in range(get_slide_collision_count()):
			var collision = get_slide_collision(i)
			if collision:  # Check if collision is valid
				velocity += -collision.get_normal() * SURFACE_STICK_FORCE

	# Check and handle transitions at ledges
	handle_surface_transition()

	move_and_slide()

	# Keep the character upright
	rotation = 0
