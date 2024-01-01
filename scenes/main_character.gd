extends CharacterBody2D


const SPEED = 400.0
const JUMP_VELOCITY = -900.0
const SLAM_VELOCITY = 1000
@onready var sprite_2d = $Sprite2D
@onready var collision_2d = $CollisionShape2D

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var is_crouched = false
var b_down= false

func _down_helper():
	if is_crouched:
		return
	else:
		is_crouched = true
		#sprite_2d.rotation_degrees = deg_to_rad(-90)
		#collision_2d.rotation_degrees = deg_to_rad(-90)
		sprite_2d.scale.y *= 0.5
		collision_2d.scale.y *= 0.5

	
func _up_helper():
	if not is_crouched:
		return
	is_crouched = false
	#sprite_2d.rotation_degrees = deg_to_rad(90)
	#collision_2d.rotation_degrees = deg_to_rad(90)
	sprite_2d.scale.y *= 2
	collision_2d.scale.y *= 2

func _physics_process(delta):
	# Animations
	if not b_down and (velocity.x > 1 || velocity.x < -1):
		sprite_2d.animation = "running"
	elif velocity.x == 0:
		sprite_2d.animation = "default"
	# Crouch Slide/Duck or Slam
	#var is_down = Input.is_key_pressed(KEY_DOWN)
	#var is_down_released = Input.is_action_just_released("ui_down")
	
	# Add the gravity.
	if not is_on_floor():
		print("not on floor")
		velocity.y += gravity * delta
		sprite_2d.animation = "jumping"
		if not is_crouched and Input.is_key_pressed(KEY_DOWN):
			print("down b")
			b_down = true
			velocity.y = SLAM_VELOCITY
			sprite_2d.animation = "slamming"

	var is_down = Input.is_key_pressed(KEY_DOWN)
	var is_down_released = Input.is_action_just_released("ui_down")

	if is_down and not b_down:
		print("crouch")
		_down_helper()
		velocity.y += gravity * delta
	if is_down_released and not b_down:
		print("release crouch")
		_up_helper()
	if is_down_released:
		print("release down b")
		b_down = false
		sprite_2d.animation = "default"
		
	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction = Input.get_axis("ui_left", "ui_right")
	if direction and not b_down:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, 5) if is_crouched else move_toward(velocity.x, 0, 10)

	if direction !=0: 
		sprite_2d.flip_h = (direction == -1)
	
	move_and_slide()
	
