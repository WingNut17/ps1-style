extends Node3D


@export var world: Node

const PLAYER = preload(Constants.SCENE_PATHS.player)
const MAIN_MENU = preload(Constants.SCENE_PATHS.main_menu)

var main_menu_instance: Node3D


func _ready() -> void:
	"""
	var player_instance = PLAYER.instantiate()
	add_child(player_instance)
	
	if world.has_method("switch_to_level"):
		world.switch_to_level(Constants.LEVEL_PATHS.main_menu)
	"""
	
	main_menu_instance = MAIN_MENU.instantiate()
	main_menu_instance.connect("start_game", _on_main_menu_start_game)
	add_child(main_menu_instance)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("dev_quit"):
		get_tree().quit()

func _on_main_menu_start_game() -> void:
	var player_instance = PLAYER.instantiate()
	add_child(player_instance)

	if world.has_method("switch_to_level"):
		world.switch_to_level(Constants.LEVEL_PATHS.janitors_room)
	
	main_menu_instance.queue_free()
