extends CharacterBody3D
@onready var standing_collision_shape = $standing_collision_shape
@onready var crouching_collision_shape_2 = $crouching_collision_shape2
@onready var ray_cast_3d = $RayCast3D

var current_speed = 5.0

const walking_speed = 5.0
const sprinting_speed = 8
const crouching_speed = 7

const JUMP_VELOCITY = 5

const mouse_sens = 0.3

@onready var head = $Head

var lerp_speed = 10.0

var sliding = false
var walking = false
var sprinting = false
var crouching = false

# Slide vars
var slide_timer = 0.0
var slide_timer_max = 1.0
var slide_vector
var input_max

var direction = Vector3.ZERO

var crouching_depth = -0.5

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event):
	if event is InputEventMouseMotion:
		rotate_y(deg_to_rad(-event.relative.x * mouse_sens))
		
		head.rotate_x(deg_to_rad(-event.relative.y * mouse_sens))
		head.rotation.x = clamp(head.rotation.x,deg_to_rad(-89), deg_to_rad(89))
		

func _physics_process(delta):
	#Getting movement input
	
	var input_dir = Input.get_vector("left", "right", "forward", "backward")
	
	#Crouch
	if Input.is_action_pressed("crouch"):
		current_speed = crouching_speed
		head.position.y = lerp(head.position.y,1.8 + crouching_depth, delta*lerp_speed)
		standing_collision_shape.disabled = true
		crouching_collision_shape_2.disabled = false
	elif !ray_cast_3d.is_colliding():
		standing_collision_shape.disabled = false
		crouching_collision_shape_2.disabled = true
		head.position.y = lerp(head.position.y,1.8,delta*lerp_speed)
	
	if sprinting && input_dir  != Vector2.ZERO:
		sliding = true
		slide_timer = slide_timer_max
		slide_vector = input_max
		
		
	
	sliding = false
	walking = false
	sprinting = false
	crouching = false
	
	
	#Sprint
	if Input.is_action_just_released("sprint"):
		current_speed = walking_speed
	
	if Input.is_action_just_pressed("sprint"):
		current_speed = sprinting_speed
	
	sliding = false
	walking = false
	sprinting = true
	crouching = false
	
	if sliding:
		slide_timer -= delta
		if slide_timer <= 0:
			sliding = false
			print("Slide end")
	
	
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		
		
		
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	
	
	direction = lerp(direction, (transform.basis * Vector3(input_dir.x, 0, input_dir.y)). normalized(), delta*lerp_speed)
	if direction:
		velocity.x = direction.x * current_speed
		velocity.z = direction.z * current_speed
	else:
		velocity.x = move_toward(velocity.x, 0, current_speed)
		velocity.z = move_toward(velocity.z, 0, current_speed)

	move_and_slide()

	if Input.is_action_pressed("exit"):
		get_tree().quit()
		
		
		if Input.is_action_pressed("restart"):
			get_tree().reload_current_scene()
