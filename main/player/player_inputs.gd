extends Node


@export var player: CharacterBody3D
@export var head: Head
@export var item_container: ItemContainer
@export var inventory: InventoryUI
@export var flashlight: Light3D
@export var interact_ray: RayCast3D

# Mouse sensitivity - you might want to expose this as an export variable
@export var mouse_sensitivity: float = 0.1

var flashlight_toggled: bool = false
var inventory_open: bool = false


func _ready() -> void:
	# Initialize mouse mode
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
	# Connect to GameState signals for mouse mode management
	GameState.dialogue_started.connect(_on_movement_blocked)
	GameState.cutscene_started.connect(_on_movement_blocked)
	GameState.menu_opened.connect(_on_movement_blocked)
	GameState.loading.connect(_on_loading)
	
	GameState.dialogue_ended.connect(_on_movement_allowed)
	GameState.cutscene_ended.connect(_on_movement_allowed)
	GameState.menu_closed.connect(_on_movement_allowed)
	GameState.done_loading.connect(_on_loading)


func _input(event: InputEvent) -> void:
	# Handle mouse look
	if event is InputEventMouseMotion and not GameState.should_block_player_input():
		_handle_mouse_look(event)
	
	# Early return for blocked input
	if GameState.should_block_player_input():
		return
	
	# Player movement and actions
	_handle_player_input(event)
	_handle_item_input(event)
	_handle_interact_input(event)
	_handle_ui_input(event)


func _unhandled_input(event: InputEvent) -> void:
	# Early return for blocked input
	if GameState.should_block_player_input():
		return


func _handle_mouse_look(event: InputEventMouseMotion) -> void:
	if not head:
		return
		
	var movement: Vector2 = event.relative
	head.rotation_degrees.y -= movement.x * mouse_sensitivity
	head.rotation_degrees.x -= movement.y * mouse_sensitivity
	head.rotation_degrees.x = clampf(head.rotation_degrees.x, -90, 90)


func _handle_player_input(event: InputEvent) -> void:
	if not player:
		return
	
	# Crouch
	if event.is_action_pressed("crouch") or event.is_action_released("crouch"):
		if player.has_method("crouch"):
			player.crouch()
	
	# Jump
	if event.is_action_pressed("jump"):
		if player.has_method("jump"):
			var is_crouching = player.get("crouching")
			if player.is_on_floor() and not is_crouching:
				player.jump()
	
	# Flashlight
	if event.is_action_pressed("flashlight"):
		_toggle_flashlight()


func _handle_ui_input(event: InputEvent) -> void:
	# Inventory toggle
	if event.is_action_pressed("inventory"):
		if GameState.is_in_menu:
			GameState.close_menu()
			inventory_open = false
		else:
			GameState.open_menu()
			inventory_open = true
		
		if inventory:
			inventory.visible = !inventory.visible


func _handle_item_input(event: InputEvent) -> void:
	if not item_container or not item_container.item:
		return
	
	var item = item_container.item
	
	# Check if item is equipable
	if not item.get("equipable"):
		return
	
	# Primary action (click)
	if event.is_action_pressed("click"):
		if item.get("full_auto") != null:
			if item.full_auto:
				if item.has_method("on_full_auto_start"):
					item.on_full_auto_start()
			else:
				if item.has_method("on_primary_action"):
					item.on_primary_action()
		elif item.has_method("on_primary_action"):
			item.on_primary_action()
	
	# Release primary action
	elif event.is_action_released("click"):
		if item.get("full_auto") != null and item.full_auto:
			if item.has_method("on_full_auto_stop"):
				item.on_full_auto_stop()
	
	# Reload
	elif event.is_action_pressed("reload"):
		if item.has_method("on_reload"):
			item.on_reload()


func _handle_interact_input(event) -> void:
	if event.is_action_pressed("interact"):
		var body = interact_ray.get_collider()
		
		if body is Interactable:
			if body.has_method("interact"):
				body.interact(player)


func _toggle_flashlight() -> void:
	if not flashlight:
		return
	
	if flashlight_toggled:
		flashlight.light_energy = 0.0
	else:
		flashlight.light_energy = 10.0
	
	flashlight_toggled = !flashlight_toggled


func _process(_delta: float) -> void:
	if GameState.should_block_player_input():
		return
		
	if player and player.get("input_direction") != null:
		var input_direction = Input.get_vector("left", "right", "forward", "backward")
		player.input_direction = input_direction


func _on_loading() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _on_movement_blocked() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


func _on_movement_allowed() -> void:
	if not GameState.is_any_blocking_state_active():
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
	interact_ray._last_crosshair_was_interactable = true
