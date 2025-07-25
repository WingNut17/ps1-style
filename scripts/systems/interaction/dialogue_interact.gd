class_name DialogueInteractable
extends Interactable


@export var dialogue_id: DialogueResource
@export var look_speed: float


func interact(player: CharacterBody3D) -> void:
	# Connect with CONNECT_ONE_SHOT flag
	DialogueManager.dialogue_ended.connect(_on_dialogue_ended.bind(player), CONNECT_ONE_SHOT)
	
	var player_head: Node3D = player.get("head")
	var target_pos = get_node("LookPos").global_position
	
	if look_speed:
		player_head.look_at_object(target_pos, look_speed)
	else:
		player_head.look_at_object(target_pos, 1.0)
	
	player.can_move = false
	DialogueManager.show_dialogue_balloon(dialogue_id, "")

func _on_dialogue_ended(_val, player: CharacterBody3D):
	player.interact_ended()
