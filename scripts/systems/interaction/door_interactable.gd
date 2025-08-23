@tool
class_name DoorInteract
extends Interactable


@export var scene: String

@export_category("Locked Door")
@export var locked_door_dialogue: DialogueResource
@export var unlocked_door_dialogue: DialogueResource
@export var locked: bool = false
@export var required_item: Item
@export var camera: Camera3D

@export_category("Knock Door")
@export var knock_dialogue: DialogueResource
@export var audio_player: AudioStreamPlayer

var player_instance: CharacterBody3D
var camera_switched: bool = false


func interact(player: CharacterBody3D) -> void:
	player_instance = player
	if locked:
		if GameState.should_block_player_input():
			return
	
		if camera:
			switch_to_interaction_camera(player)
			
			if not DialogueManager.dialogue_ended.is_connected(_on_dialogue_ended):
				DialogueManager.dialogue_ended.connect(_on_dialogue_ended)
		
		if required_item in Inventory.inventory_list:
			DialogueVariables.item = required_item.item_name
		
			if DialogueVariables.unlock_door.is_connected(_on_locked_door_unlocked):
				DialogueVariables.unlock_door.disconnect(_on_locked_door_unlocked)
			DialogueVariables.unlock_door.connect(_on_locked_door_unlocked)
		
			DialogueManager.show_dialogue_balloon(unlocked_door_dialogue, "")
		else:
			DialogueManager.show_dialogue_balloon(locked_door_dialogue, "")
		
		return
		
	elif scene:
		get_tree().get_first_node_in_group("World").switch_to_level(scene)
		
	elif knock_dialogue:
		audio_player.pitch_scale = randf_range(0.9, 1.1)
		audio_player.play()

		await get_tree().create_timer(0.5).timeout
		
		if GameState.should_block_player_input():
			return
		
		DialogueManager.show_dialogue_balloon(knock_dialogue, "")
		
	else:
		print_debug(self.name, " room scene and knock dialogue not found.")

func _on_locked_door_unlocked() -> void:
	Inventory.remove_item(required_item)
	locked = false

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
