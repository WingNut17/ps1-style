# SceneMeltTransition.gd
# Attach this to an AutoLoad singleton for global access

extends Node

var transition_scene: PackedScene = preload("res://MeltTransition.tscn")

func melt_to_scene(next_scene_path: String, duration: float = 2.0):
	var current_scene = get_tree().current_scene
	
	# Capture current viewport
	var viewport = get_viewport()
	var screenshot = viewport.get_texture().get_image()
	var screenshot_texture = ImageTexture.new()
	screenshot_texture.create_from_image(screenshot)
	
	# Load new scene
	var next_scene = load(next_scene_path).instantiate()
	
	# Create transition overlay
	var transition = transition_scene.instantiate()
	transition.setup_melt(screenshot_texture, duration)
	
	# Add new scene first (so it's behind the melting overlay)
	get_tree().root.add_child(next_scene)
	get_tree().current_scene = next_scene
	
	# Add transition overlay on top
	get_tree().root.add_child(transition)
	
	# Remove old scene
	current_scene.queue_free()
	
	# Start the melt effect
	transition.start_melt()
