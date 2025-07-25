class_name DialogueInteract
extends Interactable


@export var dialogue_id: DialogueResource
@export var look_speed: float

## Called when the player interacts with a DialogueInteract Area3D.
func interact(player: CharacterBody3D) -> void:
	if not dialogue_id:
		print("No dialogue has been added to ", get_parent().name, "...")
		return
	
	# When the dialogue ends it will send a signal to the player, allowing the player to move.
	DialogueManager.dialogue_ended.connect(_on_dialogue_ended.bind(player), CONNECT_ONE_SHOT)
	DialogueManager.dialogue_started.connect(_on_dialogue_started.bind(player), CONNECT_ONE_SHOT)
	
	# Used to call a look_at function that will smoothly pan to the characters look_pos, or to their global position if their look_pos hasnt been added.
	var player_head: Node3D = player.get("head")
	var target_pos
	if has_node("LookPos"):
		target_pos = get_node("LookPos").global_position
	else:
		target_pos = global_position
	
	# Used for determining the intensity of the look. Defaults to 1 second transition.
	if look_speed:
		player_head.look_at_object(target_pos, look_speed)
	else:
		player_head.look_at_object(target_pos, 1.0)
	
	# Displays dialogue
	DialogueManager.show_dialogue_balloon(dialogue_id, "")

func _on_dialogue_ended(_val, player: CharacterBody3D) -> void:
	player.dialogue_end()

func _on_dialogue_started(_val, player: CharacterBody3D) -> void:
	player.dialogue_start()
