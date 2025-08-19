extends Node


@export var scene_transition: CanvasLayer

var current_level: Node3D
var spawn_points: Dictionary = {}


func switch_to_level(level_uid: String, delete: bool = true, keep_running: bool = false):
	if level_uid not in Constants.LEVEL_PATHS.values():
		print("level not in registry")
		return
	
	if current_level:
		if delete:
			current_level.queue_free()
		elif keep_running:
			current_level.visible = false
		else:
			remove_child(current_level)
	
	# Load and instantiate the level scene directly
	var scene = Constants.get_scene(level_uid)
	if scene:
		current_level = scene.instantiate()
		add_child(current_level)
		
		# Get level name from the scene if it has one
		var level_key 
		if current_level.get("level_name"):
			level_key = current_level.get("level_name")
			
			if not level_key:
				level_key = "no level name"
		else:
			level_key = "no level name"
		
		scene_transition.melt_transition(level_key)
		current_level.name = level_key
		
		collect_spawn_points()
		print("Current level: %s" % current_level.name)
		await get_tree().process_frame
		teleport_player_to_spawn()
	else:
		push_error("Scene for UID '%s' not found" % level_uid)

func collect_spawn_points() -> void:
	spawn_points.clear()
	var container := current_level.get_node_or_null("SpawnPoints")
	if container:
		for child in container.get_children():
			if child is Node3D:
				spawn_points[child.name] = child
	else:
		push_warning("No 'SpawnPoints' node found in scene.")

func get_spawn_point(spawn_name: String = "Default") -> Node3D:
	return spawn_points.get(spawn_name)

func teleport_player_to_spawn():
	var spawn = get_spawn_point()
	if spawn:
		var player = get_node("/root/Main/Player")
		if player and player.has_method("teleport_to_spawn"):
			player.teleport_to_spawn(spawn.global_transform.origin)
			print("spawned at: %s %s" % [spawn.name, spawn.position])
