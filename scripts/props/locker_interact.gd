extends Interactable


@export var animation_player: AnimationPlayer

var can_open: bool = true
var open: bool = false


func interact(_player: CharacterBody3D) -> void:
	if !can_open:
		return
	
	can_open = !can_open
	open = !open
	
	if open:
		animation_player.play("open")
	elif !open:
		animation_player.play("close")

func _on_animation_player_animation_finished(_anim_name: StringName) -> void:
	can_open = true
