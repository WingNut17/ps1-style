class_name Level
extends Node3D


@export var spawn: Node3D
@export var level_name: String

var floor_entered_from: String:
	set(value):
		floor_entered_from = value


func _ready() -> void:
	pass

func get_spawn_position(spawn_name: String = "START") -> Vector3:
	if spawn and spawn.has_node(spawn_name):
		return spawn.get_node(spawn_name).global_position
	else:
		print("Spawn node '" + spawn_name + "' not found, using default position")
		return Vector3.ZERO
