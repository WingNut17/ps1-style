class_name DoorInteract
extends Interactable


@export var scene: String
@export var knock_dialogue: DialogueResource


func interact(_player: CharacterBody3D) -> void:
	if scene:
		get_tree().get_first_node_in_group("World").switch_to_level(scene)
	elif knock_dialogue:
		$AudioStreamPlayer.pitch_scale = randf_range(0.9, 1.1)
		$AudioStreamPlayer.play()

		await get_tree().create_timer(0.5).timeout
		
		if GameState.should_block_player_input():
			return
		
		# Displays dialogue
		DialogueManager.show_dialogue_balloon(knock_dialogue, "")
	else:
		print(self.name, " room scene and knock dialogue not found.")
