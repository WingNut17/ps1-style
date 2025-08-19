class_name Level
extends Node3D


@export var level_name: String ## Text displayed in the transition mananager.

var id: String
var scene_instance: Node3D
var spawn_points: Dictionary = {}


func initialize(level_uid: String) -> void:
	if level_uid.is_empty():
		push_error("Level UID cannot be empty")
		return
	
	if not level_uid.begins_with("uid://"):
		push_error("Invalid UID format: %s" % level_uid)
		return
	
	# Store the UID as the id
	id = level_uid
	
	# Load the scene directly using the UID
	var scene = Constants.get_scene(level_uid)
	if scene:
		scene_instance = scene.instantiate()
		add_child(scene_instance)
		collect_spawn_points()
	else:
		push_error("Scene for UID '%s' not found" % level_uid)

func collect_spawn_points() -> void:
	var container := scene_instance.get_node_or_null("SpawnPoints")
	if container:
		for child in container.get_children():
			if child is Node3D:
				spawn_points[child.name] = child
	else:
		push_warning("No 'SpawnPoints' node found in scene.")

func get_spawn_point(spawn_name: String = "Default") -> Node3D:
	return spawn_points.get(spawn_name)
