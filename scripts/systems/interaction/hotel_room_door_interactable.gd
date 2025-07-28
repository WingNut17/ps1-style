class_name DoorInteract
extends Interactable


@export var room_scene: PackedScene
@export var knock_dialogue: DialogueResource


func interact(player: CharacterBody3D) -> void:
	if room_scene:
		main = get_tree().root.get_node("Main")
		main.transition_manager.melt_transition(main.current_level, room_scene)
		pass
	elif knock_dialogue:
		$AudioStreamPlayer.pitch_scale = randf_range(0.9, 1.1)
		$AudioStreamPlayer.play()
		
		player.can_move = false
		await get_tree().create_timer(0.5).timeout
		
		DialogueManager.dialogue_ended.connect(_on_dialogue_ended.bind(player), CONNECT_ONE_SHOT)
		DialogueManager.dialogue_started.connect(_on_dialogue_started.bind(player), CONNECT_ONE_SHOT)

		# Displays dialogue
		DialogueManager.show_dialogue_balloon(knock_dialogue, "")
	else:
		print(self.name, " room scene and knock dialogue not found.")

func _on_dialogue_ended(_val, player: CharacterBody3D) -> void:
	player.dialogue_end()

func _on_dialogue_started(_val, player: CharacterBody3D) -> void:
	player.dialogue_start()
