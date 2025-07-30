extends Node3D


@onready var transition_manager: CanvasLayer = $TransitionManager
@onready var level_node: Node3D = $Level

var current_level: Node3D
var player_instance: CharacterBody3D

const FLOOR_0 = preload("res://scenes/levels/floors/floor_1.tscn")
const PLAYER = preload("res://main/player/player.tscn")


func _ready() -> void:
	await get_tree().process_frame
	
	current_level = FLOOR_0.instantiate()
	level_node.add_child(current_level)
	
	player_instance = PLAYER.instantiate()
	add_child(player_instance)
	player_instance.global_position = current_level.get_spawn_position("START")
	
	
