extends RayCast3D


@export var player: CharacterBody3D
@export var crosshair: TextureRect

var _last_crosshair_was_interactable := true

func _process(_delta: float) -> void:
	var is_interactable = is_colliding() and get_collider() is Interactable

	if is_interactable != _last_crosshair_was_interactable:
		_last_crosshair_was_interactable = is_interactable
		crosshair.visible = is_interactable
