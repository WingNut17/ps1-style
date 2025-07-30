extends Node3D

@onready var world: Node = $World
@onready var player: Node3D = $Player

func _ready() -> void:
	# Start the game on the first level
	if world.has_method("switch_to_level"):
		world.switch_to_level("level_1")

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("dev_quit"):
		get_tree().quit()
