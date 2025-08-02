extends Node3D

@export var crosshair: TextureRect
@export var hand: Node3D
@export var sensitivity: float = 0.25
@export var hand_follow_speed: float = 16.0
@export var hand_lag_amount: float = 0.5

var target_hand_rotation: Vector3

# Remove the local can_move property - we'll use GameState instead

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	target_hand_rotation = rotation_degrees
	
	# Connect to GameState signals to update mouse/crosshair
	GameState.dialogue_started.connect(_on_movement_blocked)
	GameState.cutscene_started.connect(_on_movement_blocked)
	GameState.menu_opened.connect(_on_movement_blocked)
	
	GameState.dialogue_ended.connect(_on_movement_allowed)
	GameState.cutscene_ended.connect(_on_movement_allowed)
	GameState.menu_closed.connect(_on_movement_allowed)

func _process(delta: float) -> void:
	if hand:
		var target_rotation = rotation_degrees + hand_lag_amount * Vector3.ONE
		target_hand_rotation = target_hand_rotation.lerp(target_rotation, hand_follow_speed * delta)
		hand.rotation_degrees = target_hand_rotation

func _input(event: InputEvent) -> void:
	# Use GameState instead of local can_move
	if GameState.should_block_player_input():
		return
	
	if event is InputEventMouseMotion:
		var movement: Vector2 = event.relative  
		rotation_degrees.y -= movement.x * sensitivity
		rotation_degrees.x -= movement.y * sensitivity
		rotation_degrees.x = clampf(rotation_degrees.x, -90, 90)

func _on_movement_blocked():
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	if crosshair:
		crosshair.visible = false

func _on_movement_allowed():
	# Only re-enable if no other blocking states are active
	if not GameState.is_any_blocking_state_active():
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		if crosshair:
			crosshair.visible = true

func look_at_object(object_position: Vector3, duration: float):
	var head_transform = global_transform
	head_transform = head_transform.looking_at(object_position, Vector3.UP)
	
	var tween = get_tree().create_tween()
	tween.tween_property(self, "global_transform", head_transform, duration).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
