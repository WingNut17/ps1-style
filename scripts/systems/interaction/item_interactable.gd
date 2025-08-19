class_name ItemInteractable
extends Interactable


@export var item: Item
@export var dialogue_id: DialogueResource
@export var use_camera: bool = true
@export var item_node: Node3D

@onready var sprite: Sprite3D = $Sprite3D
@onready var camera: Camera3D = $Camera3D
@onready var audio: AudioStreamPlayer = $AudioStreamPlayer
@onready var collision_shape: CollisionShape3D = $CollisionShape3D

var item_picked_up: bool
var player_instance: CharacterBody3D
var camera_switched: bool = false


func _ready() -> void:
	if not item:
		collision_shape.disabled = true
		sprite.visible = false
		item_node.visible = false

func interact(player: CharacterBody3D) -> void:
	player_instance = player
	if GameState.should_block_player_input():
		return
		
	if not item:
		print("no item resource")
		return
	
	DialogueEvents.item = item.item_name
	
	if use_camera:
		switch_to_interaction_camera(player)
		
		# Connect dialogue end signal only if not already connected
		if not DialogueManager.dialogue_ended.is_connected(_on_dialogue_ended):
			DialogueManager.dialogue_ended.connect(_on_dialogue_ended)
	
	DialogueManager.show_dialogue_balloon(dialogue_id, "")
	
	if DialogueEvents.pick_up_item.is_connected(_on_pick_up_item):
		DialogueEvents.pick_up_item.disconnect(_on_pick_up_item)
	DialogueEvents.pick_up_item.connect(_on_pick_up_item)

func switch_to_interaction_camera(player: CharacterBody3D) -> void:
	"""Switch from player camera to interaction camera"""
	if not camera_switched:
		player.camera.current = false
		camera.current = true
		player.visible = false
		camera_switched = true

func switch_to_player_camera() -> void:
	"""Switch back to player camera"""
	if camera_switched and player_instance:
		player_instance.camera.current = true
		camera.current = false
		player_instance.visible = true
		camera_switched = false

func _on_dialogue_ended(_val) -> void:
	"""Called when dialogue ends - switch back to player camera"""
	switch_to_player_camera()
	
	# Clean up the signal connection
	if DialogueManager.dialogue_ended.is_connected(_on_dialogue_ended):
		DialogueManager.dialogue_ended.disconnect(_on_dialogue_ended)

func _on_pick_up_item() -> void:
	collision_shape.queue_free()
	audio.play()
	item_node.visible = false
	sprite.visible = false
	
	item_picked_up = true
	
	if item is AmmoItem:
		# TODO create the ammo adding to inventory system
		pass
	else:
		Inventory.add_item(item)
