class_name Player
extends CharacterBody3D


@export var head : Node3D
@export var camera : Camera3D
@export var collision_shape : CollisionShape3D
@export var foot_cast : RayCast3D
@export var flashlight : SpotLight3D

@onready var inventory: Control = %Inventory

const SPEED = 3.5
const JUMP_VELOCITY = 4.5
const CROUCH_SPEED = 4.0  

var input_direction: Vector2 = Vector2.ZERO

var flashlight_toggled: bool = false
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
	
	if flashlight.light_energy:
		flashlight_toggled = true

func _physics_process(delta: float) -> void:
	if GameState.should_block_player_input():
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
	if crouching and is_on_floor():
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

func teleport_to_spawn(spawn_position: Vector3):
	self.global_transform.origin = spawn_position

func _on_inventory_use_item(item_resource: Item) -> void:
	pass # Replace with function body.
