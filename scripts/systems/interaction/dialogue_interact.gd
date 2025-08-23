class_name DialogueInteract
extends Interactable

@export var dialogue_id: DialogueResource
@export var look_speed: float

func interact(player: CharacterBody3D) -> void:
	if not dialogue_id:
		print_debug("No dialogue has been added to ", get_parent().name, "...")
		return
	
	# Check if we should block interaction
	if GameState.should_block_player_input():
		return
	
	# Look at logic (same as before)
	var player_head: Node3D = player.get("head")
	var target_pos
	if has_node("LookPos"):
		target_pos = get_node("LookPos").global_position
	else:
		target_pos = global_position
	
	if look_speed:
		player_head.look_at_object(target_pos, look_speed)
	else:
		player_head.look_at_object(target_pos, 1.0)
	
	# Start dialogue - GameState will automatically handle player movement blocking
	DialogueManager.show_dialogue_balloon(dialogue_id, "")
