class_name ItemInteractable
extends Interactable


@export var item: Item
@export var dialogue_id: DialogueResource
@export var use_camera: bool = true

@onready var sprite: Sprite3D = $Sprite3D
@onready var camera: Camera3D = $Camera3D
@onready var audio: AudioStreamPlayer = $AudioStreamPlayer
@onready var collision_shape: CollisionShape3D = $CollisionShape3D

var item_model: Node3D
var item_picked_up: bool


func _ready() -> void:
	if item:
		item_model = item.item_model.instantiate()
		add_child(item_model)
	else:
		collision_shape.disabled = true
		sprite.visible = false

func interact(player: CharacterBody3D) -> void:
	# Check if we should block interaction
	if GameState.should_block_player_input():
		return
		
	if not item:
		print("no item resource")
		return
	
	DialogueVariables.item = item.item_name
	
	if use_camera:
		toggle_camera(null, player)
		DialogueManager.dialogue_ended.connect(toggle_camera.bind(player))
	
	# Start dialogue - GameState will automatically handle player movement blocking
	DialogueManager.show_dialogue_balloon(dialogue_id, "")
	DialogueVariables.pick_up_item.connect(_on_pick_up_item)

func toggle_camera(_val, player: CharacterBody3D) -> void:
	if player.camera.current:
		player.camera.current = false
		camera.current = true
		player.visible = false
	else:
		player.camera.current = true
		camera.current = false
		player.visible = true
	
	if item_picked_up:
		return
	
	sprite.visible = !sprite.visible

func _on_pick_up_item() -> void:
	collision_shape.queue_free()
	audio.play()
	item_model.visible = false
	sprite.visible = false
	
	item_picked_up = true
	
	if item is AmmoItem:
		pass
	else:
		Inventory.add_item(item)
