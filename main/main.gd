extends Node3D


@export var world: Node

@onready var music: AudioStreamPlayer = $Music

const PLAYER = preload("res://main/player/player.tscn")
const MAIN_MENU = preload("res://scenes/ui/main_menu.tscn")

var main_menu_instance: Node3D


func _ready() -> void:
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
		world.switch_to_level("janitors room")
	
	main_menu_instance.queue_free()
	
	music.stream = preload("res://assets/audio/music/suspense_end.ogg")
	music.play()
