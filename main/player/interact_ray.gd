extends RayCast3D


@export var player: CharacterBody3D
@export var crosshair: TextureRect

var _last_crosshair_was_interactable := true


func _ready() -> void:
	pass 

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("interact"):
		var body = get_collider()
		
		if body is Interactable:
			if body.has_method("interact"):
				body.interact(player)

func _process(_delta: float) -> void:
	var is_interactable = is_colliding() and get_collider() is Interactable

	if is_interactable != _last_crosshair_was_interactable:
		_last_crosshair_was_interactable = is_interactable
		crosshair.visible = is_interactable
