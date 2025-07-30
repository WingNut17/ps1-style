extends CharacterBody3D


@export var head : Node3D
@export var collision_shape : CollisionShape3D
@export var foot_cast : RayCast3D

const SPEED = 3.5
const JUMP_VELOCITY = 4.5
const CROUCH_SPEED = 4.0  

var can_move: bool = true:
	set(value):
		can_move = value
		head.can_move = value

var input_direction: Vector2 = Vector2.ZERO
var shape: Shape3D
var crouching: bool = false
var target_height: float
var normal_height: float = 2.0
var crouch_height: float = 1.25
var target_collision_height: float
var normal_collision_height: float = 0.0
var crouch_collision_height: float = 0.375


func _ready() -> void:
	shape = collision_shape.shape
	normal_height = shape.height
	target_height = normal_height

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("crouch"):
		crouch()
	if event.is_action_released("crouch"):
		crouch()
	
	# to be honest i dont think this game even needs a jump...
	if event.is_action_pressed("jump") and is_on_floor() and not crouching:
		jump()
	
	input_direction = Input.get_vector("left", "right", "forward", "backward")

func _physics_process(delta: float) -> void:
	if !can_move:
		return

	# Smoothly interpolate the collision shape height
	var current_height = shape.height
	var current_collision_height = collision_shape.position.y
	if abs(current_height - target_height) > 0.01:  # Only update if there's a meaningful difference
		shape.height = lerpf(current_height, target_height, CROUCH_SPEED * delta)
		collision_shape.position.y = lerpf(current_collision_height, target_collision_height, CROUCH_SPEED * delta)
	
	# Add the gravity
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	# Horizontal basis ensures the player is moving the direction they are looking.
	var horizontal_basis = Basis(Vector3.UP, head.rotation.y)
	var direction := (horizontal_basis * Vector3(input_direction.x, 0, input_direction.y)).normalized()
	
	var current_speed = SPEED
	if crouching:
		current_speed *= 0.5
	
	if direction:
		velocity.x = direction.x * current_speed
		velocity.z = direction.z * current_speed
		
	else:
		velocity.x = move_toward(velocity.x, 0, current_speed)
		velocity.z = move_toward(velocity.z, 0, current_speed)
	
	move_and_slide()
	
	# Try to play step sound if the player is wanting to move, and on the floor
	var moving_velocity = Vector2(velocity.x, velocity.z)
	if moving_velocity and is_on_floor():
		foot_cast.try_to_play_audio()

func jump() -> void:
	velocity.y = JUMP_VELOCITY

func crouch() -> void:
	if not crouching:
		crouching = true
		target_height = crouch_height
		target_collision_height = crouch_collision_height
	elif crouching:
		crouching = false
		target_height = normal_height
		target_collision_height = normal_collision_height

func dialogue_end() -> void:
	can_move = true

func dialogue_start() -> void:
	can_move = false
