extends Node3D


@onready var transition_manager: CanvasLayer = $TransitionManager

const LEVEL_1 = preload("res://scenes/levels/level_1.tscn")
const LEVEL_2 = preload("res://scenes/levels/level_2.tscn")

var level_instance


func _ready() -> void:
	level_instance = LEVEL_1.instantiate()
	add_child(level_instance)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("test"):
		transition_manager.melt_transition(level_instance, LEVEL_2)
